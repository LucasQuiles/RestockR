import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/history/models/history_alert.dart';
import '../../../widgets/custom_image_view.dart';

/// Modal that displays detailed restock alerts for a specific hour
class HistoryDetailModal extends StatelessWidget {
  final DateTime selectedDate;
  final int hour;
  final List<HistoryAlert> alerts;

  const HistoryDetailModal({
    Key? key,
    required this.selectedDate,
    required this.hour,
    required this.alerts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.h),
          topRight: Radius.circular(24.h),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildDivider(context),
          Flexible(
            child: _buildAlertsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateStr = DateTimeUtils.formatFullDate(selectedDate);
    final hourStr = hour.toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.h,
              height: 4.h,
              decoration: BoxDecoration(
                color: appTheme.gray_300,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Title
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restock Details',
                      style: TextStyleHelper.instance.title18BoldInter
                          .copyWith(color: appTheme.black_900),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$dateStr at $hourStr:00',
                      style: TextStyleHelper.instance.body14MediumInter
                          .copyWith(color: appTheme.gray_600),
                    ),
                  ],
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.h),
                  decoration: BoxDecoration(
                    color: appTheme.gray_100,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.h,
                    color: appTheme.gray_900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Alert count
          Text(
            '${alerts.length} ${alerts.length == 1 ? 'alert' : 'alerts'}',
            style: TextStyleHelper.instance.body12MediumInter
                .copyWith(color: appTheme.gray_500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1.h,
      color: appTheme.gray_200,
    );
  }

  Widget _buildAlertsList(BuildContext context) {
    if (alerts.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.h),
      shrinkWrap: true,
      itemCount: alerts.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(context, alert);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.h,
              color: appTheme.gray_500,
            ),
            SizedBox(height: 16.h),
            Text(
              'No alerts found',
              style: TextStyleHelper.instance.body14MediumInter
                  .copyWith(color: appTheme.gray_600),
            ),
            SizedBox(height: 8.h),
            Text(
              'There were no restocks during this hour.',
              style: TextStyleHelper.instance.body14MediumInter
                  .copyWith(color: appTheme.gray_500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, HistoryAlert alert) {
    final timeStr = DateTimeUtils.formatTime(alert.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.gray_300, width: 1.h),
      ),
      padding: EdgeInsets.all(12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            timeStr,
            style: TextStyleHelper.instance.label10MediumInter
                .copyWith(color: appTheme.gray_500),
          ),
          SizedBox(height: 8.h),
          // Product info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (alert.image != null && alert.image!.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(right: 12.h),
                  child: CustomImageView(
                    imagePath: alert.image!,
                    height: 48.h,
                    width: 48.h,
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(8.h),
                  ),
                )
              else
                Container(
                  margin: EdgeInsets.only(right: 12.h),
                  height: 48.h,
                  width: 48.h,
                  decoration: BoxDecoration(
                    color: appTheme.gray_100,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 24.h,
                    color: appTheme.gray_500,
                  ),
                ),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.product,
                      style: TextStyleHelper.instance.body14MediumInter
                          .copyWith(color: appTheme.gray_900),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      alert.store.toUpperCase(),
                      style: TextStyleHelper.instance.body12SemiBoldInter
                          .copyWith(color: appTheme.gray_600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Store, SKU, and Price
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  context,
                  'SKU',
                  alert.sku,
                ),
              ),
              SizedBox(width: 8.h),
              if (alert.price != null)
                Expanded(
                  child: _buildInfoChip(
                    context,
                    'Price',
                    '\$${alert.price!.toStringAsFixed(2)}',
                  ),
                ),
            ],
          ),
          // Reactions (if any)
          if (alert.yesReactions > 0 || alert.noReactions > 0) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                if (alert.yesReactions > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.h,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: appTheme.teal_600.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(4.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thumb_up,
                          size: 14.h,
                          color: appTheme.teal_600,
                        ),
                        SizedBox(width: 4.h),
                        Text(
                          '${alert.yesReactions}',
                          style: TextStyleHelper.instance.body12SemiBoldInter
                              .copyWith(color: appTheme.teal_600),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 8.h),
                if (alert.noReactions > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.h,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: appTheme.red_500.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(4.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thumb_down,
                          size: 14.h,
                          color: appTheme.red_500,
                        ),
                        SizedBox(width: 4.h),
                        Text(
                          '${alert.noReactions}',
                          style: TextStyleHelper.instance.body12SemiBoldInter
                              .copyWith(color: appTheme.red_500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 6.h),
      decoration: BoxDecoration(
        color: appTheme.gray_100,
        borderRadius: BorderRadius.circular(6.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyleHelper.instance.body12MediumInter
                .copyWith(color: appTheme.gray_500),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyleHelper.instance.body12SemiBoldInter
                  .copyWith(color: appTheme.gray_900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
