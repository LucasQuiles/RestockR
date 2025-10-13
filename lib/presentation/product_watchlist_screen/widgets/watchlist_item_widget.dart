import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/watchlist_item_model.dart';

class WatchlistItemWidget extends StatelessWidget {
  final WatchlistItemModel? watchlistItem;
  final ValueChanged<WatchlistItemModel>? onTapSubscribe;

  const WatchlistItemWidget({
    Key? key,
    this.watchlistItem,
    this.onTapSubscribe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSubscribed = watchlistItem?.isSubscribed ?? false;
    final accentColor = isSubscribed ? appTheme.red_500 : appTheme.teal_600;
    final double actionSize = (40.h).clamp(32.0, 48.0).toDouble();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        border: Border.all(color: appTheme.gray_300, width: 1.h),
        borderRadius: BorderRadius.circular(16.h),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkuSection(context),
                SizedBox(height: 6.h),
                _buildProductInfo(context),
              ],
            ),
          ),
          SizedBox(width: 6.h),
          _buildActionButton(context, accentColor, isSubscribed, actionSize),
        ],
      ),
    );
  }

  Widget _buildSkuSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SKU:',
          style: TextStyleHelper.instance.body12MediumInter,
        ),
        Text(
          watchlistItem?.sku ?? '',
          style: TextStyleHelper.instance.body12MediumInter
              .copyWith(color: appTheme.gray_900),
        ),
        Spacer(),
        CustomImageView(
          imagePath: watchlistItem?.storeIcon ?? '',
          height: 18.h,
          width: 18.h,
        ),
        SizedBox(width: 6.h),
        Text(
          watchlistItem?.storeName ?? '',
          style: TextStyleHelper.instance.body12SemiBoldInter,
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomImageView(
          imagePath: watchlistItem?.productImage ?? '',
          height: 52.h,
          width: 52.h,
          radius: BorderRadius.circular(12.h),
          fit: BoxFit.cover,
        ),
        SizedBox(width: 10.h),
        Expanded(
          child: Text(
            watchlistItem?.productName ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.body14MediumInter
                .copyWith(color: appTheme.gray_900, height: 1.28),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Color accentColor,
    bool isSubscribed,
    double actionSize,
  ) {
    return SizedBox(
      width: actionSize,
      height: actionSize,
      child: InkWell(
        onTap: watchlistItem == null
            ? null
            : () {
                onTapSubscribe?.call(watchlistItem!);
              },
        borderRadius: BorderRadius.circular(12.h),
        splashColor: accentColor.withAlpha((0.12 * 255).round()),
        child: Container(
          height: actionSize,
          width: actionSize,
          decoration: BoxDecoration(
            color: accentColor.withAlpha((0.08 * 255).round()),
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(color: accentColor, width: 1.1),
          ),
          child: Center(
            child: Icon(
              isSubscribed ? Icons.close : Icons.add,
              color: accentColor,
              size: 16.h,
            ),
          ),
        ),
      ),
    );
  }
}
