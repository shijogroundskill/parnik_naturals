import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shopify/shopify_models.dart';
import '../../../shopify/shopify_repository.dart';
import '../controllers/cart_controller.dart';

class ShopProductView extends StatefulWidget {
  const ShopProductView({super.key, required this.handle});

  final String handle;

  @override
  State<ShopProductView> createState() => _ShopProductViewState();
}

class _ShopProductViewState extends State<ShopProductView> {
  ProductDetails? _product;
  String? _error;
  bool _loading = true;
  int _variantIndex = 0;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final repo = Get.find<ShopifyRepository>();
      final p = await repo.fetchProductByHandle(widget.handle);
      setState(() {
        _product = p;
        _variantIndex = 0;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 42),
                const SizedBox(height: 10),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final product = _product!;
    final variant = product.variants.isNotEmpty
        ? product.variants[_variantIndex.clamp(0, product.variants.length - 1)]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: product.images.isEmpty
                  ? Container(color: const Color(0xFFF1F4F1))
                  : CachedNetworkImage(
                      imageUrl: product.images.first.url,
                      fit: BoxFit.cover,
                      placeholder: (context, _) =>
                          Container(color: const Color(0xFFF1F4F1)),
                      errorWidget: (context, _, __) =>
                          Container(color: const Color(0xFFF1F4F1)),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                variant == null ? '' : '₹${variant.price.amount}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
              ),
              const Spacer(),
              if (variant != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (variant.availableForSale
                            ? cs.primary
                            : Colors.grey)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    variant.availableForSale ? 'In stock' : 'Sold out',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: variant.availableForSale
                              ? cs.primary
                              : Colors.black54,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (product.description != null && product.description!.isNotEmpty) ...[
            AnimatedCrossFade(
              firstChild: Text(
                product.description!,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black87, height: 1.35),
              ),
              secondChild: Text(
                product.description!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black87, height: 1.35),
              ),
              crossFadeState: _descExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _descExpanded = !_descExpanded),
                child: Text(_descExpanded ? 'Read less' : 'Read more'),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (product.variants.length > 1) ...[
            Text(
              'Choose option',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(product.variants.length, (i) {
                final v = product.variants[i];
                final selected = i == _variantIndex;
                return ChoiceChip(
                  selected: selected,
                  label: Text(v.title),
                  onSelected: (_) => setState(() => _variantIndex = i),
                );
              }),
            ),
            const SizedBox(height: 18),
          ],
          Obx(() {
            final busy = Get.find<CartController>().isBusy.value;
            return FilledButton.icon(
              onPressed: (variant == null || !variant.availableForSale || busy)
                  ? null
                  : () async {
                      await Get.find<CartController>().addVariant(variant.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      }
                    },
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_shopping_cart),
              label: const Text('Add to cart'),
            );
          }),
        ],
      ),
    );
  }
}

