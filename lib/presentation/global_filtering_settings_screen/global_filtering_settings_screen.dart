import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'notifier/global_filtering_settings_notifier.dart';

class GlobalFilteringSettingsScreen extends ConsumerStatefulWidget {
  GlobalFilteringSettingsScreen({Key? key}) : super(key: key);

  @override
  GlobalFilteringSettingsScreenState createState() =>
      GlobalFilteringSettingsScreenState();
}

class GlobalFilteringSettingsScreenState
    extends ConsumerState<GlobalFilteringSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        appBar: _buildAppBar(context),
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.only(
            top: 24.h,
            left: 16.h,
            right: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMinimumTargetSection(context),
              SizedBox(height: 24.h),
              _buildNewSkuCategoriesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56.h,
      title: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.h,
          vertical: 4.h,
        ),
        child: Row(
          children: [
            CustomIconButton(
              iconPath: ImageConstant.imgArrowLeft,
              backgroundColor: Colors.white,
              borderRadius: 12.h,
              height: 48.h,
              width: 48.h,
              padding: EdgeInsets.all(12.h),
              onTap: () => onTapBackButton(context),
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    'Global Filtering',
                    style: TextStyle(
                      fontSize: 18.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 22 / 18,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildMinimumTargetSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(globalFilteringSettingsNotifier);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.h,
          children: [
            Text(
              'Minimum Target Qty',
              style: TextStyle(
                fontSize: 14.fSize,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 17 / 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
            CustomTextFormField(
              controller: state.minimumTargetController,
              hintText: '12',
              borderColor: Color(0xFFCCCCCC),
              fillColor: Colors.white,
              borderRadius: 10.h,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.h,
                vertical: 14.h,
              ),
              textStyle: TextStyle(
                fontSize: 14.fSize,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 17 / 14,
                color: Color(0xFF1A1A1A),
              ),
              onChanged: (value) {
                ref
                    .read(globalFilteringSettingsNotifier.notifier)
                    .updateMinimumTarget(value);
              },
            ),
          ],
        );
      },
    );
  }

  /// Section Widget
  Widget _buildNewSkuCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New SKU Auto Open Categories',
          style: TextStyle(
            fontSize: 14.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 17 / 14,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 6.h),
        _buildCategoriesList(context),
      ],
    );
  }

  /// Section Widget
  Widget _buildCategoriesList(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(globalFilteringSettingsNotifier);
        final categories = state.globalFilteringSettingsModel?.categories ?? [];

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.h,
            vertical: 16.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Column(
            children: List.generate(categories.length, (index) {
              final category = categories[index];
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name ?? '',
                          style: TextStyle(
                            fontSize: 14.fSize,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 17 / 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Switch(
                          value: category.isEnabled ?? false,
                          onChanged: (value) {
                            ref
                                .read(globalFilteringSettingsNotifier.notifier)
                                .toggleCategory(index, value);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Color(0xFFEF4444),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Color(0xFFE5E5E5),
                        ),
                      ],
                    ),
                  ),
                  if (index < categories.length - 1)
                    Container(
                      height: 1.h,
                      margin: EdgeInsets.only(
                        top: 16.h,
                        bottom: 16.h,
                        right: 8.h,
                      ),
                      color: Color(0xFFF4F4F4),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// Navigates back to the previous screen.
  void onTapBackButton(BuildContext context) {
    NavigatorService.goBack();
  }
}
