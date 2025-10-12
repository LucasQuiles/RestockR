import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomTextFormField is a reusable text input component that supports various configurations
 * including password fields, custom styling, validation, and suffix icons.
 * 
 * @param controller - TextEditingController for managing text input
 * @param hintText - Placeholder text displayed when field is empty
 * @param isPassword - Boolean to determine if field should obscure text
 * @param suffixIcon - Optional widget to display at the end of the field
 * @param validator - Function to validate input text
 * @param onChanged - Callback function triggered when text changes
 * @param keyboardType - Type of keyboard to display
 * @param onTap - Callback function triggered when field is tapped
 * @param enabled - Boolean to enable/disable the field
 * @param maxLines - Maximum number of lines for the field
 * @param textStyle - Custom text style for input text
 * @param hintStyle - Custom text style for hint text
 * @param fillColor - Background color of the field
 * @param borderColor - Color of the field border
 * @param focusedBorderColor - Color of the border when field is focused
 * @param borderRadius - Border radius of the field
 * @param contentPadding - Internal padding of the field
 */
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    Key? key,
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final bool isPassword;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool enabled;
  final int maxLines;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_isPasswordVisible,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      style: widget.textStyle ??
          TextStyleHelper.instance.body14MediumInter
              .copyWith(color: appTheme.gray_900),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ??
            TextStyleHelper.instance.body14MediumInter
                .copyWith(color: Color(0xFF1A1A1A).withAlpha(128)),
        filled: true,
        fillColor: widget.fillColor ?? appTheme.whiteCustom,
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 14.h,
            ),
        suffixIcon: _buildSuffixIcon(),
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildFocusedBorder(),
        disabledBorder: _buildBorder(),
        errorBorder: _buildErrorBorder(),
        focusedErrorBorder: _buildErrorBorder(),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: CustomImageView(
          imagePath: _isPasswordVisible
              ? ImageConstant.imgEyeOpen
              : ImageConstant.imgIcons,
          height: 20.h,
          width: 20.h,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.h),
      borderSide: BorderSide(
        color: widget.borderColor ?? Color(0xFFE6E6E6),
        width: 1.h,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.h),
      borderSide: BorderSide(
        color: widget.focusedBorderColor ?? Color(0xFF1A1A1A),
        width: 1.h,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.h),
      borderSide: BorderSide(
        color: appTheme.redCustom,
        width: 1.h,
      ),
    );
  }
}
