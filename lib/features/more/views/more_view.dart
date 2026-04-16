import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'shopify_page_view.dart';
import 'track_order_view.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          _Section(
            title: 'Company',
            children: [
              _Item(
                icon: Icons.info_outline,
                title: 'About Us',
                handle: 'about-us',
              ),
              _NavItem(
                icon: Icons.local_shipping_outlined,
                title: 'Track order',
                onTap: () => Get.to(() => const TrackOrderView()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Policies',
            children: const [
              _Item(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                handle: 'privacy-policy',
              ),
              _Item(
                icon: Icons.article_outlined,
                title: 'Terms and Conditions',
                handle: 'terms-and-condition',
              ),
              _Item(
                icon: Icons.cancel_presentation_outlined,
                title: 'Cancellation Policy',
                handle: 'cancellation-policy',
              ),
              _Item(
                icon: Icons.assignment_return_outlined,
                title: 'Return Policy',
                handle: 'return-policy',
              ),
              _Item(
                icon: Icons.local_shipping_outlined,
                title: 'Shipping Policy',
                handle: 'shipping-policy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.title, required this.handle});

  final IconData icon;
  final String title;
  final String handle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.to(() => ShopifyPageView(handle: handle, fallbackTitle: title)),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

