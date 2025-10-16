import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_search_view.dart';
import './models/recheck_history_model.dart';
import './widgets/activity_item_widget.dart';
import './widgets/history_detail_modal.dart';
import './widgets/heatmap_calendar.dart';
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
        body: Column(
          children: [
            _buildHeaderSection(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
                child: _buildContentSection(context),
              ),
            ),
          ],
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
            onTap: () {
              NavigatorService.pushNamed(
                  AppRoutes.notificationsAlertsSettingsScreen);
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
              NavigatorService.pushNamed(AppRoutes.profileSettingsScreen);
            },
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomSearchView(
              hintText: "Search",
              prefixIconPath: ImageConstant.imgSearch,
              backgroundColor: appTheme.gray_100,
              borderRadius: 12.h,
            ),
          ),
          SizedBox(width: 8.h),
          CustomIconButton(
            iconPath: ImageConstant.imgIcons1Black900,
            backgroundColor: appTheme.gray_100,
            borderRadius: 12.h,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            onTap: () {
              NavigatorService.pushNamed(
                  AppRoutes.globalFilteringSettingsScreen);
            },
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCalendarSection(context),
        SizedBox(height: 20.h),
        _buildActivityListSection(context),
      ],
    );
  }

  /// Section Widget
  Widget _buildCalendarSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(recheckHistoryNotifier);
        final selectedDate =
            state.recheckHistoryModel?.selectedDate ?? DateTime.now();
        final firstDate = DateTime(2020);
        final lastDate = DateTime(2030);

        DateTime clampedDate = selectedDate;
        if (clampedDate.isBefore(firstDate)) {
          clampedDate = firstDate;
        } else if (clampedDate.isAfter(lastDate)) {
          clampedDate = lastDate;
        }

        return HeatmapCalendar(
          selectedDate: clampedDate,
          firstDate: firstDate,
          lastDate: lastDate,
          dailyActivityMap: state.dailyActivityMap,
          onDateChanged: (date) {
            ref.read(recheckHistoryNotifier.notifier).onDateChanged(date);
          },
        );
      },
    );
  }

  /// Section Widget
  Widget _buildActivityListSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.gray_300, width: 1),
      ),
      padding: EdgeInsets.all(12.h),
      child: Column(
        children: [
          _buildTableHeader(context),
          SizedBox(height: 12.h),
          _buildActivityList(context),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildTableHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: Row(
        children: [
          Text(
            "Time",
            style: TextStyleHelper.instance.body12SemiBoldInter
                .copyWith(color: appTheme.gray_600),
          ),
          SizedBox(width: 20.h),
          Expanded(
            child: Text(
              "Status",
              style: TextStyleHelper.instance.body12SemiBoldInter
                  .copyWith(color: appTheme.gray_600),
            ),
          ),
          Text(
            "Qty",
            style: TextStyleHelper.instance.body12SemiBoldInter
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
          spacing: 8.h,
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
  void _onTapActivityItem(BuildContext context, ActivityItemModel item) async {
    // Trigger the notifier to fetch details
    await ref.read(recheckHistoryNotifier.notifier).onActivityItemTapped(item);

    // Get the current state after fetching
    final state = ref.read(recheckHistoryNotifier);

    // Show the modal with the fetched details
    if (state.historyDetails != null && !state.isLoadingDetails!) {
      _showHistoryDetailModal(context, item);
    } else if (state.detailsError != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.detailsError ?? 'Failed to load details'),
          backgroundColor: appTheme.red_500,
        ),
      );
    }
  }

  /// Shows the history detail modal
  void _showHistoryDetailModal(BuildContext context, ActivityItemModel item) {
    final state = ref.read(recheckHistoryNotifier);
    final selectedDate = state.recheckHistoryModel?.selectedDate ?? DateTime.now();

    // Extract hour from time string
    final timeStr = item.time ?? '0:00';
    final hour = int.tryParse(timeStr.split(':')[0]) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => HistoryDetailModal(
          selectedDate: selectedDate,
          hour: hour,
          alerts: state.historyDetails ?? [],
        ),
      ),
    );
  }
}
