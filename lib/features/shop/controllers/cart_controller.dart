import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shopify/shopify_models.dart';
import '../../../shopify/shopify_repository.dart';
import '../../checkout/views/checkout_webview.dart';

class CartController extends GetxController {
  CartController(this._repo);

  final ShopifyRepository _repo;

  final cart = Rxn<CartState>();
  final isBusy = false.obs;
  final error = RxnString();

  Future<void> addVariant(String variantId, {int quantity = 1}) async {
    try {
      isBusy.value = true;
      error.value = null;

      final current = cart.value;
      if (current == null) {
        cart.value = await _repo.createCart(
          variantId: variantId,
          quantity: quantity,
        );
      } else {
        cart.value = await _repo.addToCart(
          cartId: current.id,
          variantId: variantId,
          quantity: quantity,
        );
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> incrementLine(CartLine line) async {
    final current = cart.value;
    if (current == null) return;
    await _updateLine(line.id, line.quantity + 1);
  }

  Future<void> decrementLine(CartLine line) async {
    final current = cart.value;
    if (current == null) return;
    final nextQty = line.quantity - 1;
    if (nextQty <= 0) {
      await removeLine(line.id);
      return;
    }
    await _updateLine(line.id, nextQty);
  }

  Future<void> removeLine(String lineId) async {
    final current = cart.value;
    if (current == null) return;
    try {
      isBusy.value = true;
      error.value = null;
      cart.value = await _repo.removeLine(cartId: current.id, lineId: lineId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _updateLine(String lineId, int quantity) async {
    final current = cart.value;
    if (current == null) return;
    try {
      isBusy.value = true;
      error.value = null;
      cart.value = await _repo.updateLine(
        cartId: current.id,
        lineId: lineId,
        quantity: quantity,
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isBusy.value = false;
    }
  }

  void clearCart() {
    cart.value = null;
  }

  Future<void> checkout(BuildContext context) async {
    final url = cart.value?.checkoutUrl ?? '';
    if (url.isEmpty) return;
    final uri = Uri.parse(url);

    if (kIsWeb) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    final ok = await Get.to<bool>(() => CheckoutWebView(checkoutUrl: url));
    if (ok == true) {
      clearCart();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully')),
        );
      }
    }
  }
}

