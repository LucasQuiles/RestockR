import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_session.dart';
import '../utils/navigator_service.dart';

/// Resolves navigation guard behaviour using the latest auth session signal.
final routeGuardProvider = Provider<RouteGuard>(
  (ref) => (routeName, arguments) {
    if (!AppRoutes.routeRequiresAuth(routeName)) {
      return true;
    }

    final status = ref.read(authSessionProvider);
    if (status == AuthSessionStatus.authenticated ||
        status == AuthSessionStatus.unknown) {
      return true;
    }

    assert(() {
      debugPrint('Navigation blocked for $routeName until authentication.');
      return true;
    }());
    return false;
  },
);
