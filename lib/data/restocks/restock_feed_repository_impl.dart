import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/backend_config.dart';
import 'restock_feed_repository.dart';
import 'native_websocket_client.dart';
import 'models/restock_alert.dart';
import 'models/restock_feed_result.dart';

/// Real implementation of RestockFeedRepository using backend API
/// Uses native Dart WebSocket for iOS compatibility with HTTP fallback
class RestockFeedRepositoryImpl implements RestockFeedRepository {
  final BackendConfig config;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final CookieJar _cookieJar;
  NativeWebSocketClient? _wsClient;
  bool _useHttpFallback = false;

  static const _tokenKey = 'restockr_jwt_token';

  RestockFeedRepositoryImpl({
    required this.config,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
    CookieJar? cookieJar,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _cookieJar = cookieJar ?? CookieJar() {
    _configureDio();
    _initializeWebSocket();
  }

  void _initializeWebSocket() async {
    // Only initialize WebSocket if URL is configured
    if (config.wsUrl != null) {
      print('[RestockFeed] 🔌 Initializing Native WebSocket...');

      // Get auth token from secure storage
      final token = await _secureStorage.read(key: _tokenKey);
      print('[RestockFeed] 🔌 Token loaded: ${token != null ? "YES (${token.length} chars)" : "NO"}');

      if (token == null) {
        print('[RestockFeed] ⚠️ WARNING: No auth token available for WebSocket connection!');
        print('[RestockFeed] ⚠️ WebSocket connection will likely be rejected by backend');
        print('[RestockFeed] 🔄 Falling back to HTTP for reactions');
        _useHttpFallback = true;
        return;
      }

      _wsClient = NativeWebSocketClient(
        config: config,
        authToken: token,
      );

      // Connect immediately for reactions and real-time updates
      try {
        await _wsClient!.connect();
        print('[RestockFeed] 🔌 Native WebSocket connection initiated');

        // Monitor connection after 5 seconds
        Timer(Duration(seconds: 5), () {
          if (!(_wsClient?.isConnected ?? false)) {
            print('[RestockFeed] ⚠️ WebSocket not connected after 5s, enabling HTTP fallback');
            _useHttpFallback = true;
          }
        });
      } catch (e) {
        print('[RestockFeed] ❌ WebSocket connection failed: $e');
        print('[RestockFeed] 🔄 Falling back to HTTP for reactions');
        _useHttpFallback = true;
      }
    } else {
      print('[RestockFeed] ⚠️ WebSocket URL not configured (RESTOCKR_WS_URL not set)');
      print('[RestockFeed] 🔄 Using HTTP for reactions');
      _useHttpFallback = true;
    }
  }

  void _configureDio() {
    _dio.options.baseUrl = config.apiBase.toString();
    _dio.options.connectTimeout = Duration(seconds: config.timeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: config.timeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Add cookie manager to persist cookies across requests
    _dio.interceptors.add(CookieManager(_cookieJar));

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
  Future<RestockFeedResult> getRecentAlerts({int limit = 25}) async {
    try {
      final response = await _dio.get(
        '/api/alerts/recent',
        queryParameters: {'limit': limit},
        options: Options(
          headers: {
            // Auth token will be added by interceptor if available
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final alerts = data
            .map((json) => RestockAlert.fromJson(json as Map<String, dynamic>))
            .toList();

        return RestockFeedResult.success(
          alerts,
          hasMore: alerts.length >= limit,
        );
      }

      return RestockFeedResult.failure(
          'Failed to fetch alerts: ${response.statusCode}');
    } on DioException catch (e) {
      return RestockFeedResult.failure(_handleDioError(e));
    } catch (e) {
      return RestockFeedResult.failure('Unexpected error: $e');
    }
  }

  @override
  Future<bool> submitReaction(String alertId, bool isPositive) async {
    // Try WebSocket first if available and connected
    if (_wsClient != null && _wsClient!.isConnected && !_useHttpFallback) {
      return _wsClient!.submitReaction(alertId, isPositive);
    }

    // HTTP fallback for reactions
    print('[RestockFeed] 🔄 Using HTTP fallback for reaction');
    try {
      final response = await _dio.post(
        '/api/alerts/$alertId/react',
        data: {
          'type': isPositive ? 'yes' : 'no',
        },
      );

      if (response.statusCode == 200) {
        print('[RestockFeed] ✅ Reaction submitted via HTTP');
        return true;
      }

      print('[RestockFeed] ❌ HTTP reaction failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('[RestockFeed] ❌ HTTP reaction error: ${_handleDioError(e)}');
      return false;
    } catch (e) {
      print('[RestockFeed] ❌ Unexpected reaction error: $e');
      return false;
    }
  }

  @override
  Stream<RestockAlert>? get alertStream {
    if (_wsClient == null) {
      print('[RestockFeed] WebSocket not configured (RESTOCKR_WS_URL not set)');
      return null;
    }

    return _wsClient!.alertStream;
  }

  /// Sync watchlist to backend via WebSocket for real-time updates
  void syncWatchlistViaWebSocket(List<String> skus) {
    if (_wsClient == null) {
      print('[RestockFeed] Cannot sync watchlist: WebSocket not configured');
      return;
    }

    _wsClient!.syncWatchlist(skus);
  }

  /// Listen for watchlist updates from WebSocket
  void onWatchlistUpdate(Function(List<String>) callback) {
    if (_wsClient == null) {
      print('[RestockFeed] Cannot listen for watchlist updates: WebSocket not configured');
      return;
    }

    _wsClient!.onWatchlistUpdate(callback);
  }

  /// Expose WebSocket client for repository integration
  NativeWebSocketClient? get wsClient => _wsClient;

  /// Check if using HTTP fallback mode
  bool get isUsingHttpFallback => _useHttpFallback;

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your network.';
      case DioExceptionType.badResponse:
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
    _wsClient?.dispose();
    _dio.close();
  }
}
