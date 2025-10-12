import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * A customizable AppBar component that provides a consistent header layout
 * with title and action buttons. Implements PreferredSizeWidget for proper
 * AppBar integration.
 * 
 * Features:
 * - Customizable title text with consistent styling
 * - Support for multiple action buttons
 * - Optional leading widget
 * - Responsive design with SizeUtils
 * - Consistent background and styling
 */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.centerTitle,
    this.elevation,
  }) : super(key: key);

  /// The primary title text displayed in the AppBar
  final String? title;

  /// Widget to display before the title (typically back button)
  final Widget? leading;

  /// List of action widgets to display after the title
  final List<Widget>? actions;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Whether the title should be centered
  final bool? centerTitle;

  /// Shadow elevation of the AppBar
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.whiteCustom,
      elevation: elevation ?? 0,
      centerTitle: centerTitle ?? false,
      automaticallyImplyLeading: false,
      leading: leading,
      title: title != null
          ? Text(
              title!,
              style: TextStyleHelper.instance.headline24BoldInter
                  .copyWith(height: 1.25),
            )
          : null,
      actions: actions ?? _buildDefaultActions(),
      titleSpacing: leading == null ? 24.h : 0,
    );
  }

  /// Builds default action buttons based on the design patterns
  List<Widget> _buildDefaultActions() {
    return [
      _buildActionButton(
        iconPath: ImageConstant.imgIcons1,
        onTap: () {},
      ),
      SizedBox(width: 8.h),
      _buildActionButton(
        iconPath: ImageConstant.imgIcons1Gray900,
        onTap: () {},
      ),
      SizedBox(width: 16.h),
    ];
  }

  /// Builds individual action button with consistent styling
  Widget _buildActionButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.h),
      child: Container(
        width: 48.h,
        height: 48.h,
        decoration: BoxDecoration(
          color: appTheme.gray_100,
          borderRadius: BorderRadius.circular(12.h),
        ),
        padding: EdgeInsets.all(12.h),
        child: CustomImageView(
          imagePath: iconPath,
          height: 24.h,
          width: 24.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(96.h);
}

/// Custom action button data model for AppBar actions
class CustomAppBarAction {
  CustomAppBarAction({
    required this.iconPath,
    this.onTap,
    this.backgroundColor,
    this.size,
  });

  /// Path to the icon image
  final String iconPath;

  /// Callback function when button is tapped
  final VoidCallback? onTap;

  /// Background color of the action button
  final Color? backgroundColor;

  /// Size of the action button
  final double? size;
}
