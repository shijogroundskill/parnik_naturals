import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../account/controllers/account_controller.dart';
import '../../../shopify/shopify_models.dart';

class TrackOrderView extends StatelessWidget {
  const TrackOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AccountController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
        actions: [
          Obx(() {
            if (!c.isSignedIn) return const SizedBox.shrink();
            return TextButton(
              onPressed: c.isBusy.value ? null : c.signOut,
              child: const Text('Sign out'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (!c.isSignedIn) {
          return _SignedOut(
            onSignIn: () async {
              try {
                await c.signIn(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(c.error.value ?? e.toString()),
                  ),
                );
              }
            },
          );
        }

        final who = (c.displayName.value ?? '').isNotEmpty
            ? c.displayName.value!
            : (c.email.value ?? '');

        if (c.isBusy.value && c.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.error.value != null && c.orders.isEmpty) {
          return _ErrorState(message: c.error.value!, onRetry: c.refreshOrders);
        }

        if (c.orders.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        final fmt = DateFormat('dd MMM yyyy');
        return RefreshIndicator(
          onRefresh: c.refreshOrders,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            itemBuilder: (context, i) {
              final o = c.orders[i];
              if (i == 0 && who.isNotEmpty) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE9EEE9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Signed in as $who',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _OrderTile(o: o, fmt: fmt),
                  ],
                );
              }
              return _OrderTile(o: o, fmt: fmt);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: c.orders.length,
          ),
        );
      }),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.o, required this.fmt});

  final OrderSummary o;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(o.processedAt);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEE9)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (dt != null) fmt.format(dt),
                    if ((o.financialStatus ?? '').isNotEmpty) o.financialStatus!,
                    if ((o.fulfillmentStatus ?? '').isNotEmpty)
                      o.fulfillmentStatus!,
                  ].join(' • '),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '₹${o.totalPrice.amount}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

        // (rest of file unchanged)

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onSignIn});
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 46),
            const SizedBox(height: 12),
            Text(
              'Sign in to track orders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders are linked to your customer account on Shopify.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onSignIn, child: const Text('Sign in')),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

