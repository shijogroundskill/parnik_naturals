import 'package:get/get.dart';

import '../../../shopify/shopify_models.dart';
import '../../../shopify/shopify_repository.dart';

class ShopController extends GetxController {
  ShopController(this._repo);

  final ShopifyRepository _repo;

  final collections = <CollectionSummary>[].obs;
  final gallery = <ProductSummary>[].obs;
  final products = <ProductSummary>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = null;
      final results = await Future.wait([
        _repo.fetchCollections(first: 8),
        _repo.fetchProductsByTag('watchbuy', first: 10),
        _repo.fetchProducts(first: 24),
      ]);
      collections.value = results[0] as List<CollectionSummary>;
      gallery.value = results[1] as List<ProductSummary>;
      products.value = results[2] as List<ProductSummary>;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

