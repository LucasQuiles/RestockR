import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import 'auth_status.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/auth/auth_repository_mock.dart';
import '../../data/auth/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(backendConfigProvider);

  // Use mock repository for development, real for production
  final AuthRepository repository;
  if (config.environment == 'development' || config.environment == 'local') {
    // Use mock for local/dev testing
    repository = MockAuthRepository(config: config);
  } else {
    // Use real implementation for staging/production
    repository = AuthRepositoryImpl(config: config);
  }

  ref.onDispose(repository.dispose);
  return repository;
});

class AuthSessionController extends StateNotifier<AuthSessionStatus> {
  AuthSessionController(this._repository) : super(AuthSessionStatus.unknown) {
    _subscription = _repository.sessionChanges().listen(
      (status) => state = status,
      onError: (_) => state = AuthSessionStatus.unauthenticated,
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthSessionStatus> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Tracks the current authentication status and stays in sync with repository state.
final authSessionProvider =
    StateNotifierProvider<AuthSessionController, AuthSessionStatus>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthSessionController(repository);
});
