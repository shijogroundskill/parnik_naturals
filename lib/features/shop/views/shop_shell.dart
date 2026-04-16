import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/nav_controller.dart';
import '../../more/views/more_view.dart';
import 'shop_home_view.dart';
import 'shop_cart_view.dart';

class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavController>();
    final tabs = <Widget>[
      const ShopHomeView(),
      const ShopCartView(),
      const MoreView(),
    ];

    return Obx(() {
      final idx = nav.index.value;
      return Scaffold(
        body: tabs[idx.clamp(0, tabs.length - 1)],
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: nav.setIndex,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Obx(() {
                final count = Get.find<CartController>()
                        .cart
                        .value
                        ?.lines
                        .fold<int>(0, (a, b) => a + b.quantity) ??
                    0;
                if (count <= 0) return const Icon(Icons.shopping_bag_outlined);
                return Badge.count(
                  count: count,
                  child: const Icon(Icons.shopping_bag_outlined),
                );
              }),
              selectedIcon: const Icon(Icons.shopping_bag),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.menu_outlined),
              selectedIcon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      );
    });
  }
}

