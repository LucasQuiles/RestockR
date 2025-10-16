import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../core/auth/auth_status.dart';
import '../../core/config/backend_config.dart';
import 'auth_repository.dart';

/// Real implementation of AuthRepository
/// Communicates with the RestockR backend API
class AuthRepositoryImpl implements AuthRepository {
  final BackendConfig config;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  final _sessionController = StreamController<AuthSessionStatus>.broadcast();
  AuthSessionStatus _currentStatus = AuthSessionStatus.unknown;
  Timer? _tokenRefreshTimer;

  static const _tokenKey = 'restockr_jwt_token';

  AuthRepositoryImpl({
    required this.config,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _configureDio();
    _initialize();
  }

  void _configureDio() {
    _dio.options.baseUrl = config.apiBase.toString();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add request interceptor to inject auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getStoredToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - token expired or invalid
          if (error.response?.statusCode == 401) {
            await signOut();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _initialize() async {
    try {
      final token = await getStoredToken();

      if (token != null && token.isNotEmpty) {
        // Check if token is valid (not expired)
        if (_isTokenValid(token)) {
          _updateStatus(AuthSessionStatus.authenticated);
          _scheduleTokenRefresh(token);
        } else {
          // Token expired, clear it
          await clearToken();
          _updateStatus(AuthSessionStatus.unauthenticated);
        }
      } else {
        _updateStatus(AuthSessionStatus.unauthenticated);
      }
    } catch (e) {
      _updateStatus(AuthSessionStatus.unauthenticated);
    }
  }

  bool _isTokenValid(String token) {
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  void _scheduleTokenRefresh(String token) {
    _tokenRefreshTimer?.cancel();

    try {
      final decodedToken = JwtDecoder.decode(token);
      final exp = decodedToken['exp'] as int?;

      if (exp != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final refreshTime =
            expiryTime.subtract(Duration(minutes: config.authRefreshIntervalMinutes));
        final delay = refreshTime.difference(DateTime.now());

        if (delay.inSeconds > 0) {
          _tokenRefreshTimer = Timer(delay, () async {
            try {
              await refreshToken();
            } catch (e) {
              // Token refresh failed, sign out
              await signOut();
            }
          });
        }
      }
    } catch (e) {
      // Failed to schedule refresh, will rely on 401 interceptor
    }
  }

  void _updateStatus(AuthSessionStatus status) {
    _currentStatus = status;
    if (!_sessionController.isClosed) {
      _sessionController.add(status);
    }
  }

  @override
  Future<AuthResult> signIn(
    String username,
    String password, {
    String? parentAccount,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
          if (parentAccount != null) 'parentAccount': parentAccount,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'] as String;
        await storeToken(token);
        _updateStatus(AuthSessionStatus.authenticated);
        _scheduleTokenRefresh(token);
        return AuthResult.success(token);
      } else {
        _updateStatus(AuthSessionStatus.unauthenticated);
        return AuthResult.failure('Login failed');
      }
    } on DioException catch (e) {
      _updateStatus(AuthSessionStatus.unauthenticated);
      final errorMessage = _extractErrorMessage(e);
      return AuthResult.failure(errorMessage);
    } catch (e) {
      _updateStatus(AuthSessionStatus.unauthenticated);
      return AuthResult.failure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    _tokenRefreshTimer?.cancel();
    await clearToken();
    _updateStatus(AuthSessionStatus.unauthenticated);
  }

  @override
  Future<String> refreshToken() async {
    final currentToken = await getStoredToken();
    if (currentToken == null || currentToken.isEmpty) {
      throw Exception('No token to refresh');
    }

    try {
      // Note: The current backend doesn't have a refresh endpoint
      // For now, we'll return the existing token if it's still valid
      // In production, you'd call POST /api/auth/refresh
      if (_isTokenValid(currentToken)) {
        return currentToken;
      } else {
        throw Exception('Token expired');
      }
    } catch (e) {
      await signOut();
      rethrow;
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/me');

      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await signOut();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<AuthSessionStatus> sessionChanges() {
    return _sessionController.stream;
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> storeToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      // Failed to store token securely, handle gracefully
      rethrow;
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      // Ignore errors when clearing token
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    if (token == null || token.isEmpty) return false;
    return _isTokenValid(token);
  }

  @override
  Future<AuthResult> signInWithDiscord({String? guildId}) async {
    try {
      // Build OAuth URL
      final baseUrl = config.apiBase.toString();

      // IMPORTANT: guildId is required by the backend!
      // Without it, Discord OAuth may fail
      final guildParam = guildId != null ? '?guildId=$guildId' : '';
      final oauthUrl = '$baseUrl/api/auth/discord/mobile$guildParam';

      print('🔐 Starting Discord OAuth flow...');
      print('🔐 OAuth URL: $oauthUrl');

      // Define callback URL scheme
      // Using custom scheme 'restockr' to capture restockr://callback?token=...
      // The backend detects mobile and redirects to restockr:// instead of https://
      final callbackUrlScheme = 'restockr';

      // Launch OAuth flow with flutter_web_auth_2
      // This opens OAuth in a web view and automatically captures the callback
      final result = await FlutterWebAuth2.authenticate(
        url: oauthUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      // Debug: Print the callback URL
      print('🔐 OAuth callback URL: $result');

      // Extract token or error from callback URL
      // Backend should redirect to: restockr://callback?token=xxx (for mobile)
      // or https://restockr.app/login?token=xxx (for web)
      final uri = Uri.parse(result);
      print('🔐 Parsed URI - scheme: ${uri.scheme}, host: ${uri.host}, path: ${uri.path}');
      print('🔐 Query parameters: ${uri.queryParameters}');

      // Check for error first
      final error = uri.queryParameters['error'];
      if (error != null) {
        _updateStatus(AuthSessionStatus.unauthenticated);
        print('🔐 OAuth error: $error');
        if (error == 'unauthorized') {
          return AuthResult.failure(
            'Discord OAuth failed: unauthorized. This may happen if:\n' +
            '1. Your Discord account userType is 0 (contact admin)\n' +
            '2. Guild ID is missing or invalid\n' +
            '3. Backend passport authentication failed\n\n' +
            'Callback URL: $result',
          );
        }
        return AuthResult.failure('Discord OAuth error: $error\n\nCallback: $result');
      }

      // Extract token
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        print('🔐 Token received successfully');
        await storeToken(token);
        _updateStatus(AuthSessionStatus.authenticated);
        _scheduleTokenRefresh(token);
        return AuthResult.success(token);
      } else {
        _updateStatus(AuthSessionStatus.unauthenticated);
        return AuthResult.failure('No token received from Discord OAuth\n\nCallback: $result');
      }
    } on PlatformException catch (e) {
      _updateStatus(AuthSessionStatus.unauthenticated);
      // User cancelled the OAuth flow
      if (e.code == 'CANCELED') {
        return AuthResult.failure('Discord login cancelled');
      }
      print('🔐 PlatformException: ${e.code} - ${e.message}');
      return AuthResult.failure('Discord OAuth error: ${e.message}');
    } catch (e) {
      _updateStatus(AuthSessionStatus.unauthenticated);
      print('🔐 Exception: ${e.toString()}');
      return AuthResult.failure('Discord OAuth error: ${e.toString()}');
    }
  }

  @override
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      print('📝 Updating user preferences: $preferences');

      final response = await _dio.patch(
        '/api/me',
        data: preferences,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ User preferences updated successfully');
        return true;
      } else {
        print('❌ Failed to update preferences: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      print('❌ Preferences update error: $errorMessage');
      return false;
    } catch (e) {
      print('❌ Unexpected error updating preferences: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _sessionController.close();
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
