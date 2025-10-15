import 'dart:async';
import '../../core/auth/auth_status.dart';
import '../../core/config/backend_config.dart';
import 'auth_repository.dart';

/// Mock implementation of AuthRepository for development/testing
/// Simulates authentication with hardcoded responses and delays
class MockAuthRepository implements AuthRepository {
  final BackendConfig config;
  final _sessionController =
      StreamController<AuthSessionStatus>.broadcast();

  AuthSessionStatus _currentStatus = AuthSessionStatus.unknown;
  String? _mockToken;
  UserProfile? _mockUser;

  MockAuthRepository({required this.config}) {
    _initialize();
  }

  void _initialize() async {
    // Simulate checking for stored token on init
    await Future.delayed(const Duration(milliseconds: 500));
    final storedToken = await getStoredToken();

    if (storedToken != null && storedToken.isNotEmpty) {
      _mockToken = storedToken;
      _mockUser = _createMockUser();
      _updateStatus(AuthSessionStatus.authenticated);
    } else {
      _updateStatus(AuthSessionStatus.unauthenticated);
    }
  }

  void _updateStatus(AuthSessionStatus status) {
    _currentStatus = status;
    if (!_sessionController.isClosed) {
      _sessionController.add(status);
    }
  }

  UserProfile _createMockUser() {
    return const UserProfile(
      id: '68bb880ed198820652b948f0',
      username: 'mockuser',
      email: 'mock@example.com',
      userType: 2,
      productSkus: [],
      restockBell: true,
      parentAccounts: [
        ParentAccountInfo(
          id: '689cfdb2af4352a5d8e2b041',
          discordServerName: 'Mock Server',
        ),
      ],
      minimumQty: 1,
      newSku: {
        'pokemon': false,
        'mtg': false,
        'op': false,
        'gundam': false,
        'riftbound': false,
        'yugioh': false,
      },
      autoOpenPcQueue: false,
      pcQueueDelaySeconds: 0,
      reopenCooldown: 0,
    );
  }

  @override
  Future<AuthResult> signIn(
    String username,
    String password, {
    String? parentAccount,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple mock validation
    if (username.isEmpty || password.isEmpty) {
      _updateStatus(AuthSessionStatus.unauthenticated);
      return AuthResult.failure('Username and password required');
    }

    // Accept any non-empty credentials for mock
    if (username.length >= 3 && password.length >= 3) {
      // Generate mock JWT token
      _mockToken =
          'mock.jwt.token.${DateTime.now().millisecondsSinceEpoch}';
      _mockUser = _createMockUser();
      await storeToken(_mockToken!);
      _updateStatus(AuthSessionStatus.authenticated);
      return AuthResult.success(_mockToken!);
    }

    _updateStatus(AuthSessionStatus.unauthenticated);
    return AuthResult.failure('Invalid credentials');
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockToken = null;
    _mockUser = null;
    await clearToken();
    _updateStatus(AuthSessionStatus.unauthenticated);
  }

  @override
  Future<String> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_mockToken == null) {
      throw Exception('No token to refresh');
    }

    // Generate new mock token
    _mockToken =
        'mock.jwt.token.refreshed.${DateTime.now().millisecondsSinceEpoch}';
    await storeToken(_mockToken!);
    return _mockToken!;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_mockToken == null) {
      return null;
    }

    return _mockUser ?? _createMockUser();
  }

  @override
  Stream<AuthSessionStatus> sessionChanges() {
    return _sessionController.stream;
  }

  @override
  Future<String?> getStoredToken() async {
    // Mock token storage - in real impl this would use shared_preferences or secure_storage
    return _mockToken;
  }

  @override
  Future<void> storeToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockToken = token;
  }

  @override
  Future<void> clearToken() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockToken = null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthResult> signInWithDiscord({String? guildId}) async {
    // Mock Discord OAuth - simulate successful login after delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock JWT token
    _mockToken =
        'mock.discord.jwt.token.${DateTime.now().millisecondsSinceEpoch}';
    _mockUser = _createMockUser();
    await storeToken(_mockToken!);
    _updateStatus(AuthSessionStatus.authenticated);
    return AuthResult.success(_mockToken!);
  }

  @override
  void dispose() {
    _sessionController.close();
  }
}
