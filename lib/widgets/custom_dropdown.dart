import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// A customizable dropdown component with validation support
///
/// This widget provides a dropdown selection interface with configurable
/// styling, validation, and icon customization options.
///
/// Arguments:
/// - [hintText]: Placeholder text displayed when no item is selected
/// - [items]: List of dropdown items to display
/// - [value]: Currently selected value
/// - [onChanged]: Callback function triggered when selection changes
/// - [validator]: Optional validation function for form validation
/// - [iconPath]: Path to the dropdown arrow icon
/// - [width]: Width constraint for the dropdown (as percentage string like "44%")
/// - [contentPadding]: Custom padding for the dropdown content
class CustomDropdown extends StatelessWidget {
  CustomDropdown({
    Key? key,
    this.hintText,
    this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.iconPath,
    this.width,
    this.contentPadding,
  }) : super(key: key);

  /// Placeholder text shown when no item is selected
  final String? hintText;

  /// List of dropdown items
  final List<String>? items;

  /// Currently selected value
  final String? value;

  /// Callback function when selection changes
  final Function(String?)? onChanged;

  /// Validation function for form validation
  final String? Function(String?)? validator;

  /// Path to the dropdown arrow icon
  final String? iconPath;

  /// Width constraint as percentage string (e.g., "44%")
  final String? width;

  /// Custom content padding
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? "100%";
    final widthPercentage =
        double.tryParse(effectiveWidth.replaceAll('%', '')) ?? 100;
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownWidth = (screenWidth * widthPercentage / 100);

    return SizedBox(
      width: dropdownWidth,
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(
          hintText ?? "Select an option",
          style: TextStyleHelper.instance.title16SemiBoldInter
              .copyWith(height: 1.25),
        ),
        items: (items ?? []).map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyleHelper.instance.title16SemiBoldInter
                  .copyWith(height: 1.25),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: contentPadding ??
              EdgeInsets.only(
                top: 12.h,
                right: 36.h,
                bottom: 12.h,
                left: 12.h,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.colorFFE0E0,
              width: 1.h,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.colorFFE0E0,
              width: 1.h,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.gray_900,
              width: 1.h,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.all(12.h),
            child: CustomImageView(
              imagePath: iconPath ?? ImageConstant.imgFrameBlack900,
              height: 24.h,
              width: 24.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
        icon: Container(), // Hide default dropdown icon
        dropdownColor: appTheme.whiteCustom,
        style: TextStyleHelper.instance.title16SemiBoldInter
            .copyWith(height: 1.25),
      ),
    );
  }
}
