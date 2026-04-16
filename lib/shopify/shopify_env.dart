import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShopifyEnv {
  static String get storeDomain => dotenv.env['SHOPIFY_STORE_DOMAIN'] ?? '';
  static String get publicDomain => dotenv.env['SHOPIFY_PUBLIC_DOMAIN'] ?? '';
  static String get storefrontAccessToken =>
      dotenv.env['SHOPIFY_STOREFRONT_ACCESS_TOKEN'] ?? '';
  static String get apiVersion => dotenv.env['SHOPIFY_API_VERSION'] ?? '2026-04';

  static void validate() {
    if (storeDomain.isEmpty || storefrontAccessToken.isEmpty) {
      throw StateError(
        'Missing Shopify configuration. Set SHOPIFY_STORE_DOMAIN and '
        'SHOPIFY_STOREFRONT_ACCESS_TOKEN in .env',
      );
    }

    if (!storeDomain.contains('myshopify.com')) {
      throw StateError(
        'SHOPIFY_STORE_DOMAIN must be your *.myshopify.com domain for '
        'Storefront API requests (custom domains redirect).',
      );
    }

    if (publicDomain.isEmpty) {
      throw StateError('Missing SHOPIFY_PUBLIC_DOMAIN in .env');
    }
  }
}

