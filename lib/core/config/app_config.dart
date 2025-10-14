import 'package:flutter/foundation.dart';

/// Central toggle points for build-time/runtime feature flags.
class AppConfig {
  /// Controls whether debug-only tooling such as the navigation screen is exposed.
  static bool get showDebugMenu =>
      const bool.fromEnvironment('RESTOCKR_DEBUG_MENU', defaultValue: false) ||
      kDebugMode;
}
