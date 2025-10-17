import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/backend_config.dart';
import '../restocks/restock_feed_repository_impl.dart';
import 'watchlist_repository.dart';
import 'models/watchlist_item.dart';

/// Real implementation of WatchlistRepository using backend API
class WatchlistRepositoryImpl implements WatchlistRepository {
  final BackendConfig config;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final RestockFeedRepositoryImpl? _restockFeedRepo;

  static const _tokenKey = 'restockr_jwt_token';

  WatchlistRepositoryImpl({
    required this.config,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
    RestockFeedRepositoryImpl? restockFeedRepo,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _restockFeedRepo = restockFeedRepo {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = config.apiBase.toString();
    _dio.options.connectTimeout = Duration(seconds: config.timeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: config.timeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Add auth token interceptor
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
  Future<WatchlistResult> getWatchlist() async {
    try {
      print('📋 Fetching watchlist from /api/me');
      final response = await _dio.get('/api/me');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final productSkus = (data['productSkus'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        print('📋 Watchlist loaded: ${productSkus.length} subscriptions');
        return WatchlistResult.successResult(productSkus);
      }

      print('📋 Failed to fetch watchlist: ${response.statusCode}');
      return WatchlistResult.failure(
          'Failed to fetch watchlist: ${response.statusCode}');
    } on DioException catch (e) {
      final error = _handleDioError(e);
      print('📋 Watchlist fetch error: $error');
      return WatchlistResult.failure(error);
    } catch (e) {
      print('📋 Unexpected watchlist error: $e');
      return WatchlistResult.failure('Unexpected error: $e');
    }
  }

  @override
  Future<WatchlistResult> subscribe(String sku) async {
    try {
      final response = await _dio.post('/api/subscribe/$sku');

      if (response.statusCode == 200) {
        // Endpoint returns {success: true}, need to refetch subscriptions
        final meResponse = await _dio.get('/api/me');
        if (meResponse.statusCode == 200) {
          final data = meResponse.data as Map<String, dynamic>;
          final productSkus = (data['productSkus'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          // Sync via WebSocket for real-time multi-device updates
          _restockFeedRepo?.syncWatchlistViaWebSocket(productSkus);

          return WatchlistResult.successResult(productSkus);
        }
      }

      return WatchlistResult.failure(
          'Failed to subscribe: ${response.statusCode}');
    } on DioException catch (e) {
      return WatchlistResult.failure(_handleDioError(e));
    } catch (e) {
      return WatchlistResult.failure('Unexpected error: $e');
    }
  }

  @override
  Future<WatchlistResult> unsubscribe(String sku) async {
    try {
      final response = await _dio.post('/api/unsubscribe/$sku');

      if (response.statusCode == 200) {
        // Endpoint returns {success: true}, need to refetch subscriptions
        final meResponse = await _dio.get('/api/me');
        if (meResponse.statusCode == 200) {
          final data = meResponse.data as Map<String, dynamic>;
          final productSkus = (data['productSkus'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          // Sync via WebSocket for real-time multi-device updates
          _restockFeedRepo?.syncWatchlistViaWebSocket(productSkus);

          return WatchlistResult.successResult(productSkus);
        }
      }

      return WatchlistResult.failure(
          'Failed to unsubscribe: ${response.statusCode}');
    } on DioException catch (e) {
      return WatchlistResult.failure(_handleDioError(e));
    } catch (e) {
      return WatchlistResult.failure('Unexpected error: $e');
    }
  }

  @override
  Future<bool> isSubscribed(String sku) async {
    final result = await getWatchlist();
    if (result.success) {
      return result.skus.contains(sku);
    }
    return false;
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your network.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Unauthorized. Please log in again.';
        }
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  @override
  void dispose() {
    _dio.close();
  }
}
