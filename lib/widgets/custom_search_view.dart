import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomSearchView - A reusable search input field component with customizable styling
 * 
 * Features:
 * - Built-in search icon with customizable image path
 * - Configurable placeholder text and styling
 * - Responsive design using SizeUtils
 * - Form validation support
 * - Customizable background color and border radius
 * - Flexible margin and padding options
 * 
 * @param controller - TextEditingController for managing input text
 * @param hintText - Placeholder text displayed when field is empty
 * @param prefixIconPath - Path to the search icon image
 * @param backgroundColor - Background fill color of the search field
 * @param borderRadius - Corner radius for the search field border
 * @param textStyle - Text style for input text
 * @param hintStyle - Text style for hint/placeholder text
 * @param margin - External spacing around the search field
 * @param validator - Function to validate input text
 * @param onChanged - Callback function triggered when text changes
 * @param onTap - Callback function triggered when field is tapped
 * @param enabled - Whether the search field is interactive
 */
class CustomSearchView extends StatelessWidget {
  CustomSearchView({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIconPath,
    this.backgroundColor,
    this.borderRadius,
    this.textStyle,
    this.hintStyle,
    this.margin,
    this.validator,
    this.onChanged,
    this.onTap,
    this.enabled,
  }) : super(key: key);

  /// Controller for managing the search input text
  final TextEditingController? controller;

  /// Placeholder text shown when the field is empty
  final String? hintText;

  /// Path to the search icon image (SVG or PNG)
  final String? prefixIconPath;

  /// Background color of the search field
  final Color? backgroundColor;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Text style for the input text
  final TextStyle? textStyle;

  /// Text style for the hint/placeholder text
  final TextStyle? hintStyle;

  /// External margin around the search field
  final EdgeInsets? margin;

  /// Validation function for form input
  final String? Function(String?)? validator;

  /// Callback when text changes
  final Function(String)? onChanged;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Whether the search field is enabled
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          EdgeInsets.only(
            left: 16.h,
            right: 16.h,
            bottom: 12.h,
          ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        enabled: enabled ?? true,
        style: textStyle ?? TextStyleHelper.instance.body14RegularInter,
        decoration: InputDecoration(
          hintText: hintText ?? "Search",
          hintStyle: hintStyle ??
              TextStyleHelper.instance.body14RegularInter
                  .copyWith(color: appTheme.gray_500),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.h),
            child: CustomImageView(
              imagePath: prefixIconPath ?? ImageConstant.imgSearch,
              height: 22.h,
              width: 24.h,
            ),
          ),
          filled: true,
          fillColor: backgroundColor ?? Color(0xFFF4F4F4),
          contentPadding: EdgeInsets.only(
            top: 12.h,
            right: 16.h,
            bottom: 12.h,
            left: 8.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.h),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.h),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.h),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
        ),
      ),
    );
  }
}
