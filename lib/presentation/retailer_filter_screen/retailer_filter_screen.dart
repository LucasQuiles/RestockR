import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/retailer_filter_notifier.dart';

class RetailerFilterScreen extends ConsumerStatefulWidget {
  RetailerFilterScreen({Key? key}) : super(key: key);

  @override
  RetailerFilterScreenState createState() => RetailerFilterScreenState();
}

class RetailerFilterScreenState extends ConsumerState<RetailerFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: _buildAppBar(context),
        body: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              _buildMainContent(context),
              _buildBottomActionBar(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 18.fSize,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {
                onTapClearAll(context);
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildMainContent(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTabs(context),
                  SizedBox(width: 26.h),
                  _buildRetailerList(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.only(top: 16.h, left: 8.h, right: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.h),
        ),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(retailerFilterNotifier);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(retailerFilterNotifier.notifier)
                      .selectFilter('Retailer');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Retailer',
                        style: TextStyle(
                          fontSize: 14.fSize,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: (state.selectedFilter == 'Retailer')
                              ? Color(0xFFDC2626)
                              : Color(0xFF808080),
                        ),
                      ),
                      if (state.selectedFilter == 'Retailer')
                        CustomImageView(
                          imagePath: ImageConstant.imgIconsRed700,
                          height: 20.h,
                          width: 20.h,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () {
                  ref
                      .read(retailerFilterNotifier.notifier)
                      .selectFilter('Product Type');
                  NavigatorService.pushNamed(AppRoutes.productTypeFilterScreen);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  child: Text(
                    'Product Type',
                    style: TextStyle(
                      fontSize: 14.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF808080),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () {
                  ref
                      .read(retailerFilterNotifier.notifier)
                      .selectFilter('Number type');
                  NavigatorService.pushNamed(AppRoutes.numberTypeFilterScreen);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  margin: EdgeInsets.only(bottom: 518.h),
                  child: Text(
                    'Number type',
                    style: TextStyle(
                      fontSize: 14.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF808080),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildRetailerList(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(retailerFilterNotifier);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRetailerCheckbox(
                  context,
                  'Amazon',
                  state.retailerFilterModel?.amazonSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('amazon');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'Amazon-uk',
                  state.retailerFilterModel?.amazonUkSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('amazon-uk');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'Costco',
                  state.retailerFilterModel?.costcoSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('costco');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'Macys',
                  state.retailerFilterModel?.macysSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('macys');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'BestBuy',
                  state.retailerFilterModel?.bestBuySelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('bestbuy');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'target',
                  state.retailerFilterModel?.targetSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('target');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'Scheels',
                  state.retailerFilterModel?.scheelsSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('scheels');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'Pokemon_center',
                  state.retailerFilterModel?.pokemonCenterSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('pokemon_center');
                  },
                ),
                SizedBox(height: 16.h),
                _buildRetailerCheckbox(
                  context,
                  'Walmart',
                  state.retailerFilterModel?.walmartSelected ?? false,
                  () {
                    ref
                        .read(retailerFilterNotifier.notifier)
                        .toggleRetailer('walmart');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildRetailerCheckbox(BuildContext context, String retailerName,
      bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            CustomImageView(
              imagePath: isSelected
                  ? ImageConstant.imgCheckbox
                  : ImageConstant.imgCheckboxGray600,
              height: 24.h,
              width: 24.h,
            ),
            SizedBox(width: 8.h),
            Text(
              retailerName,
              style: TextStyle(
                fontSize: 14.fSize,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: isSelected ? Color(0xFFDC2626) : Color(0xFF808080),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFF4F4F4),
            width: 1.h,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              onTapClose(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Color(0xFFF4F4F4),
                    width: 1.h,
                  ),
                ),
              ),
              child: Text(
                'CLOSE',
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF808080),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTapApply(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: 70.h),
              child: Text(
                'APPLY',
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates back to the previous screen
  void onTapClose(BuildContext context) {
    NavigatorService.goBack();
  }

  /// Applies the selected filters and navigates back
  void onTapApply(BuildContext context) {
    ref.read(retailerFilterNotifier.notifier).applyFilters();
    NavigatorService.goBack();
  }

  /// Clears all selected filters
  void onTapClearAll(BuildContext context) {
    ref.read(retailerFilterNotifier.notifier).clearAllFilters();
  }
}
