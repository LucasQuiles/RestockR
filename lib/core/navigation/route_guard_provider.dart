import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_session.dart';
import '../auth/auth_status.dart';
import '../utils/navigator_service.dart';

/// Resolves navigation guard behaviour using the latest auth session signal.
final routeGuardProvider = Provider<RouteGuard>(
  (ref) => (routeName, arguments) {
    final requiresAuth = AppRoutes.routeRequiresAuth(routeName);

    if (!requiresAuth) {
      debugPrint('🚪 Route guard: Allowing $routeName (no auth required)');
      return true;
    }

    final status = ref.read(authSessionProvider);
    debugPrint('🚪 Route guard: Checking $routeName (requires auth), status: $status');

    if (status == AuthSessionStatus.authenticated ||
        status == AuthSessionStatus.unknown) {
      debugPrint('🚪 Route guard: ✅ Allowing $routeName');
      return true;
    }

    debugPrint('🚪 Route guard: ❌ Blocking $routeName (status: $status)');
    assert(() {
      debugPrint('Navigation blocked for $routeName until authentication.');
      return true;
    }());
    return false;
  },
);
