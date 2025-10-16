/// Represents a product with metadata
class Product {
  final String sku;
  final String name;
  final String? brand;
  final String? category;
  final String? store;
  final String? imageUrl;
  final double? price;
  final Map<String, String>? urls; // Store-specific URLs

  const Product({
    required this.sku,
    required this.name,
    this.brand,
    this.category,
    this.store,
    this.imageUrl,
    this.price,
    this.urls,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle different response formats from backend
    // Backend uses uppercase 'SKU' field
    final sku = json['SKU']?.toString() ??
                json['sku']?.toString() ??
                json['_id']?.toString() ?? '';

    // Product name might be in different fields
    // Backend uses uppercase 'Product' field
    final name = json['Product'] ??
                 json['name'] ??
                 json['product'] ??
                 json['productName'] ??
                 'Product $sku';

    // URLs might be in newProductUrls or newProductUrl
    Map<String, String>? urls;
    if (json['newProductUrls'] != null) {
      urls = Map<String, String>.from(json['newProductUrls'] as Map);
    } else if (json['newProductUrl'] != null) {
      urls = {'default': json['newProductUrl']};
    }

    // Parse price - backend may return empty string
    double? price;
    final priceValue = json['price'];
    if (priceValue != null && priceValue != '') {
      if (priceValue is num) {
        price = priceValue.toDouble();
      } else if (priceValue is String) {
        price = double.tryParse(priceValue);
      }
    }

    return Product(
      sku: sku,
      name: name,
      brand: json['brand'],
      category: json['category'] ?? json['productType'],
      store: json['store'] ?? json['retailer'],
      imageUrl: json['imageUrl'] ?? json['image'],
      price: price,
      urls: urls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (store != null) 'store': store,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (price != null) 'price': price,
      if (urls != null) 'urls': urls,
    };
  }

  /// Get the primary URL for this product
  String? get primaryUrl {
    if (urls == null || urls!.isEmpty) return null;

    // Try to get store-specific URL first
    if (store != null && urls!.containsKey(store)) {
      return urls![store];
    }

    // Otherwise return first available URL
    return urls!.values.first;
  }
}
