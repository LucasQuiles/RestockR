import 'product.dart';

/// Result wrapper for product repository operations
class ProductResult {
  final List<Product> products;
  final String? error;
  final bool success;

  const ProductResult({
    this.products = const [],
    this.error,
    required this.success,
  });

  factory ProductResult.success(List<Product> products) {
    return ProductResult(
      products: products,
      success: true,
    );
  }

  factory ProductResult.successSingle(Product product) {
    return ProductResult(
      products: [product],
      success: true,
    );
  }

  factory ProductResult.failure(String error) {
    return ProductResult(
      products: const [],
      error: error,
      success: false,
    );
  }

  /// Get a single product (for fetchProductBySku)
  Product? get product => products.isNotEmpty ? products.first : null;

  /// Check if result has products
  bool get hasProducts => products.isNotEmpty;
}
