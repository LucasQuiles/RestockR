import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/monitor_item_model.dart';

class MonitorItemWidget extends StatelessWidget {
  final MonitorItemModel? model;
  final VoidCallback? onTapBuy;
  final VoidCallback? onTapDownVote;
  final VoidCallback? onTapUpVote;

  MonitorItemWidget({
    Key? key,
    this.model,
    this.onTapBuy,
    this.onTapDownVote,
    this.onTapUpVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.gray_300, width: 1.h),
      ),
      padding: EdgeInsets.all(14.h),
      child: Column(
        spacing: 8.h,
        children: [
          _buildDateTimeSection(context),
          _buildDivider(context),
          _buildProductSection(context),
          _buildDetailsSection(context),
          _buildVotingSection(context),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          model?.date ?? "",
          style: TextStyleHelper.instance.label10MediumInter,
        ),
        Text(
          model?.time ?? "",
          style: TextStyleHelper.instance.label10MediumInter,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1.h,
      width: double.maxFinite,
      color: appTheme.gray_100,
    );
  }

  Widget _buildProductSection(BuildContext context) {
    return Row(
      children: [
        CustomImageView(
          imagePath: model?.productImage ?? "",
          height: 48.h,
          width: 48.h,
          fit: BoxFit.cover,
        ),
        SizedBox(width: 8.h),
        Expanded(
          child: Text(
            model?.productTitle ?? "",
            style: TextStyleHelper.instance.body14MediumInter
                .copyWith(color: appTheme.gray_900, height: 1.57),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 28.h),
        GestureDetector(
          onTap: onTapBuy,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 4.h),
            decoration: BoxDecoration(
              color: appTheme.gray_100_01,
              borderRadius: BorderRadius.circular(6.h),
            ),
            child: Text(
              "Buy",
              style: TextStyleHelper.instance.body12SemiBoldInter
                  .copyWith(color: appTheme.indigo_A400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Row(
      spacing: 8.h,
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            "Store",
            Row(
              children: [
                CustomImageView(
                  imagePath: model?.storeIcon ?? "",
                  height: 18.h,
                  width: 18.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 6.h),
                Text(
                  model?.storeName ?? "",
                  style: TextStyleHelper.instance.body12SemiBoldInter,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _buildInfoCard(
            context,
            "Quantity",
            Text(
              model?.quantity ?? "",
              style: TextStyleHelper.instance.body12SemiBoldInter,
            ),
          ),
        ),
        Expanded(
          child: _buildInfoCard(
            context,
            "Price",
            Text(
              model?.price ?? "",
              style: TextStyleHelper.instance.body12SemiBoldInter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, Widget content) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.gray_300, width: 1.h),
        borderRadius: BorderRadius.circular(6.h),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyleHelper.instance.body12MediumInter
                .copyWith(color: appTheme.gray_500),
          ),
          SizedBox(height: 4.h),
          content,
        ],
      ),
    );
  }

  Widget _buildVotingSection(BuildContext context) {
    return Row(
      spacing: 8.h,
      children: [
        Expanded(
          child: _buildVoteButton(
            context,
            model?.downVoteCount?.toString() ?? "0",
            ImageConstant.imgFrame,
            appTheme.red_500,
            Color(0xFFEF4444),
            appTheme.transparentCustom,
            appTheme.black_900,
            onTapDownVote,
            isDownVote: true,
          ),
        ),
        Expanded(
          child: _buildVoteButton(
            context,
            model?.upVoteCount?.toString() ?? "0",
            ImageConstant.imgFrameTeal600,
            appTheme.teal_600,
            Color(0xFF059666),
            (model?.upVoteCount ?? 0) > 0
                ? Color(0xFF059666)
                : appTheme.transparentCustom,
            (model?.upVoteCount ?? 0) > 0
                ? Color(0xFFFFFFFF)
                : appTheme.black_900,
            onTapUpVote,
            isDownVote: false,
          ),
        ),
      ],
    );
  }

  Widget _buildVoteButton(
      BuildContext context,
      String count,
      String iconPath,
      Color borderColor,
      Color iconColor,
      Color backgroundColor,
      Color textColor,
      VoidCallback? onTap,
      {required bool isDownVote}) {
    final hasVotes = int.tryParse(count) != null && int.parse(count) > 0;
    final showBackground = isDownVote ? hasVotes : hasVotes;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: showBackground
              ? (isDownVote ? Color(0xFFEF4444) : appTheme.teal_600)
              : appTheme.transparentCustom,
          border: Border.all(color: borderColor, width: 1.h),
          borderRadius: BorderRadius.circular(6.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isDownVote && hasVotes) ...[
              CustomImageView(
                imagePath: ImageConstant.imgFrameWhiteA70018x18,
                height: 18.h,
                width: 18.h,
              ),
              SizedBox(width: 8.h),
            ],
            Text(
              count,
              style: TextStyleHelper.instance.body14SemiBoldInter.copyWith(
                  color:
                      showBackground ? Color(0xFFFFFFFF) : appTheme.black_900),
            ),
            if (isDownVote || !hasVotes) ...[
              SizedBox(width: 8.h),
              CustomImageView(
                imagePath: iconPath,
                height: 18.h,
                width: 18.h,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
