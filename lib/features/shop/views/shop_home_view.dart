import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shopify/shopify_models.dart';
import '../controllers/nav_controller.dart';
import '../controllers/shop_controller.dart';
import 'shop_product_view.dart';

class ShopHomeView extends StatefulWidget {
  const ShopHomeView({super.key});

  @override
  State<ShopHomeView> createState() => _ShopHomeViewState();
}

class _ShopHomeViewState extends State<ShopHomeView> {
  final _bestSellersKey = GlobalKey();

  Future<void> _scrollToBestSellers() async {
    final nav = Get.find<NavController>();
    nav.goToShop();

    final ctx = _bestSellersKey.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShopController>();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Image.asset(
              'assets/images/parnik-logo.png',
              height: 28,
              fit: BoxFit.contain,
            ),
            actions: [
              IconButton(
                tooltip: 'Reload',
                onPressed: c.load,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 6),
            ],
          ),
          Obx(() {
            if (c.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (c.error.value != null) {
              return SliverFillRemaining(
                child: _ErrorState(message: c.error.value!),
              );
            }
            final items = c.products;
            return SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  const SizedBox(height: 10),
                  _HomeCarousel(
                    items: c.collections,
                    onShopNow: _scrollToBestSellers,
                  ),
                  const SizedBox(height: 16),
                  if (c.gallery.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Watch & Buy',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            'From Shopify tag: watchbuy',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.black45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 164,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) =>
                            _GalleryCard(item: c.gallery[index]),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: c.gallery.length,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Padding(
                    key: _bestSellersKey,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Best sellers',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) =>
                          _ProductCard(item: items[index]),
                      itemCount: items.length,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HomeCarousel extends StatefulWidget {
  const _HomeCarousel({required this.items, required this.onShopNow});

  final List<CollectionSummary> items;
  final VoidCallback onShopNow;

  @override
  State<_HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<_HomeCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _idx = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = widget.items.where((e) => (e.image?.url ?? '').isNotEmpty).toList();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE9EEE9)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add images to Shopify Collections to show banners here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _idx = i),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final it = items[index];
              final url = it.image!.url;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: widget.onShopNow,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE9EEE9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, _) =>
                                Container(color: const Color(0xFFF1F4F1)),
                            errorWidget: (context, _, __) =>
                                Container(color: const Color(0xFFF1F4F1)),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 12,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    it.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.9),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  onPressed: widget.onShopNow,
                                  child: Text(
                                    'Shop now',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: active ? 22 : 8,
              decoration: BoxDecoration(
                color: active ? cs.primary : const Color(0xFFD7DED7),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.item});
  final ProductSummary item;

  @override
  Widget build(BuildContext context) {
    final url = item.featuredImage?.url ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Get.to(() => ShopProductView(handle: item.handle)),
      child: Ink(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9EEE9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              url.isEmpty
                  ? Container(color: const Color(0xFFF1F4F1))
                  : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});

  final ProductSummary item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imgUrl = item.featuredImage?.url ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.to(() => ShopProductView(handle: item.handle)),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EEE9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Container(
                      color: const Color(0xFFF1F4F1),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: imgUrl.isEmpty
                          ? const SizedBox.shrink()
                          : CachedNetworkImage(
                              imageUrl: imgUrl,
                              fit: BoxFit.contain,
                              fadeInDuration:
                                  const Duration(milliseconds: 120),
                              placeholder: (context, _) =>
                                  const SizedBox.shrink(),
                              errorWidget: (context, _, __) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    children: [
                      Text(
                        '₹${item.minPrice.amount}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'View',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 44),
            const SizedBox(height: 12),
            Text(
              'Couldn’t load products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: Get.find<ShopController>().load,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

