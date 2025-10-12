import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_search_view.dart';
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.h, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: TabBar(
        controller: tabController,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: appTheme.gray_900,
          borderRadius: BorderRadius.circular(8.h),
        ),
        dividerColor: appTheme.transparentCustom,
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
              child: Text(
                'Discover Products',
                style: TextStyleHelper.instance.body12SemiBoldInter,
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
              child: Text(
                'My Subscriptions (12)',
                style: TextStyleHelper.instance.body12SemiBoldInter,
              ),
            ),
          ),
        ],
        labelColor: appTheme.white_A700,
        unselectedLabelColor: appTheme.gray_900,
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

          return ListView.separated(
            padding: EdgeInsets.only(top: 16.h),
            physics: BouncingScrollPhysics(),
            itemCount: state.productWatchlistModel?.watchlistItems?.length ?? 0,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final item = state.productWatchlistModel?.watchlistItems?[index];
              return WatchlistItemWidget(
                watchlistItem: item,
                onTapSubscribe: () {
                  onTapSubscribe(context, index);
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
      child: Center(
        child: Text(
          'My Subscriptions Content',
          style: TextStyleHelper.instance.title16MediumInter
              .copyWith(color: appTheme.gray_900),
        ),
      ),
    );
  }

  void onTapNotification(BuildContext context) {
    // Handle notification tap
  }

  void onTapProfile(BuildContext context) {
    // Handle profile tap
  }

  void onTapSubscribe(BuildContext context, int index) {
    ref.read(productWatchlistNotifier.notifier).toggleSubscription(index);
  }
}
