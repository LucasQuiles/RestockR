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
    final accentColor = _getAccentColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(color: appTheme.gray_300, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: accentColor.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Text(
                model.time ?? '',
                style: TextStyleHelper.instance.body12SemiBoldInter
                    .copyWith(color: accentColor),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.status ?? '',
                    style: TextStyleHelper.instance.body14MediumInter
                        .copyWith(color: appTheme.gray_900),
                  ),
                  if ((model.quantity ?? '').isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        model.quantity ?? '',
                        style: TextStyleHelper.instance.body12MediumInter
                            .copyWith(color: appTheme.gray_600),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: appTheme.gray_500,
              size: 20.h,
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (model.activityType) {
      case ActivityType.high:
        return appTheme.red_500;
      case ActivityType.moderate:
        return appTheme.teal_600;
      case ActivityType.none:
      default:
        return appTheme.gray_600;
    }
  }
}
