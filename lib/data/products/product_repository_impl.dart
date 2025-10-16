import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/backend_config.dart';
import 'product_repository.dart';
import 'models/product_result.dart';
import 'models/product.dart';

/// Real implementation of ProductRepository
/// Communicates with the RestockR backend API for product data
class ProductRepositoryImpl implements ProductRepository {
  final BackendConfig config;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Cache for products to avoid repeated API calls
  final Map<String, Product> _productCache = {};
  DateTime? _lastFullFetch;

  static const _tokenKey = 'restockr_jwt_token';

  ProductRepositoryImpl({
    required this.config,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = config.apiBase.toString();
    _dio.options.connectTimeout = Duration(seconds: config.timeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: config.timeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add request interceptor to inject auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: _tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  @override
  Future<ProductResult> fetchAllProducts() async {
    try {
      // Check if we have a recent cache (< 5 minutes old)
      if (_lastFullFetch != null &&
          DateTime.now().difference(_lastFullFetch!) < Duration(minutes: 5) &&
          _productCache.isNotEmpty) {
        print('📦 Using cached products (${_productCache.length} items)');
        return ProductResult.success(_productCache.values.toList());
      }

      print('📦 Fetching all products from API');

      final response = await _dio.get('/api/skus');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>?;

        if (data == null) {
          return ProductResult.failure('No data returned from server');
        }

        final products = data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        // Update cache
        _productCache.clear();
        for (final product in products) {
          _productCache[product.sku] = product;
        }
        _lastFullFetch = DateTime.now();

        print('📦 Fetched ${products.length} products');

        return ProductResult.success(products);
      } else {
        return ProductResult.failure(
          'Failed to fetch products: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      print('📦 Products fetch error: $errorMessage');
      return ProductResult.failure(errorMessage);
    } catch (e) {
      print('📦 Unexpected error: $e');
      return ProductResult.failure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ProductResult> fetchProductBySku(String sku) async {
    try {
      // Check cache first
      if (_productCache.containsKey(sku)) {
        print('📦 Using cached product: $sku');
        return ProductResult.successSingle(_productCache[sku]!);
      }

      print('📦 Fetching product: $sku');

      // If not in cache, fetch all products (backend doesn't have single SKU endpoint)
      final result = await fetchAllProducts();

      if (result.success) {
        final product = result.products.firstWhere(
          (p) => p.sku == sku,
          orElse: () => Product(
            sku: sku,
            name: 'Product $sku',
          ),
        );

        return ProductResult.successSingle(product);
      }

      return result;
    } catch (e) {
      print('📦 Error fetching product $sku: $e');
      return ProductResult.failure('Failed to fetch product: ${e.toString()}');
    }
  }

  @override
  Future<ProductResult> fetchProductsBySkus(List<String> skus) async {
    try {
      // Check how many are in cache
      final cached = skus.where((sku) => _productCache.containsKey(sku)).toList();
      final missing = skus.where((sku) => !_productCache.containsKey(sku)).toList();

      if (missing.isEmpty) {
        print('📦 All ${skus.length} products in cache');
        final products = skus.map((sku) => _productCache[sku]!).toList();
        return ProductResult.success(products);
      }

      print('📦 Fetching products: ${cached.length} cached, ${missing.length} missing');

      // Fetch all products to update cache
      final result = await fetchAllProducts();

      if (result.success) {
        final products = skus.map((sku) {
          return _productCache[sku] ?? Product(sku: sku, name: 'Product $sku');
        }).toList();

        return ProductResult.success(products);
      }

      return result;
    } catch (e) {
      print('📦 Error fetching products: $e');
      return ProductResult.failure('Failed to fetch products: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _dio.close();
    _productCache.clear();
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      try {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        if (data is Map && data.containsKey('error')) {
          return data['error'];
        }
      } catch (_) {}
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Network error';
    }
  }
}
