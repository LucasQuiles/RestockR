import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/backend_config.dart';
import 'history_repository.dart';
import 'models/history_result.dart';
import 'models/history_aggregation.dart';
import 'models/history_alert.dart';

/// Real implementation of HistoryRepository
/// Communicates with the RestockR backend API for historical data
class HistoryRepositoryImpl implements HistoryRepository {
  final BackendConfig config;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'restockr_jwt_token';

  HistoryRepositoryImpl({
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
  Future<HistoryResult> fetchHistory({
    required DateTime startDate,
    required DateTime endDate,
    String? sku,
    String? retailer,
    String groupBy = 'date',
    String mode = 'count',
  }) async {
    try {
      print('📊 Fetching history: $startDate to $endDate, groupBy: $groupBy, mode: $mode');

      // Build query parameters
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'groupBy': groupBy,
        'mode': mode,
      };

      if (sku != null && sku.isNotEmpty) {
        queryParams['sku'] = sku;
      }
      if (retailer != null && retailer.isNotEmpty) {
        queryParams['retailer'] = retailer;
      }

      final response = await _dio.get(
        '/api/alerts/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>?;

        if (data == null) {
          return HistoryResult.failure('No data returned from server');
        }

        final aggregations = data
            .map((item) => HistoryAggregation.fromJson(item as Map<String, dynamic>))
            .toList();

        print('📊 Fetched ${aggregations.length} history aggregations');

        return HistoryResult.successWithAggregations(aggregations);
      } else {
        return HistoryResult.failure(
          'Failed to fetch history: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      print('📊 History fetch error: $errorMessage');
      return HistoryResult.failure(errorMessage);
    } catch (e) {
      print('📊 Unexpected error: $e');
      return HistoryResult.failure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<HistoryResult> fetchHistoryDetails({
    required DateTime date,
    int? hour,
    int limit = 100,
  }) async {
    try {
      print('📊 Fetching history details for date: $date, hour: $hour');

      // Build query parameters
      final queryParams = <String, dynamic>{
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
        'limit': limit,
      };

      if (hour != null) {
        queryParams['hour'] = hour;
      }

      final response = await _dio.get(
        '/api/alerts/history/details',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>?;

        if (data == null) {
          return HistoryResult.failure('No data returned from server');
        }

        final alerts = data
            .map((item) => HistoryAlert.fromJson(item as Map<String, dynamic>))
            .toList();

        print('📊 Fetched ${alerts.length} history details');

        return HistoryResult.successWithAlerts(alerts);
      } else {
        return HistoryResult.failure(
          'Failed to fetch history details: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      print('📊 History details fetch error: $errorMessage');
      return HistoryResult.failure(errorMessage);
    } catch (e) {
      print('📊 Unexpected error: $e');
      return HistoryResult.failure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _dio.close();
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
