import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/backend_config.dart';
import 'restock_feed_repository.dart';
import 'restock_feed_ws_client.dart';
import 'models/restock_alert.dart';
import 'models/restock_feed_result.dart';

/// Real implementation of RestockFeedRepository using backend API
class RestockFeedRepositoryImpl implements RestockFeedRepository {
  final BackendConfig config;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final CookieJar _cookieJar;
  RestockFeedWSClient? _wsClient;

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
      // Get auth token from secure storage
      final token = await _secureStorage.read(key: _tokenKey);

      // Get cookies from cookie jar for WebSocket connection
      final cookies = await _cookieJar.loadForRequest(config.apiBase);
      print('[RestockFeed] Loaded ${cookies.length} cookies for WebSocket');

      _wsClient = RestockFeedWSClient(
        config: config,
        authToken: token,
        cookies: cookies,
      );
      // Connect immediately for reactions and real-time updates
      _wsClient!.connect();
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
    // Reactions are sent via WebSocket, not HTTP
    if (_wsClient == null) {
      print('[RestockFeed] Cannot submit reaction: WebSocket not configured');
      return false;
    }

    return _wsClient!.submitReaction(alertId, isPositive);
  }

  @override
  Stream<RestockAlert>? get alertStream {
    if (_wsClient == null) {
      print('[RestockFeed] WebSocket not configured (RESTOCKR_WS_URL not set)');
      return null;
    }

    return _wsClient!.alertStream;
  }

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
