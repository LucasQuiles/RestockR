import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../product_monitor_screen/product_monitor_screen.dart';
import '../recheck_history_screen/recheck_history_screen.dart';
import './product_watchlist_screen_initial_page.dart';

class ProductWatchlistScreen extends ConsumerStatefulWidget {
  const ProductWatchlistScreen({Key? key}) : super(key: key);

  @override
  ProductWatchlistScreenState createState() => ProductWatchlistScreenState();
}

class ProductWatchlistScreenState
    extends ConsumerState<ProductWatchlistScreen> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  int _selectedIndex = 1; // Default to Monitor tab

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Navigator(
          key: navigatorKey,
          initialRoute: AppRoutes.productMonitorScreen,
          onGenerateRoute: (routeSetting) => PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) =>
                getCurrentPage(context, routeSetting.name!),
            transitionDuration: Duration(seconds: 0),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.maxFinite,
        child: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    var bottomBarItemList = <CustomBottomBarItem>[
      CustomBottomBarItem(
        icon: ImageConstant.imgNavDashboard,
        activeIcon: ImageConstant.imgNavDashboard,
        title: 'Dashboard',
        routeName: AppRoutes.productWatchlistScreenInitialPage,
      ),
      CustomBottomBarItem(
        icon: ImageConstant.imgNavMonitor,
        activeIcon: ImageConstant.imgNavMonitorRed500,
        title: 'Monitor',
        routeName: AppRoutes.productMonitorScreen,
      ),
      CustomBottomBarItem(
        icon: ImageConstant.imgNavHistory,
        activeIcon: ImageConstant.imgNavHistoryRed500,
        title: 'History',
        routeName: AppRoutes.recheckHistoryScreen,
      ),
      CustomBottomBarItem(
        icon: ImageConstant.imgNavWatchlist,
        activeIcon: ImageConstant.imgNavWatchlist,
        title: 'Watchlist',
        routeName: AppRoutes.productWatchlistScreenInitialPage,
      ),
    ];

    return CustomBottomBar(
      bottomBarItemList: bottomBarItemList,
      selectedIndex: _selectedIndex,
      onChanged: (index) {
        if (_selectedIndex == index) {
          return;
        }
        setState(() {
          _selectedIndex = index;
        });
        var bottomBarItem = bottomBarItemList[index];
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          bottomBarItem.routeName!,
          (route) => false,
        );
      },
    );
  }

  Widget getCurrentPage(BuildContext context, String currentRoute) {
    switch (currentRoute) {
      case AppRoutes.productWatchlistScreenInitialPage:
        return ProductWatchlistScreenInitialPage();
      case AppRoutes.productMonitorScreen:
        return ProductMonitorScreen();
      case AppRoutes.recheckHistoryScreen:
        return RecheckHistoryScreen();
      default:
        return ProductWatchlistScreenInitialPage();
    }
  }
}
