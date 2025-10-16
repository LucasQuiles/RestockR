import 'dart:async';
import 'product_repository.dart';
import 'models/product_result.dart';
import 'models/product.dart';

/// Mock implementation of ProductRepository for development and testing
class MockProductRepository implements ProductRepository {
  // Mock product database
  static final List<Product> _mockProducts = [
    Product(
      sku: '12315494',
      name: 'PlayStation 5 Console',
      brand: 'Sony',
      category: 'Gaming',
      store: 'Target',
      imageUrl: 'https://via.placeholder.com/150',
      price: 499.99,
      urls: {'Target': 'https://target.com/ps5'},
    ),
    Product(
      sku: '87654321',
      name: 'Xbox Series X',
      brand: 'Microsoft',
      category: 'Gaming',
      store: 'BestBuy',
      imageUrl: 'https://via.placeholder.com/150',
      price: 499.99,
      urls: {'BestBuy': 'https://bestbuy.com/xbox'},
    ),
    Product(
      sku: '11223344',
      name: 'Nintendo Switch OLED',
      brand: 'Nintendo',
      category: 'Gaming',
      store: 'Amazon',
      imageUrl: 'https://via.placeholder.com/150',
      price: 349.99,
      urls: {'Amazon': 'https://amazon.com/switch'},
    ),
    Product(
      sku: '55667788',
      name: 'Apple AirPods Pro (2nd Gen)',
      brand: 'Apple',
      category: 'Electronics',
      store: 'Target',
      price: 249.99,
    ),
    Product(
      sku: '99887766',
      name: 'Samsung Galaxy S24 Ultra',
      brand: 'Samsung',
      category: 'Electronics',
      store: 'BestBuy',
      price: 1199.99,
    ),
  ];

  @override
  Future<ProductResult> fetchAllProducts() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    print('📦 Mock: Fetching all products (${_mockProducts.length} items)');

    return ProductResult.success(List.from(_mockProducts));
  }

  @override
  Future<ProductResult> fetchProductBySku(String sku) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    print('📦 Mock: Fetching product: $sku');

    final product = _mockProducts.firstWhere(
      (p) => p.sku == sku,
      orElse: () => Product(
        sku: sku,
        name: 'Mock Product $sku',
        category: 'Unknown',
        price: 99.99,
      ),
    );

    return ProductResult.successSingle(product);
  }

  @override
  Future<ProductResult> fetchProductsBySkus(List<String> skus) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 400));

    print('📦 Mock: Fetching ${skus.length} products');

    final products = skus.map((sku) {
      return _mockProducts.firstWhere(
        (p) => p.sku == sku,
        orElse: () => Product(
          sku: sku,
          name: 'Mock Product $sku',
          category: 'Unknown',
          price: 99.99,
        ),
      );
    }).toList();

    return ProductResult.success(products);
  }

  @override
  void dispose() {
    // No resources to dispose in mock
  }
}
