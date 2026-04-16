class Money {
  final String amount;
  final String currencyCode;

  const Money({required this.amount, required this.currencyCode});

  factory Money.fromJson(Map<String, dynamic> json) => Money(
        amount: (json['amount'] ?? '').toString(),
        currencyCode: (json['currencyCode'] ?? '').toString(),
      );
}

class ShopifyImage {
  final String url;
  final String? altText;

  const ShopifyImage({required this.url, this.altText});

  factory ShopifyImage.fromJson(Map<String, dynamic> json) => ShopifyImage(
        url: (json['url'] ?? '').toString(),
        altText: json['altText']?.toString(),
      );
}

class ProductSummary {
  final String id;
  final String handle;
  final String title;
  final String? description;
  final ShopifyImage? featuredImage;
  final Money minPrice;

  const ProductSummary({
    required this.id,
    required this.handle,
    required this.title,
    required this.description,
    required this.featuredImage,
    required this.minPrice,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    final price = (json['priceRangeV2']?['minVariantPrice'] ??
        json['priceRange']?['minVariantPrice']) as Map<String, dynamic>?;
    return ProductSummary(
      id: (json['id'] ?? '').toString(),
      handle: (json['handle'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      featuredImage: (json['featuredImage'] is Map<String, dynamic>)
          ? ShopifyImage.fromJson(json['featuredImage'] as Map<String, dynamic>)
          : null,
      minPrice: Money.fromJson(price ?? const <String, dynamic>{}),
    );
  }
}

class ProductVariant {
  final String id;
  final String title;
  final bool availableForSale;
  final Money price;

  const ProductVariant({
    required this.id,
    required this.title,
    required this.availableForSale,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        availableForSale: json['availableForSale'] == true,
        price: Money.fromJson((json['price'] as Map<String, dynamic>?) ?? const {}),
      );
}

class ProductDetails {
  final String id;
  final String handle;
  final String title;
  final String? description;
  final List<ShopifyImage> images;
  final List<ProductVariant> variants;

  const ProductDetails({
    required this.id,
    required this.handle,
    required this.title,
    required this.description,
    required this.images,
    required this.variants,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    final imagesEdges = (json['images']?['edges'] as List<dynamic>? ?? const []);
    final variantEdges =
        (json['variants']?['edges'] as List<dynamic>? ?? const []);

    return ProductDetails(
      id: (json['id'] ?? '').toString(),
      handle: (json['handle'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      images: imagesEdges
          .map((e) => e as Map<String, dynamic>)
          .map((e) => e['node'] as Map<String, dynamic>)
          .map(ShopifyImage.fromJson)
          .toList(growable: false),
      variants: variantEdges
          .map((e) => e as Map<String, dynamic>)
          .map((e) => e['node'] as Map<String, dynamic>)
          .map(ProductVariant.fromJson)
          .toList(growable: false),
    );
  }
}

class CollectionSummary {
  final String id;
  final String handle;
  final String title;
  final ShopifyImage? image;

  const CollectionSummary({
    required this.id,
    required this.handle,
    required this.title,
    required this.image,
  });

  factory CollectionSummary.fromJson(Map<String, dynamic> json) =>
      CollectionSummary(
        id: (json['id'] ?? '').toString(),
        handle: (json['handle'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        image: (json['image'] is Map<String, dynamic>)
            ? ShopifyImage.fromJson(json['image'] as Map<String, dynamic>)
            : null,
      );
}

class ShopifyPage {
  final String id;
  final String handle;
  final String title;
  final String bodyHtml;

  const ShopifyPage({
    required this.id,
    required this.handle,
    required this.title,
    required this.bodyHtml,
  });

  factory ShopifyPage.fromJson(Map<String, dynamic> json) => ShopifyPage(
        id: (json['id'] ?? '').toString(),
        handle: (json['handle'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        bodyHtml: (json['body'] ?? '').toString(),
      );
}

class CustomerToken {
  final String accessToken;
  final String expiresAt;

  const CustomerToken({required this.accessToken, required this.expiresAt});
}

class OrderSummary {
  final String id;
  final String name;
  final int orderNumber;
  final String processedAt;
  final String? financialStatus;
  final String? fulfillmentStatus;
  final String? statusUrl;
  final Money totalPrice;

  const OrderSummary({
    required this.id,
    required this.name,
    required this.orderNumber,
    required this.processedAt,
    required this.financialStatus,
    required this.fulfillmentStatus,
    required this.statusUrl,
    required this.totalPrice,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        orderNumber:
            (json['orderNumber'] as num?)?.toInt() ?? (json['number'] as num?)?.toInt() ?? 0,
        processedAt: (json['processedAt'] ?? '').toString(),
        financialStatus: json['financialStatus']?.toString(),
        fulfillmentStatus: json['fulfillmentStatus']?.toString(),
        statusUrl: (json['statusUrl'] ?? json['statusPageUrl'])?.toString(),
        totalPrice:
            Money.fromJson((json['totalPrice'] as Map<String, dynamic>?) ?? const {}),
      );
}

class CartLine {
  final String id;
  final int quantity;
  final ProductSummary product;
  final ProductVariant variant;

  const CartLine({
    required this.id,
    required this.quantity,
    required this.product,
    required this.variant,
  });
}

class CartState {
  final String id;
  final String checkoutUrl;
  final List<CartLine> lines;
  final Money totalAmount;

  const CartState({
    required this.id,
    required this.checkoutUrl,
    required this.lines,
    required this.totalAmount,
  });
}

