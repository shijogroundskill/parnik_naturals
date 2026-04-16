import 'dart:convert';

import 'package:http/http.dart' as http;

import 'shopify_env.dart';

class ShopifyClient {
  ShopifyClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Uri get _endpoint => Uri.https(
        ShopifyEnv.storeDomain,
        '/api/${ShopifyEnv.apiVersion}/graphql.json',
      );

  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const {},
  }) async {
    final res = await _http.post(
      _endpoint,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': ShopifyEnv.storefrontAccessToken,
      },
      body: jsonEncode(<String, dynamic>{
        'query': document,
        'variables': variables,
      }),
    );

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Shopify HTTP ${res.statusCode}: ${res.body}');
    }

    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw StateError('Shopify GraphQL error: ${jsonEncode(errors)}');
    }

    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Shopify response: ${res.body}');
    }
    return data;
  }
}

