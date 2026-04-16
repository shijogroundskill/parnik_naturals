import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import '../../../shopify/shopify_models.dart';
// ShopifyRepository intentionally not used here; Customer Account API uses OAuth.
import '../../../customer_account/customer_account_client.dart';
import '../../../customer_account/customer_account_queries.dart';
import '../../../customer_account/customer_account_env.dart';
import '../views/customer_auth_webview.dart';

class AccountController extends GetxController {
  AccountController();

  static const _tokenKey = 'customer_access_token';
  static const _refreshKey = 'customer_refresh_token';
  static const _nameKey = 'customer_display_name';
  static const _emailKey = 'customer_email';

  final _customer = CustomerAccountClient();
  final _storage = const FlutterSecureStorage();
  CustomerAccountConfig? _cfg;

  final token = RxnString();
  final displayName = RxnString();
  final email = RxnString();
  final isBusy = false.obs;
  final error = RxnString();
  final orders = <OrderSummary>[].obs;

  bool get isSignedIn => (token.value ?? '').isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    if (kIsWeb) {
      // Avoid SharedPreferences plugin issues during hot-restart on web.
      // (Web builds don't need persisted auth for demo/testing.)
      token.value = token.value;
      return;
    }
    token.value = await _storage.read(key: _tokenKey);
    displayName.value = await _storage.read(key: _nameKey);
    email.value = await _storage.read(key: _emailKey);
  }

  Future<void> _saveToken(String? value) async {
    if (kIsWeb) {
      token.value = (value == null || value.isEmpty) ? null : value;
      return;
    }
    if (value == null || value.isEmpty) {
      await _storage.delete(key: _tokenKey);
    } else {
      await _storage.write(key: _tokenKey, value: value);
    }
    token.value = value;
  }

  Future<void> _saveProfile({String? name, String? email}) async {
    if (kIsWeb) {
      displayName.value = name;
      this.email.value = email;
      return;
    }
    if (name == null || name.isEmpty) {
      await _storage.delete(key: _nameKey);
    } else {
      await _storage.write(key: _nameKey, value: name);
    }
    if (email == null || email.isEmpty) {
      await _storage.delete(key: _emailKey);
    } else {
      await _storage.write(key: _emailKey, value: email);
    }
    displayName.value = name;
    this.email.value = email;
  }

  Future<void> signIn(BuildContext context) async {
    if (kIsWeb) {
      throw StateError('OTP sign-in is not supported on web builds.');
    }

    try {
      isBusy.value = true;
      error.value = null;
      CustomerAccountEnv.validate();

      _cfg ??= await _customer.discover();
      final pkce = _customer.createPkce();
      final authUrl = _customer.buildAuthorizeUrl(_cfg!, pkce);

      final redirected = await Get.to<String?>(
        () => CustomerAuthWebView(
          authorizationUrl: authUrl.toString(),
          redirectUri: CustomerAccountEnv.redirectUri,
        ),
      );
      if (redirected == null) return;

      final uri = Uri.parse(redirected);
      final code = uri.queryParameters['code'] ?? '';
      final state = uri.queryParameters['state'] ?? '';
      if (code.isEmpty) {
        throw StateError('Login cancelled');
      }
      if (state.isNotEmpty && state != pkce.state) {
        throw StateError('Invalid state');
      }

      final tokens = await _customer.exchangeCode(
        cfg: _cfg!,
        code: code,
        verifier: pkce.verifier,
      );

      await _saveToken(tokens.accessToken);
      if (tokens.refreshToken != null) {
        await _storage.write(key: _refreshKey, value: tokens.refreshToken);
      }

      await refreshOrders();
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> signOut() async {
    final t = token.value;
    if (t == null || t.isEmpty) return;
    try {
      isBusy.value = true;
      error.value = null;
      // Customer Account API logout uses OAuth end-session; we just clear tokens locally.
    } catch (_) {
      // ignore logout errors
    } finally {
      orders.clear();
      await _saveToken(null);
      await _saveProfile(name: null, email: null);
      if (!kIsWeb) {
        await _storage.delete(key: _refreshKey);
      }
      isBusy.value = false;
    }
  }

  Future<void> refreshOrders() async {
    final t = token.value;
    if (t == null || t.isEmpty) {
      orders.clear();
      return;
    }
    try {
      isBusy.value = true;
      error.value = null;
      _cfg ??= await _customer.discover();
      final data = await _customer.queryCustomerApi(
        cfg: _cfg!,
        accessToken: t,
        query: CustomerAccountQueries.orders,
        variables: const {'first': 30},
      );
      final customer = data['customer'] as Map<String, dynamic>?;
      final name = customer?['displayName']?.toString();
      final em = (customer?['emailAddress'] as Map<String, dynamic>?)
          ?['emailAddress']
          ?.toString();
      await _saveProfile(name: name, email: em);
      final edges =
          (customer?['orders']?['edges'] as List<dynamic>? ?? const <dynamic>[]);
      orders.value = edges
          .map((e) => e as Map<String, dynamic>)
          .map((e) => e['node'] as Map<String, dynamic>)
          .map(OrderSummary.fromJson)
          .toList(growable: false);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isBusy.value = false;
    }
  }
}

