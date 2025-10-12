import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * A customizable icon button widget with background styling and tap handling.
 * 
 * This widget provides a consistent icon button with configurable icon,
 * background color, border radius, and tap callback functionality.
 * 
 * @param iconPath - Path to the icon/SVG file
 * @param onTap - Callback function triggered when button is tapped
 * @param backgroundColor - Background color of the button
 * @param borderRadius - Border radius of the button background
 * @param height - Height of the button
 * @param width - Width of the button
 * @param padding - Internal padding of the button
 */
class CustomIconButton extends StatelessWidget {
  CustomIconButton({
    Key? key,
    required this.iconPath,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.height,
    this.width,
    this.padding,
  }) : super(key: key);

  /// Path to the icon/SVG file to be displayed
  final String iconPath;

  /// Callback function triggered when the button is tapped
  final VoidCallback? onTap;

  /// Background color of the button
  final Color? backgroundColor;

  /// Border radius of the button background
  final double? borderRadius;

  /// Height of the button
  final double? height;

  /// Width of the button
  final double? width;

  /// Internal padding of the button
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 48.h,
        width: width ?? 48.h,
        padding: padding ?? EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(borderRadius ?? 12.h),
        ),
        child: CustomImageView(
          imagePath: iconPath,
          height: 24.h,
          width: 24.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
