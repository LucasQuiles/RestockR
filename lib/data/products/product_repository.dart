import 'dart:async';
import 'models/product_result.dart';

/// Repository interface for product operations
/// Provides access to product metadata and details
abstract class ProductRepository {
  /// Fetch all available products with metadata
  ///
  /// Returns ProductResult with list of products
  Future<ProductResult> fetchAllProducts();

  /// Fetch a single product by SKU
  ///
  /// Parameters:
  /// - sku: Product SKU identifier
  ///
  /// Returns ProductResult with single product or error
  Future<ProductResult> fetchProductBySku(String sku);

  /// Fetch multiple products by SKUs
  ///
  /// Parameters:
  /// - skus: List of SKU identifiers
  ///
  /// Returns ProductResult with list of matching products
  Future<ProductResult> fetchProductsBySkus(List<String> skus);

  /// Dispose resources (e.g., close HTTP client)
  void dispose();
}
