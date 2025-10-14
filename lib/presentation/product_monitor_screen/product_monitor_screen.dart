import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_search_view.dart';
import './widgets/monitor_item_widget.dart';
import 'models/monitor_item_model.dart';
import 'notifier/product_monitor_notifier.dart';

class ProductMonitorScreen extends ConsumerStatefulWidget {
  ProductMonitorScreen({Key? key}) : super(key: key);

  @override
  ProductMonitorScreenState createState() => ProductMonitorScreenState();
}

class ProductMonitorScreenState extends ConsumerState<ProductMonitorScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 7, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        ref
            .read(productMonitorNotifier.notifier)
            .onTabChanged(tabController.index);
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appTheme.gray_100,
        body: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              _buildHeaderSection(context),
              Expanded(
                child: _buildContentSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.h),
          bottomRight: Radius.circular(24.h),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        spacing: 20.h,
        children: [
          _buildAppBarSection(context),
          _buildSearchSection(context),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildAppBarSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Monitor",
            style: TextStyleHelper.instance.headline24BoldInter
                .copyWith(height: 1.25),
          ),
          Spacer(),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {
              onTapNotificationButton(context);
            },
          ),
          SizedBox(width: 8.h),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1Gray900,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {
              onTapProfileButton(context);
            },
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildSearchSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(productMonitorNotifier);
        return CustomSearchView(
          controller: state.searchController,
          hintText: "Search",
          backgroundColor: appTheme.gray_100,
          borderRadius: 12.h,
          margin: EdgeInsets.only(left: 16.h, right: 16.h, bottom: 12.h),
          onChanged: (value) {
            ref.read(productMonitorNotifier.notifier).onSearchChanged(value);
          },
        );
      },
    );
  }

  /// Section Widget
  Widget _buildContentSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSection(context),
          Expanded(
            child: _buildTabBarView(context),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildTabSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.h, left: 16.h),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(),
        dividerColor: appTheme.transparentCustom,
        labelPadding: EdgeInsets.zero,
        tabs: [
          _buildTab("All", 0),
          _buildTab("Target", 1),
          _buildTab("Amazon", 2),
          _buildTab("SamClub", 3),
          _buildTab("BestBuy", 4),
          _buildTab("Walmart", 5),
          _buildTab("Costco", 6),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(productMonitorNotifier);
        final isSelected = state.selectedTabIndex == index;

        return GestureDetector(
          onTap: () {
            tabController.animateTo(index);
            ref.read(productMonitorNotifier.notifier).onTabChanged(index);
          },
          child: Container(
            margin: EdgeInsets.only(right: 8.h),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? appTheme.black_900 : appTheme.white_A700,
                borderRadius: BorderRadius.circular(24.h),
                border: Border.all(
                  color: isSelected ? appTheme.black_900 : appTheme.gray_300,
                  width: 1,
                ),
              ),
              child: Text(
                text,
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: isSelected ? appTheme.white_A700 : appTheme.gray_700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: List.generate(7, (index) => _buildMonitorList(context, index)),
    );
  }

  /// Section Widget
  Widget _buildMonitorList(BuildContext context, int tabIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(productMonitorNotifier);

          if (state.isLoading ?? false) {
            return Center(child: CircularProgressIndicator());
          }

          final monitorItems = state.productMonitorModel?.monitorItems ?? [];
          final filteredItems = _filterItemsForTab(monitorItems, tabIndex);

          if (filteredItems.isEmpty) {
            return Center(
              child: Text(
                "No products to show.",
                style: TextStyleHelper.instance.body14MediumInter
                    .copyWith(color: appTheme.gray_600),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.only(top: 16.h),
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 8.h);
            },
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final model = filteredItems[index];
              final originalIndex = monitorItems.indexOf(model);
              return MonitorItemWidget(
                model: model,
                onTapBuy: () {
                  onTapBuyButton(context, model);
                },
                onTapDownVote: () {
                  if (originalIndex != -1) {
                    ref
                        .read(productMonitorNotifier.notifier)
                        .onDownVote(originalIndex);
                  }
                },
                onTapUpVote: () {
                  if (originalIndex != -1) {
                    ref
                        .read(productMonitorNotifier.notifier)
                        .onUpVote(originalIndex);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Navigates to notification screen
  void onTapNotificationButton(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.notificationsAlertsSettingsScreen);
  }

  /// Navigates to profile screen
  void onTapProfileButton(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.profileSettingsScreen);
  }

  /// Handles buy button tap
  void onTapBuyButton(BuildContext context, MonitorItemModel? model) {
    NavigatorService.pushNamed(AppRoutes.watchlistManagementScreen);
  }

  List<MonitorItemModel> _filterItemsForTab(
      List<MonitorItemModel> items, int tabIndex) {
    if (tabIndex == 0) {
      return items;
    }

    const storeTabs = [
      null,
      "Target",
      "Amazon",
      "SamClub",
      "BestBuy",
      "Walmart",
      "Costco",
    ];

    if (tabIndex < 0 || tabIndex >= storeTabs.length) {
      return items;
    }

    final expectedStore = storeTabs[tabIndex];
    if (expectedStore == null) {
      return items;
    }

    return items
        .where(
          (element) =>
              element.storeName?.toLowerCase() == expectedStore.toLowerCase(),
        )
        .toList();
  }
}
