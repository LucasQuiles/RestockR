import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/product_type_filter_notifier.dart';

class ProductTypeFilterScreen extends ConsumerStatefulWidget {
  ProductTypeFilterScreen({Key? key}) : super(key: key);

  @override
  ProductTypeFilterScreenState createState() => ProductTypeFilterScreenState();
}

class ProductTypeFilterScreenState
    extends ConsumerState<ProductTypeFilterScreen> {
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
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        _buildFilterContent(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(context),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56.h,
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
  Widget _buildFilterContent(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterCategories(context),
          SizedBox(width: 26.h),
          Expanded(
            child: _buildProductTypeList(context),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildFilterCategories(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.h),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16.h,
        left: 6.h,
        right: 6.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.h),
            child: Text(
              'Retailer',
              style: TextStyle(
                fontSize: 14.fSize,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Color(0xFF808080),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(left: 10.h),
                child: Text(
                  'Product Type',
                  style: TextStyle(
                    fontSize: 14.fSize,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
              SizedBox(width: 8.h),
              CustomImageView(
                imagePath: ImageConstant.imgIconsRed700,
                height: 20.h,
                width: 20.h,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            margin: EdgeInsets.only(left: 10.h, bottom: 518.h),
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
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildProductTypeList(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(productTypeFilterNotifier);

        return Container(
          margin: EdgeInsets.only(top: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckboxItem(
                context,
                'All Type',
                state.productTypeFilterModel?.allTypeSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .toggleAllType(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Pokemon',
                state.productTypeFilterModel?.pokemonSelected ?? false,
                Color(0xFFDC2626),
                ImageConstant.imgCheckbox,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .togglePokemon(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Onepiece',
                state.productTypeFilterModel?.onepieceSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .toggleOnepiece(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'YugoMtg',
                state.productTypeFilterModel?.yugoMtgSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .toggleYugoMtg(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Gundam',
                state.productTypeFilterModel?.gundamSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () =>
                    ref.read(productTypeFilterNotifier.notifier).toggleGundam(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Sportscards',
                state.productTypeFilterModel?.sportscardsSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .toggleSportscards(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Scheels',
                state.productTypeFilterModel?.scheelsSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .toggleScheels(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Pokemon_center',
                state.productTypeFilterModel?.pokemonCenterSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .togglePokemonCenter(),
              ),
              SizedBox(height: 16.h),
              _buildCheckboxItem(
                context,
                'Walmart',
                state.productTypeFilterModel?.walmartSelected ?? false,
                Color(0xFF808080),
                ImageConstant.imgCheckboxGray600,
                () => ref
                    .read(productTypeFilterNotifier.notifier)
                    .toggleWalmart(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper Widget
  Widget _buildCheckboxItem(
    BuildContext context,
    String text,
    bool isSelected,
    Color textColor,
    String iconPath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
            text,
            style: TextStyle(
              fontSize: 14.fSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: isSelected ? Color(0xFFDC2626) : Color(0xFF808080),
            ),
          ),
        ],
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
              padding: EdgeInsets.symmetric(
                horizontal: 30.h,
                vertical: 16.h,
              ),
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

  /// Clears all filter selections
  void onTapClearAll(BuildContext context) {
    ref.read(productTypeFilterNotifier.notifier).clearAllFilters();
  }

  /// Applies the current filter selections and navigates back
  void onTapApply(BuildContext context) {
    ref.read(productTypeFilterNotifier.notifier).applyFilters();
    NavigatorService.goBack();
  }
}
