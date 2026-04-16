import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/nav_controller.dart';

class ShopCartView extends StatelessWidget {
  const ShopCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();
    return SafeArea(
      child: Obx(() {
        final cart = c.cart.value;
        final busy = c.isBusy.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart'),
            actions: [
              if (busy)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          body: cart == null || cart.lines.isEmpty
              ? _EmptyCart(onShop: () => Get.find<NavController>().goToShop())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  itemBuilder: (context, i) {
                    final line = cart.lines[i];
                    final img = line.product.featuredImage?.url ?? '';
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE9EEE9)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 66,
                              height: 66,
                              child: img.isEmpty
                                  ? Container(color: const Color(0xFFF1F4F1))
                                  : CachedNetworkImage(
                                      imageUrl: img,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  line.variant.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton.filledTonal(
                                      onPressed: busy
                                          ? null
                                          : () => c.decrementLine(line),
                                      icon: const Icon(Icons.remove),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        '${line.quantity}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    IconButton.filledTonal(
                                      onPressed: busy
                                          ? null
                                          : () => c.incrementLine(line),
                                      icon: const Icon(Icons.add),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: 'Remove',
                                      onPressed:
                                          busy ? null : () => c.removeLine(line.id),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: cart.lines.length,
                ),
          bottomSheet: (cart == null || cart.lines.isEmpty)
              ? null
              : _CartSummary(
                  total: '₹${cart.totalAmount.amount}',
                  onCheckout: busy ? null : () => c.checkout(context),
                ),
        );
      }),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.total, required this.onCheckout});

  final String total;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE9EEE9))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.lock),
              label: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 46),
            const SizedBox(height: 12),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to continue to checkout.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onShop,
              child: const Text('Shop now'),
            ),
          ],
        ),
      ),
    );
  }
}

