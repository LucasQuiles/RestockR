import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/product_monitor_screen/product_monitor_screen.dart';
import '../presentation/recheck_history_screen/recheck_history_screen.dart';
import '../presentation/product_watchlist_screen/product_watchlist_screen.dart';
import '../presentation/watchlist_management_screen/watchlist_management_screen.dart';
import '../presentation/notifications_alerts_settings_screen/notifications_alerts_settings_screen.dart';
import '../presentation/retailer_filter_screen/retailer_filter_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/product_type_filter_screen/product_type_filter_screen.dart';
import '../presentation/number_type_filter_screen/number_type_filter_screen.dart';
import '../presentation/retailer_override_settings_screen/retailer_override_settings_screen.dart';
import '../presentation/global_filtering_settings_screen/global_filtering_settings_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

@immutable
class AppRouteDefinition {
  const AppRouteDefinition({
    required this.path,
    required this.builder,
    required this.debugLabel,
    this.requiresAuth = false,
    this.debugOnly = false,
    this.showInDebugMenu = true,
  });

  final String path;
  final WidgetBuilder builder;
  final String debugLabel;
  final bool requiresAuth;
  final bool debugOnly;
  final bool showInDebugMenu;
}

class AppRoutes {
  static const String splashScreen = '/splash_screen';
  static const String loginScreen = '/login_screen';
  static const String productMonitorScreen = '/product_monitor_screen';
  static const String recheckHistoryScreen = '/recheck_history_screen';
  static const String productWatchlistScreen = '/product_watchlist_screen';
  static const String productWatchlistScreenInitialPage =
      '/product_watchlist_screen_initial_page';
  static const String watchlistManagementScreen =
      '/watchlist_management_screen';
  static const String notificationsAlertsSettingsScreen =
      '/notifications_alerts_settings_screen';
  static const String retailerFilterScreen = '/retailer_filter_screen';
  static const String profileSettingsScreen = '/profile_settings_screen';
  static const String productTypeFilterScreen = '/product_type_filter_screen';
  static const String numberTypeFilterScreen = '/number_type_filter_screen';
  static const String retailerOverrideSettingsScreen =
      '/retailer_override_settings_screen';
  static const String globalFilteringSettingsScreen =
      '/global_filtering_settings_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = splashScreen;

  static final List<AppRouteDefinition> _definitions = [
    AppRouteDefinition(
      path: splashScreen,
      builder: (context) => SplashScreen(),
      debugLabel: 'Splash Screen',
      showInDebugMenu: true,
    ),
    AppRouteDefinition(
      path: loginScreen,
      builder: (context) => LoginScreen(),
      debugLabel: 'Login',
      showInDebugMenu: true,
    ),
    AppRouteDefinition(
      path: productMonitorScreen,
      builder: (context) => ProductMonitorScreen(),
      debugLabel: 'Monitor',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: recheckHistoryScreen,
      builder: (context) => RecheckHistoryScreen(),
      debugLabel: 'History vTwo',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: productWatchlistScreen,
      builder: (context) => ProductWatchlistScreen(),
      debugLabel: 'Watchlist - One',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: watchlistManagementScreen,
      builder: (context) => WatchlistManagementScreen(),
      debugLabel: 'Watchlist - Two',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: notificationsAlertsSettingsScreen,
      builder: (context) => NotificationsAlertsSettingsScreen(),
      debugLabel: 'Notifications & Alerts',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: retailerFilterScreen,
      builder: (context) => RetailerFilterScreen(),
      debugLabel: 'Filter - Retailer',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: profileSettingsScreen,
      builder: (context) => ProfileSettingsScreen(),
      debugLabel: 'Profile',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: productTypeFilterScreen,
      builder: (context) => ProductTypeFilterScreen(),
      debugLabel: 'Filter - Product Type',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: numberTypeFilterScreen,
      builder: (context) => NumberTypeFilterScreen(),
      debugLabel: 'Filter - Number type',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: retailerOverrideSettingsScreen,
      builder: (context) => RetailerOverrideSettingsScreen(),
      debugLabel: 'Retailer-Specific Overrides',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: globalFilteringSettingsScreen,
      builder: (context) => GlobalFilteringSettingsScreen(),
      debugLabel: 'Global Filtering',
      requiresAuth: true,
    ),
    AppRouteDefinition(
      path: appNavigationScreen,
      builder: (context) => AppNavigationScreen(),
      debugLabel: 'App Navigation',
      debugOnly: true,
      showInDebugMenu: false,
    ),
  ];

  static Iterable<AppRouteDefinition> get registeredRoutes =>
      _definitions.where(
        (route) => !route.debugOnly || AppConfig.showDebugMenu,
      );

  static Iterable<AppRouteDefinition> get debugMenuRoutes => _definitions.where(
        (route) =>
            route.showInDebugMenu &&
            route.path != appNavigationScreen &&
            (!route.debugOnly || AppConfig.showDebugMenu),
      );

  static AppRouteDefinition? definitionFor(String path) {
    for (final route in _definitions) {
      if (route.path == path) {
        return route;
      }
    }
    return null;
  }

  static bool routeRequiresAuth(String path) =>
      definitionFor(path)?.requiresAuth ?? false;

  static Map<String, WidgetBuilder> get routes => {
        '/': (context) => SplashScreen(),
        for (final route in registeredRoutes) route.path: route.builder,
      };
}
