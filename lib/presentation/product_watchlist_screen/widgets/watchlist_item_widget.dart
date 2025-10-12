import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/watchlist_item_model.dart';

class WatchlistItemWidget extends StatelessWidget {
  final WatchlistItemModel? watchlistItem;
  final VoidCallback? onTapSubscribe;

  const WatchlistItemWidget({
    Key? key,
    this.watchlistItem,
    this.onTapSubscribe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        border: Border.all(color: appTheme.gray_300, width: 1.h),
        borderRadius: BorderRadius.circular(16.h),
      ),
      padding: EdgeInsets.all(16.h),
      child: Column(
        spacing: 8.h,
        children: [
          _buildSkuSection(context),
          _buildDivider(context),
          _buildProductInfo(context),
          _buildSubscribeButton(context),
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

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1.h,
      width: double.infinity,
      color: appTheme.gray_100,
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Row(
      children: [
        CustomImageView(
          imagePath: watchlistItem?.productImage ?? '',
          height: 48.h,
          width: 48.h,
          fit: BoxFit.cover,
        ),
        SizedBox(width: 8.h),
        Expanded(
          flex: 44,
          child: Text(
            watchlistItem?.productName ?? '',
            style: TextStyleHelper.instance.title16MediumInter
                .copyWith(color: appTheme.gray_900),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return CustomButton(
      text: 'Subscribe',
      onPressed: onTapSubscribe,
      variant: CustomButtonVariant.text,
      textColor: appTheme.teal_600,
      backgroundColor: appTheme.gray_100,
      borderRadius: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 6.h),
    );
  }
}
