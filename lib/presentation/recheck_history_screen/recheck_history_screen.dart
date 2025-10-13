import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_search_view.dart';
import './models/recheck_history_model.dart';
import './widgets/activity_item_widget.dart';
import 'notifier/recheck_history_notifier.dart';

class RecheckHistoryScreen extends ConsumerStatefulWidget {
  RecheckHistoryScreen({Key? key}) : super(key: key);

  @override
  RecheckHistoryScreenState createState() => RecheckHistoryScreenState();
}

class RecheckHistoryScreenState extends ConsumerState<RecheckHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appTheme.gray_100,
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              _buildHeaderSection(context),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContentSection(context),
                ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.whiteCustom,
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
            "Recheck History",
            style: TextStyleHelper.instance.headline24BoldInter,
          ),
          Spacer(),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {},
          ),
          SizedBox(width: 8.h),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1Gray900,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildSearchSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.h, right: 16.h, bottom: 12.h),
      child: Row(
        spacing: 8.h,
        children: [
          Expanded(
            child: CustomSearchView(
              hintText: "Search",
              prefixIconPath: ImageConstant.imgSearch,
              backgroundColor: appTheme.gray_100,
              borderRadius: 12.h,
            ),
          ),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1Black900,
            backgroundColor: appTheme.gray_100,
            borderRadius: 16.h,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildContentSection(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.h, left: 16.h),
            child: Column(
              spacing: 16.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthDropdown(context),
                _buildCalendarSection(context),
                _buildActivityListSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildMonthDropdown(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(recheckHistoryNotifier);
        return CustomDropdown(
          hintText: "September 2025",
          width: "44%",
          iconPath: ImageConstant.imgFrameBlack900,
          contentPadding: EdgeInsets.only(
            top: 12.h,
            right: 36.h,
            bottom: 12.h,
            left: 12.h,
          ),
          items: state.recheckHistoryModel?.monthOptions ?? [],
          value: state.recheckHistoryModel?.selectedMonth,
          onChanged: (value) {
            ref
                .read(recheckHistoryNotifier.notifier)
                .onMonthChanged(value ?? '');
          },
        );
      },
    );
  }

  /// Section Widget
  Widget _buildCalendarSection(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Consumer(
        builder: (context, ref, _) {
          return CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: (date) {
              ref.read(recheckHistoryNotifier.notifier).onDateChanged(date);
            },
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildActivityListSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.h),
      child: Column(
        children: [
          _buildTableHeader(context),
          SizedBox(height: 6.h),
          _buildActivityList(context),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildTableHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 26.h, left: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Time",
            style: TextStyleHelper.instance.title16MediumInter
                .copyWith(color: appTheme.gray_600),
          ),
          Text(
            "Status",
            style: TextStyleHelper.instance.title16MediumInter
                .copyWith(color: appTheme.gray_600),
          ),
          Spacer(),
          Text(
            "Qty",
            style: TextStyleHelper.instance.title16MediumInter
                .copyWith(color: appTheme.gray_600),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildActivityList(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(recheckHistoryNotifier);

        return Column(
          spacing: 4.h,
          children: [
            // High Activity Items
            ...List.generate(
              state.recheckHistoryModel?.highActivityItems?.length ?? 0,
              (index) {
                final item =
                    state.recheckHistoryModel?.highActivityItems?[index];
                return ActivityItemWidget(
                  model: item!,
                  onTap: () {
                    _onTapActivityItem(context, item);
                  },
                );
              },
            ),

            // No Activity Items
            ...List.generate(
              state.recheckHistoryModel?.noActivityItems?.length ?? 0,
              (index) {
                final item = state.recheckHistoryModel?.noActivityItems?[index];
                return ActivityItemWidget(
                  model: item!,
                  onTap: () {
                    _onTapActivityItem(context, item);
                  },
                );
              },
            ),

            // Moderate Activity Items
            ...List.generate(
              state.recheckHistoryModel?.moderateActivityItems?.length ?? 0,
              (index) {
                final item =
                    state.recheckHistoryModel?.moderateActivityItems?[index];
                return ActivityItemWidget(
                  model: item!,
                  onTap: () {
                    _onTapActivityItem(context, item);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Handles activity item tap
  void _onTapActivityItem(BuildContext context, ActivityItemModel item) {
    // Handle activity item selection
    ref.read(recheckHistoryNotifier.notifier).onActivityItemTapped(item);
  }
}
