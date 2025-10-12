import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/subscription_item_model.dart';

class SubscriptionItemWidget extends StatelessWidget {
  final SubscriptionItemModel model;
  final VoidCallback? onUnsubscribe;

  const SubscriptionItemWidget({
    Key? key,
    required this.model,
    this.onUnsubscribe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        border: Border.all(color: appTheme.gray_300),
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        spacing: 8.h,
        children: [
          _buildSkuRow(context),
          _buildDivider(context),
          _buildProductRow(context),
          _buildUnsubscribeButton(context),
        ],
      ),
    );
  }

  Widget _buildSkuRow(BuildContext context) {
    return Row(
      children: [
        Text(
          'SKU:',
          style: TextStyleHelper.instance.body12MediumInter,
        ),
        Text(
          model.sku ?? '',
          style: TextStyleHelper.instance.body12MediumInter
              .copyWith(color: appTheme.gray_900),
        ),
        Spacer(),
        CustomImageView(
          imagePath: model.storeIcon ?? '',
          height: 18.h,
          width: 18.h,
          radius: BorderRadius.circular(8.h),
        ),
        SizedBox(width: 6.h),
        Text(
          model.storeName ?? '',
          style: TextStyleHelper.instance.body12SemiBoldInter,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1.h,
      color: appTheme.gray_100,
    );
  }

  Widget _buildProductRow(BuildContext context) {
    return Row(
      children: [
        CustomImageView(
          imagePath: model.productImage ?? '',
          height: 48.h,
          width: 48.h,
          radius: BorderRadius.circular(24.h),
        ),
        SizedBox(width: 8.h),
        Expanded(
          child: Text(
            model.productName ?? '',
            style: TextStyleHelper.instance.title16MediumInter
                .copyWith(color: appTheme.gray_900, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildUnsubscribeButton(BuildContext context) {
    return CustomButton(
      text: 'Unsubscribe',
      onPressed: onUnsubscribe,
      variant: CustomButtonVariant.outlined,
      textColor: appTheme.red_500,
      borderColor: appTheme.red_500,
      borderRadius: 6.0,
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 6.h),
    );
  }
}
