import 'dart:async';
import '../../core/auth/auth_status.dart';

/// Authentication result containing token and user data
class AuthResult {
  final String token;
  final String? error;
  final bool success;

  const AuthResult({
    required this.token,
    this.error,
    required this.success,
  });

  factory AuthResult.success(String token) =>
      AuthResult(token: token, success: true);

  factory AuthResult.failure(String error) =>
      AuthResult(token: '', error: error, success: false);
}

/// User profile data
class UserProfile {
  final String id;
  final String username;
  final String? email;
  final int userType;
  final List<String> productSkus;
  final bool restockBell;
  final List<ParentAccountInfo> parentAccounts;
  final int minimumQty;
  final Map<String, bool> newSku;
  final bool autoOpenPcQueue;
  final int pcQueueDelaySeconds;
  final int reopenCooldown;

  const UserProfile({
    required this.id,
    required this.username,
    this.email,
    required this.userType,
    this.productSkus = const [],
    this.restockBell = true,
    this.parentAccounts = const [],
    this.minimumQty = 1,
    this.newSku = const {},
    this.autoOpenPcQueue = false,
    this.pcQueueDelaySeconds = 0,
    this.reopenCooldown = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      userType: json['userType'] ?? 0,
      productSkus: (json['productSkus'] as List?)?.cast<String>() ?? [],
      restockBell: json['restockBell'] ?? true,
      parentAccounts: (json['parentAccount'] as List?)
              ?.map((p) => ParentAccountInfo.fromJson(p))
              .toList() ??
          [],
      minimumQty: json['minimumQty'] ?? 1,
      newSku: Map<String, bool>.from(json['newSku'] ?? {}),
      autoOpenPcQueue: json['autoOpenPcQueue'] ?? false,
      pcQueueDelaySeconds: json['pcQueueDelaySeconds'] ?? 0,
      reopenCooldown: json['reopenCooldown'] ?? 0,
    );
  }
}

/// Parent account information
class ParentAccountInfo {
  final String id;
  final String? discordServerName;

  const ParentAccountInfo({
    required this.id,
    this.discordServerName,
  });

  factory ParentAccountInfo.fromJson(Map<String, dynamic> json) {
    return ParentAccountInfo(
      id: json['id']?.toString() ?? '',
      discordServerName: json['discordServerName'],
    );
  }
}

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with username and password
  /// Returns AuthResult with token on success
  Future<AuthResult> signIn(String username, String password,
      {String? parentAccount});

  /// Sign out and clear stored credentials
  Future<void> signOut();

  /// Refresh the current JWT token
  /// Returns new token string or throws if refresh fails
  Future<String> refreshToken();

  /// Get current authenticated user profile
  /// Returns null if not authenticated
  Future<UserProfile?> getCurrentUser();

  /// Stream of authentication status changes
  /// Emits AuthSessionStatus updates as auth state changes
  Stream<AuthSessionStatus> sessionChanges();

  /// Get stored JWT token
  Future<String?> getStoredToken();

  /// Store JWT token securely
  Future<void> storeToken(String token);

  /// Clear stored token
  Future<void> clearToken();

  /// Check if currently authenticated
  Future<bool> isAuthenticated();

  /// Sign in with Discord OAuth
  /// Opens Discord authorization in browser and returns token on success
  /// guildId is optional Discord server ID for server-specific auth
  Future<AuthResult> signInWithDiscord({String? guildId});

  /// Update user preferences
  /// Accepts a map of preferences to update
  /// Returns true on success, false on failure
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences);

  /// Dispose resources (e.g., close streams)
  void dispose();
}
