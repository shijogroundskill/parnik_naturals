import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../shopify/shopify_env.dart';
import 'customer_account_env.dart';

class CustomerAccountConfig {
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri graphqlEndpoint;

  const CustomerAccountConfig({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.graphqlEndpoint,
  });
}

class CustomerOAuthParams {
  final String verifier;
  final String challenge;
  final String state;
  final String nonce;

  const CustomerOAuthParams({
    required this.verifier,
    required this.challenge,
    required this.state,
    required this.nonce,
  });
}

class CustomerTokens {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  const CustomerTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
}

class CustomerAccountClient {
  CustomerAccountClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<CustomerAccountConfig> discover() async {
    // Customer Account API discovery should use the public storefront domain.
    // (Shopify may serve auth/customer account endpoints on the customer-accounts domain
    // tied to the storefront.)
    final shopDomain = ShopifyEnv.publicDomain;

    final openid = await _http.get(
      Uri.https(shopDomain, '/.well-known/openid-configuration'),
      headers: const {'Accept': 'application/json'},
    );
    if (openid.statusCode < 200 || openid.statusCode >= 300) {
      throw StateError('OpenID discovery failed: HTTP ${openid.statusCode}');
    }
    final openidJson = jsonDecode(openid.body) as Map<String, dynamic>;

    final api = await _http.get(
      Uri.https(shopDomain, '/.well-known/customer-account-api'),
      headers: const {'Accept': 'application/json'},
    );
    if (api.statusCode < 200 || api.statusCode >= 300) {
      throw StateError('API discovery failed: HTTP ${api.statusCode}');
    }
    final apiJson = jsonDecode(api.body) as Map<String, dynamic>;

    return CustomerAccountConfig(
      authorizationEndpoint: Uri.parse(
        (openidJson['authorization_endpoint'] ?? '').toString(),
      ),
      tokenEndpoint: Uri.parse(
        (openidJson['token_endpoint'] ?? '').toString(),
      ),
      graphqlEndpoint: Uri.parse((apiJson['graphql_api'] ?? '').toString()),
    );
  }

  CustomerOAuthParams createPkce() {
    final verifier = _randomUrlSafe(64);
    final bytes = sha256.convert(utf8.encode(verifier)).bytes;
    final challenge = base64UrlEncode(bytes).replaceAll('=', '');
    return CustomerOAuthParams(
      verifier: verifier,
      challenge: challenge,
      state: _randomUrlSafe(32),
      nonce: _randomUrlSafe(32),
    );
  }

  Uri buildAuthorizeUrl(CustomerAccountConfig cfg, CustomerOAuthParams pkce) {
    CustomerAccountEnv.validate();
    final authUrl = cfg.authorizationEndpoint.replace(
      queryParameters: <String, String>{
        'client_id': CustomerAccountEnv.clientId,
        'response_type': 'code',
        'redirect_uri': CustomerAccountEnv.redirectUri,
        'scope': 'openid email customer-account-api:full',
        'state': pkce.state,
        'nonce': pkce.nonce,
        'code_challenge': pkce.challenge,
        'code_challenge_method': 'S256',
      },
    );
    return authUrl;
  }

  Future<CustomerTokens> exchangeCode({
    required CustomerAccountConfig cfg,
    required String code,
    required String verifier,
  }) async {
    CustomerAccountEnv.validate();
    final res = await _http.post(
      cfg.tokenEndpoint,
      headers: const <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: <String, String>{
        'grant_type': 'authorization_code',
        'client_id': CustomerAccountEnv.clientId,
        'code': code,
        'redirect_uri': CustomerAccountEnv.redirectUri,
        'code_verifier': verifier,
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Token exchange failed: HTTP ${res.statusCode} ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final access = (json['access_token'] ?? '').toString();
    if (access.isEmpty) throw StateError('Missing access_token');
    return CustomerTokens(
      accessToken: access,
      refreshToken: json['refresh_token']?.toString(),
      expiresIn: (json['expires_in'] as num?)?.toInt(),
    );
  }

  Future<Map<String, dynamic>> queryCustomerApi({
    required CustomerAccountConfig cfg,
    required String accessToken,
    required String query,
    Map<String, dynamic> variables = const {},
  }) async {
    final res = await _http.post(
      cfg.graphqlEndpoint,
      headers: <String, String>{
        'Content-Type': 'application/json',
        // Customer Account API expects the access_token directly in Authorization header.
        'Authorization': accessToken,
      },
      body: jsonEncode(<String, dynamic>{
        'query': query,
        'variables': variables,
      }),
    );

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Customer API HTTP ${res.statusCode}: ${res.body}');
    }

    if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
      throw StateError('Customer API error: ${jsonEncode(json['errors'])}');
    }

    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Customer API response: ${res.body}');
    }
    return data;
  }

  static String _randomUrlSafe(int length) {
    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final rand = Random.secure();
    return List.generate(length, (_) => alphabet[rand.nextInt(alphabet.length)])
        .join();
  }
}

