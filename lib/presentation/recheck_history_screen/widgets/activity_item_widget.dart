import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/recheck_history_model.dart';

// Modified: Removed import to non-existent file and use existing model

class ActivityItemWidget extends StatelessWidget {
  final ActivityItemModel model;
  final VoidCallback? onTap;

  ActivityItemWidget({
    Key? key,
    required this.model,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: (model.time?.length ?? 0) > 4 ? 16.h : 14.h,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: appTheme.color330000,
                borderRadius: BorderRadius.circular(16.h),
              ),
              child: Text(
                model.time ?? '',
                style: TextStyleHelper.instance.body14MediumInter
                    .copyWith(color: _getTimeTextColor()),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 14.h, bottom: 6.h),
                child: Text(
                  model.status ?? '',
                  style: TextStyleHelper.instance.body14MediumInter
                      .copyWith(color: _getStatusTextColor()),
                ),
              ),
            ),
            if (model.quantity != null)
              Padding(
                padding: EdgeInsets.only(right: 14.h, bottom: 6.h),
                child: Text(
                  model.quantity ?? '',
                  style: TextStyleHelper.instance.body14MediumInter
                      .copyWith(color: _getStatusTextColor()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (model.activityType) {
      case ActivityType.high:
        return model.isFirstHour == true
            ? Color(0xFF064E36)
            : model.isSecondHour == true
                ? Color(0xFF047852)
                : Color(0xFF059666);
      case ActivityType.moderate:
        return Color(0xFF10B981);
      case ActivityType.none:
      default:
        return Color(0xFF6EE7BF);
    }
  }

  Color _getTimeTextColor() {
    switch (model.activityType) {
      case ActivityType.high:
        return appTheme.whiteCustom;
      case ActivityType.moderate:
      case ActivityType.none:
      default:
        return Color(0xFF022C1E);
    }
  }

  Color _getStatusTextColor() {
    switch (model.activityType) {
      case ActivityType.high:
        return appTheme.whiteCustom;
      case ActivityType.moderate:
      case ActivityType.none:
      default:
        return Color(0xFF022C1E);
    }
  }
}
