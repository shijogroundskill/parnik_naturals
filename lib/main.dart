import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'features/shop/controllers/cart_controller.dart';
import 'features/shop/controllers/nav_controller.dart';
import 'features/shop/controllers/shop_controller.dart';
import 'features/shop/views/shop_shell.dart';
import 'features/more/controllers/content_controller.dart';
import 'features/account/controllers/account_controller.dart';
import 'shopify/shopify_client.dart';
import 'shopify/shopify_env.dart';
import 'shopify/shopify_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  ShopifyEnv.validate();

  final repo = ShopifyRepository(ShopifyClient());
  Get.put<ShopifyRepository>(repo, permanent: true);
  Get.put(ShopController(repo), permanent: true);
  Get.put(CartController(repo), permanent: true);
  Get.put(NavController(), permanent: true);
  Get.put(ContentController(repo), permanent: true);
  Get.put(AccountController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Parnik Naturals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.shop,
      getPages: AppPages.pages,
    );
  }
}

class AppRoutes {
  static const shop = '/shop';
}

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.shop, page: () => const ShopShell()),
  ];
}

class AppTheme {
  static const _brand = Color(0xFF2E7D32); // natural green

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _brand),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F8F7),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE1E5E1)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
