import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_search_view.dart';
import './models/watchlist_item_model.dart';
import './widgets/watchlist_item_widget.dart';
import 'notifier/product_watchlist_notifier.dart';

class ProductWatchlistScreenInitialPage extends ConsumerStatefulWidget {
  const ProductWatchlistScreenInitialPage({Key? key}) : super(key: key);

  @override
  ProductWatchlistScreenInitialPageState createState() =>
      ProductWatchlistScreenInitialPageState();
}

class ProductWatchlistScreenInitialPageState
    extends ConsumerState<ProductWatchlistScreenInitialPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        ref
            .read(productWatchlistNotifier.notifier)
            .changeTab(tabController.index);
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.gray_100,
      ),
      child: Column(
        children: [
          _buildHeaderSection(context),
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
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
          _buildAppBar(context),
          _buildSearchView(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Watchlist',
            style: TextStyleHelper.instance.headline24BoldInter,
          ),
          Spacer(),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1,
            height: 48.h,
            width: 48.h,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {
              onTapNotification(context);
            },
          ),
          SizedBox(width: 8.h),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1Gray900,
            height: 48.h,
            width: 48.h,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {
              onTapProfile(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      child: CustomSearchView(
        hintText: "Search",
        backgroundColor: appTheme.gray_100,
        borderRadius: 12.h,
        margin: EdgeInsets.only(bottom: 12.h),
        onChanged: (value) {
          ref.read(productWatchlistNotifier.notifier).searchProducts(value);
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        _buildTabSection(context),
        Expanded(
          child: _buildTabContent(context),
        ),
      ],
    );
  }

  Widget _buildTabSection(BuildContext context) {
    final subscriptionCount = ref.watch(
      productWatchlistNotifier.select(
        (state) => state.subscribedCount ?? 0,
      ),
    );

    final selectedIndex = ref.watch(
      productWatchlistNotifier.select(
        (state) => state.selectedTabIndex ?? 0,
      ),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(16.h, 12.h, 16.h, 12.h),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorColor: appTheme.transparentCustom,
        dividerColor: appTheme.transparentCustom,
        overlayColor: WidgetStateProperty.all(appTheme.transparentCustom),
        onTap: (index) {
          ref.read(productWatchlistNotifier.notifier).changeTab(index);
        },
        tabs: [
          _buildFilterPill(
            context,
            title: 'Discover Products',
            isSelected: selectedIndex == 0,
          ),
          _buildFilterPill(
            context,
            title: 'My Subscriptions ($subscriptionCount)',
            isSelected: selectedIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        _buildDiscoverTab(context),
        _buildSubscriptionsTab(context),
      ],
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(productWatchlistNotifier);
          final items =
              state.productWatchlistModel?.watchlistItems ?? const [];

          if (state.isLoading ?? false) {
            return Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return Center(
              child: Text(
                'No products found. Try adjusting your search.',
                style: TextStyleHelper.instance.title16MediumInter
                    .copyWith(color: appTheme.gray_600),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.only(top: 8.h),
            physics: BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final item = items[index];
              return WatchlistItemWidget(
                watchlistItem: item,
                onTapSubscribe: (selectedItem) {
                  onTapSubscribe(context, selectedItem);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionsTab(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(productWatchlistNotifier);
          final items =
              state.productWatchlistModel?.watchlistItems ?? const [];

          final subscribedItems = items
              .where((item) => item.isSubscribed ?? false)
              .toList(growable: false);

          if (subscribedItems.isEmpty) {
            return Center(
              child: Text(
                state.searchQuery?.isNotEmpty ?? false
                    ? 'No subscriptions match your search.'
                    : 'You have not subscribed to any products yet.',
                style: TextStyleHelper.instance.title16MediumInter
                    .copyWith(color: appTheme.gray_600),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.only(top: 8.h),
            physics: BouncingScrollPhysics(),
            itemCount: subscribedItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final item = subscribedItems[index];
              return WatchlistItemWidget(
                watchlistItem: item,
                onTapSubscribe: (selectedItem) {
                  onTapSubscribe(context, selectedItem);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String title,
    required bool isSelected,
  }) {
    return Tab(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        margin: EdgeInsets.only(right: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.black_900 : appTheme.white_A700,
          borderRadius: BorderRadius.circular(28.h),
          border: Border.all(
            color: isSelected ? appTheme.black_900 : appTheme.gray_300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: appTheme.color190000,
                    offset: Offset(0, 3),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.body12SemiBoldInter.copyWith(
              color: isSelected ? appTheme.white_A700 : appTheme.gray_700,
            ),
          ),
        ),
      ),
    );
  }

  void onTapNotification(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.notificationsAlertsSettingsScreen);
  }

  void onTapProfile(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.profileSettingsScreen);
  }

  void onTapSubscribe(BuildContext context, WatchlistItemModel item) {
    final wasSubscribed = item.isSubscribed ?? false;
    ref.read(productWatchlistNotifier.notifier).toggleSubscription(item);

    final variant = wasSubscribed
        ? AppToastVariant.warning
        : AppToastVariant.success;
    final message = wasSubscribed
        ? 'Removed from your subscriptions.'
        : 'Subscribed to ${item.productName ?? 'product'}.';

    showAppToast(
      context,
      message: message,
      variant: variant,
    );
  }
}
