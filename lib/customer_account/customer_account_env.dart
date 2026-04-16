import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomerAccountEnv {
  static String get clientId => dotenv.env['CUSTOMER_ACCOUNT_CLIENT_ID'] ?? '';
  static String get redirectUri =>
      dotenv.env['CUSTOMER_ACCOUNT_REDIRECT_URI'] ?? '';

  static void validate() {
    if (clientId.isEmpty || redirectUri.isEmpty) {
      throw StateError(
        'Missing CUSTOMER_ACCOUNT_CLIENT_ID or CUSTOMER_ACCOUNT_REDIRECT_URI in .env',
      );
    }
  }
}

