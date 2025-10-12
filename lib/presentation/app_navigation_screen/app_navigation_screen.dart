import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class AppNavigationScreen extends ConsumerStatefulWidget {
  const AppNavigationScreen({Key? key}) : super(key: key);

  @override
  AppNavigationScreenState createState() => AppNavigationScreenState();
}

class AppNavigationScreenState extends ConsumerState<AppNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      _buildScreenTitle(
                        context,
                        screenTitle: "Splash Screen",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.splashScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Login",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.loginScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Monitor",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.productMonitorScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "History vTwo",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.recheckHistoryScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Watchlist - One",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.productWatchlistScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Watchlist - Two",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.watchlistManagementScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Notifications & Alerts",
                        onTapScreenTitle: () => onTapScreenTitle(context,
                            AppRoutes.notificationsAlertsSettingsScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Filter -Retailer",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.retailerFilterScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Profile",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.profileSettingsScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Filter - Product Type",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.productTypeFilterScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Filter - Number type",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.numberTypeFilterScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Retailer-Specific Overrides",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.retailerOverrideSettingsScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Global Filtering",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.globalFilteringSettingsScreen),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
    BuildContext context, {
    required String screenTitle,
    Function? onTapScreenTitle,
  }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        decoration: BoxDecoration(color: Color(0XFFFFFFFF)),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  screenTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0XFF000000),
                    fontSize: 20.fSize,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Color(0XFF343330),
                )
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1.h, thickness: 1.h, color: Color(0XFFD2D2D2)),
          ],
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(BuildContext context, String routeName) {
    NavigatorService.pushNamed(routeName);
  }

  /// Common click event for bottomsheet
  void onTapBottomSheetTitle(BuildContext context, Widget className) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return className;
      },
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Common click event for dialog
  void onTapDialogTitle(BuildContext context, Widget className) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: className,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
