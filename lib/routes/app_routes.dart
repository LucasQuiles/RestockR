import 'package:flutter/material.dart';
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
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        splashScreen: (context) => SplashScreen(),
        loginScreen: (context) => LoginScreen(),
        productMonitorScreen: (context) => ProductMonitorScreen(),
        recheckHistoryScreen: (context) => RecheckHistoryScreen(),
        productWatchlistScreen: (context) => ProductWatchlistScreen(),
        watchlistManagementScreen: (context) => WatchlistManagementScreen(),
        notificationsAlertsSettingsScreen: (context) =>
            NotificationsAlertsSettingsScreen(),
        retailerFilterScreen: (context) => RetailerFilterScreen(),
        profileSettingsScreen: (context) => ProfileSettingsScreen(),
        productTypeFilterScreen: (context) => ProductTypeFilterScreen(),
        numberTypeFilterScreen: (context) => NumberTypeFilterScreen(),
        retailerOverrideSettingsScreen: (context) =>
            RetailerOverrideSettingsScreen(),
        globalFilteringSettingsScreen: (context) =>
            GlobalFilteringSettingsScreen(),
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => AppNavigationScreen()
      };
}
