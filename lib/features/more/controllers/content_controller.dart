import 'package:get/get.dart';

import '../../../shopify/shopify_models.dart';
import '../../../shopify/shopify_repository.dart';

class ContentController extends GetxController {
  ContentController(this._repo);

  final ShopifyRepository _repo;

  final _cache = <String, ShopifyPage>{}.obs;
  final isLoading = false.obs;
  final error = RxnString();

  ShopifyPage? cached(String handle) => _cache[handle];

  Future<ShopifyPage> getPage(String handle) async {
    final cached = _cache[handle];
    if (cached != null) return cached;

    try {
      isLoading.value = true;
      error.value = null;
      final page = await _repo.fetchPageByHandle(handle);
      _cache[handle] = page;
      return page;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

