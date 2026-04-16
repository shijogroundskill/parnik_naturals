import 'shopify_client.dart';
import 'shopify_models.dart';
import 'shopify_queries.dart';

class ShopifyRepository {
  ShopifyRepository(this._client);

  final ShopifyClient _client;

  Future<List<CollectionSummary>> fetchCollections({int first = 10}) async {
    final data = await _client.query(
      ShopifyQueries.collections,
      variables: <String, dynamic>{'first': first},
    );
    final edges =
        (data['collections']?['edges'] as List<dynamic>? ?? const <dynamic>[]);
    return edges
        .map((e) => e as Map<String, dynamic>)
        .map((e) => e['node'] as Map<String, dynamic>)
        .map(CollectionSummary.fromJson)
        .toList(growable: false);
  }

  Future<List<ProductSummary>> fetchProducts({int first = 20}) async {
    final data = await _client.query(
      ShopifyQueries.products,
      variables: <String, dynamic>{'first': first, 'after': null},
    );
    final edges =
        (data['products']?['edges'] as List<dynamic>? ?? const <dynamic>[]);
    return edges
        .map((e) => e as Map<String, dynamic>)
        .map((e) => e['node'] as Map<String, dynamic>)
        .map(ProductSummary.fromJson)
        .toList(growable: false);
  }

  Future<List<ProductSummary>> fetchProductsByTag(
    String tag, {
    int first = 12,
  }) async {
    final data = await _client.query(
      ShopifyQueries.productsByTag,
      variables: <String, dynamic>{'first': first, 'query': 'tag:$tag'},
    );
    final edges =
        (data['products']?['edges'] as List<dynamic>? ?? const <dynamic>[]);
    return edges
        .map((e) => e as Map<String, dynamic>)
        .map((e) => e['node'] as Map<String, dynamic>)
        .map(ProductSummary.fromJson)
        .toList(growable: false);
  }

  Future<ShopifyPage> fetchPageByHandle(String handle) async {
    final data = await _client.query(
      ShopifyQueries.pageByHandle,
      variables: <String, dynamic>{'handle': handle},
    );
    final page = data['pageByHandle'];
    if (page is! Map<String, dynamic>) {
      throw StateError('Page not found for handle: $handle');
    }
    return ShopifyPage.fromJson(page);
  }

  Future<CustomerToken> customerLogin({
    required String email,
    required String password,
  }) async {
    final data = await _client.query(
      ShopifyQueries.customerAccessTokenCreate,
      variables: <String, dynamic>{
        'input': {'email': email, 'password': password},
      },
    );
    final payload = data['customerAccessTokenCreate'] as Map<String, dynamic>?;
    if (payload == null) throw StateError('Unexpected login payload');

    final errs = payload['customerUserErrors'] as List<dynamic>? ?? const [];
    if (errs.isNotEmpty) {
      throw StateError('Login error: $errs');
    }

    final tok = payload['customerAccessToken'] as Map<String, dynamic>?;
    if (tok == null) throw StateError('Missing access token');

    return CustomerToken(
      accessToken: (tok['accessToken'] ?? '').toString(),
      expiresAt: (tok['expiresAt'] ?? '').toString(),
    );
  }

  Future<void> customerLogout(String accessToken) async {
    await _client.query(
      ShopifyQueries.customerAccessTokenDelete,
      variables: <String, dynamic>{'customerAccessToken': accessToken},
    );
  }

  Future<List<OrderSummary>> fetchCustomerOrders({
    required String accessToken,
    int first = 20,
  }) async {
    final data = await _client.query(
      ShopifyQueries.customerOrders,
      variables: <String, dynamic>{
        'customerAccessToken': accessToken,
        'first': first,
      },
    );
    final customer = data['customer'];
    if (customer is! Map<String, dynamic>) {
      throw StateError('Not signed in (or customer access token invalid)');
    }

    final edges =
        (customer['orders']?['edges'] as List<dynamic>? ?? const <dynamic>[]);
    return edges
        .map((e) => e as Map<String, dynamic>)
        .map((e) => e['node'] as Map<String, dynamic>)
        .map(OrderSummary.fromJson)
        .toList(growable: false);
  }

  Future<ProductDetails> fetchProductByHandle(String handle) async {
    final data = await _client.query(
      ShopifyQueries.productByHandle,
      variables: <String, dynamic>{'handle': handle},
    );
    final prod = data['productByHandle'];
    if (prod is! Map<String, dynamic>) {
      throw StateError('Product not found for handle: $handle');
    }
    return ProductDetails.fromJson(prod);
  }

  Future<CartState> createCart({required String variantId, int quantity = 1}) {
    return _cartMutation(
      ShopifyQueries.cartCreate,
      variables: <String, dynamic>{
        'lines': [
          {'merchandiseId': variantId, 'quantity': quantity},
        ],
      },
    );
  }

  Future<CartState> getCart(String cartId) async {
    final data = await _client.query(
      ShopifyQueries.cartGet,
      variables: <String, dynamic>{'id': cartId},
    );
    final cart = data['cart'];
    if (cart is! Map<String, dynamic>) {
      throw StateError('Cart not found');
    }
    return _parseCart(cart);
  }

  Future<CartState> addToCart({
    required String cartId,
    required String variantId,
    int quantity = 1,
  }) {
    return _cartMutation(
      ShopifyQueries.cartLinesAdd,
      variables: <String, dynamic>{
        'cartId': cartId,
        'lines': [
          {'merchandiseId': variantId, 'quantity': quantity},
        ],
      },
    );
  }

  Future<CartState> updateLine({
    required String cartId,
    required String lineId,
    required int quantity,
  }) {
    return _cartMutation(
      ShopifyQueries.cartLinesUpdate,
      variables: <String, dynamic>{
        'cartId': cartId,
        'lines': [
          {'id': lineId, 'quantity': quantity},
        ],
      },
    );
  }

  Future<CartState> removeLine({
    required String cartId,
    required String lineId,
  }) {
    return _cartMutation(
      ShopifyQueries.cartLinesRemove,
      variables: <String, dynamic>{
        'cartId': cartId,
        'lineIds': [lineId],
      },
    );
  }

  Future<CartState> _cartMutation(
    String doc, {
    required Map<String, dynamic> variables,
  }) async {
    final data = await _client.query(doc, variables: variables);
    final rootKey = data.keys.firstWhere((k) => k.startsWith('cart'));
    final payload = data[rootKey] as Map<String, dynamic>?;
    if (payload == null) throw StateError('Unexpected cart payload');

    final userErrors = payload['userErrors'] as List<dynamic>? ?? const [];
    if (userErrors.isNotEmpty) {
      throw StateError('Cart error: $userErrors');
    }

    final cart = payload['cart'];
    if (cart is! Map<String, dynamic>) throw StateError('Cart missing');
    return _parseCart(cart);
  }

  CartState _parseCart(Map<String, dynamic> cart) {
    final edges =
        (cart['lines']?['edges'] as List<dynamic>? ?? const <dynamic>[]);
    final lines = <CartLine>[];

    for (final e in edges) {
      final node = (e as Map<String, dynamic>)['node'] as Map<String, dynamic>;
      final merch = node['merchandise'] as Map<String, dynamic>;
      final product = merch['product'] as Map<String, dynamic>;

      lines.add(
        CartLine(
          id: (node['id'] ?? '').toString(),
          quantity: (node['quantity'] as num?)?.toInt() ?? 1,
          product: ProductSummary.fromJson(product),
          variant: ProductVariant.fromJson(merch),
        ),
      );
    }

    final total =
        (cart['cost']?['totalAmount'] as Map<String, dynamic>?) ?? const {};

    return CartState(
      id: (cart['id'] ?? '').toString(),
      checkoutUrl: (cart['checkoutUrl'] ?? '').toString(),
      lines: lines,
      totalAmount: Money.fromJson(total),
    );
  }
}

