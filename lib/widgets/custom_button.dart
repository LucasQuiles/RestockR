import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// Custom button component that supports various styling variants
/// including filled, outlined, and text-only buttons with optional icons
///
/// @param text - Button text content
/// @param onPressed - Callback function when button is pressed
/// @param variant - Button style variant (filled, outlined, text)
/// @param backgroundColor - Background color of the button
/// @param textColor - Text color of the button
/// @param borderColor - Border color for outlined buttons
/// @param fontSize - Font size of the button text
/// @param fontWeight - Font weight of the button text
/// @param borderRadius - Border radius of the button
/// @param padding - Internal padding of the button
/// @param margin - External margin of the button
/// @param width - Width of the button
/// @param height - Height of the button
/// @param alignment - Text alignment within the button
/// @param leftIcon - Left side icon path
/// @param rightIcon - Right side icon path
/// @param iconSize - Size of the icons
class CustomButton extends StatelessWidget {
  CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.leftIcon,
    this.rightIcon,
    this.iconSize,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant? variant;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final TextAlign? alignment;
  final String? leftIcon;
  final String? rightIcon;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final buttonVariant = variant ?? CustomButtonVariant.filled;
    final buttonTextColor = textColor ?? _getDefaultTextColor(buttonVariant);
    final buttonBackgroundColor =
        backgroundColor ?? _getDefaultBackgroundColor(buttonVariant);
    final buttonBorderColor =
        borderColor ?? _getDefaultBorderColor(buttonVariant);
    final buttonFontSize = fontSize ?? 14.0;
    final buttonFontWeight = fontWeight ?? FontWeight.w500;
    final buttonBorderRadius = borderRadius ?? 6.0;
    final buttonPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 30.h, vertical: 6.h);
    final textAlignment = alignment ?? TextAlign.center;
    final buttonIconSize = iconSize ?? 18.0;

    final buttonTextStyle = TextStyleHelper.instance.bodyTextInter.copyWith(
      color: buttonTextColor,
      fontSize: buttonFontSize,
      fontWeight: buttonFontWeight,
    );

    Widget buttonChild = _buildButtonContent(
      buttonTextStyle,
      textAlignment,
      buttonIconSize,
    );

    switch (buttonVariant) {
      case CustomButtonVariant.filled:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonTextColor,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius.h),
            ),
            elevation: 0,
            shadowColor: appTheme.transparentCustom,
          ),
          child: buttonChild,
        );
      case CustomButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonTextColor,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius.h),
            ),
            side: BorderSide(color: buttonBorderColor, width: 1),
          ),
          child: buttonChild,
        );
      case CustomButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonTextColor,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius.h),
            ),
          ),
          child: buttonChild,
        );
    }
  }

  Widget _buildButtonContent(
    TextStyle textStyle,
    TextAlign textAlignment,
    double iconSize,
  ) {
    List<Widget> children = [];

    if (leftIcon != null) {
      children.add(
        CustomImageView(
          imagePath: leftIcon!,
          height: iconSize.h,
          width: iconSize.h,
        ),
      );
      children.add(SizedBox(width: 8.h));
    }

    children.add(
      Flexible(
        child: Text(
          text,
          textAlign: textAlignment,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (rightIcon != null) {
      children.add(SizedBox(width: 8.h));
      children.add(
        CustomImageView(
          imagePath: rightIcon!,
          height: iconSize.h,
          width: iconSize.h,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Color _getDefaultTextColor(CustomButtonVariant variant) {
    switch (variant) {
      case CustomButtonVariant.filled:
        return appTheme.whiteCustom;
      case CustomButtonVariant.outlined:
        return Color(0xFF000000);
      case CustomButtonVariant.text:
        return Color(0xFF000000);
    }
  }

  Color _getDefaultBackgroundColor(CustomButtonVariant variant) {
    switch (variant) {
      case CustomButtonVariant.filled:
        return Color(0xFF059666);
      case CustomButtonVariant.outlined:
        return appTheme.transparentCustom;
      case CustomButtonVariant.text:
        return Color(0xFFF4F4F4);
    }
  }

  Color _getDefaultBorderColor(CustomButtonVariant variant) {
    switch (variant) {
      case CustomButtonVariant.filled:
        return appTheme.transparentCustom;
      case CustomButtonVariant.outlined:
        return Color(0xFF059666);
      case CustomButtonVariant.text:
        return appTheme.transparentCustom;
    }
  }
}

enum CustomButtonVariant {
  filled,
  outlined,
  text,
}
