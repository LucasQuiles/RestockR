import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/number_type_filter_notifier.dart';

class NumberTypeFilterScreen extends ConsumerStatefulWidget {
  NumberTypeFilterScreen({Key? key}) : super(key: key);

  @override
  NumberTypeFilterScreenState createState() => NumberTypeFilterScreenState();
}

class NumberTypeFilterScreenState
    extends ConsumerState<NumberTypeFilterScreen> {
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
                  child: Column(
                    children: [
                      _buildFilterContent(context),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context),
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
      titleSpacing: 0,
    );
  }

  /// Section Widget
  Widget _buildFilterContent(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterTabs(context),
          Expanded(
            child: _buildNumberTypeOptions(context),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildFilterTabs(BuildContext context) {
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
        spacing: 24.h,
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
          Container(
            margin: EdgeInsets.only(left: 10.h),
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
          Container(
            margin: EdgeInsets.only(bottom: 518.h),
            child: Row(
              spacing: 10.h,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Number type',
                  style: TextStyle(
                    fontSize: 14.fSize,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDC2626),
                  ),
                ),
                CustomImageView(
                  imagePath: ImageConstant.imgIconsRed700,
                  height: 20.h,
                  width: 20.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildNumberTypeOptions(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.h,
        left: 26.h,
      ),
      width: MediaQuery.of(context).size.width * 0.5,
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(numberTypeFilterNotifier);

          return Column(
            children: [
              _buildRadioOption(
                context,
                text: 'Number of Restocks',
                isSelected: state.selectedNumberType == 'restocks',
                onTap: () {
                  ref
                      .read(numberTypeFilterNotifier.notifier)
                      .selectNumberType('restocks');
                },
              ),
              SizedBox(height: 16.h),
              _buildRadioOption(
                context,
                text: 'Number of Reactions',
                isSelected: state.selectedNumberType == 'reactions',
                onTap: () {
                  ref
                      .read(numberTypeFilterNotifier.notifier)
                      .selectNumberType('reactions');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Helper Widget
  Widget _buildRadioOption(
    BuildContext context, {
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            CustomImageView(
              imagePath: isSelected
                  ? ImageConstant.imgRadioButtons
                  : ImageConstant.imgRadioButtonsGray600,
              height: 24.h,
              width: 24.h,
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Color(0xFFDC2626) : Color(0xFF808080),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildBottomActions(BuildContext context) {
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

  /// Handles clear all filters action
  void onTapClearAll(BuildContext context) {
    ref.read(numberTypeFilterNotifier.notifier).clearAllFilters();
  }

  /// Handles close action
  void onTapClose(BuildContext context) {
    NavigatorService.goBack();
  }

  /// Handles apply filters action
  void onTapApply(BuildContext context) {
    ref.read(numberTypeFilterNotifier.notifier).applyFilters();
    NavigatorService.goBack();
  }
}
