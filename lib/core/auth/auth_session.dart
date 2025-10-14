import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated }

/// Tracks the current authentication status; will be replaced by real auth data.
final authSessionProvider = StateProvider<AuthSessionStatus>(
  (ref) => AuthSessionStatus.unknown,
);
