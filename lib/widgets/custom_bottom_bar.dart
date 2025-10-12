import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomBottomBar - A reusable bottom navigation bar component
 * 
 * Features:
 * - Four navigation items: Dashboard, Monitor, History, Watchlist
 * - Active state with red background and text color
 * - Inactive state with gray icons and text
 * - Shadow effect and rounded top corners
 * - Responsive design with proper spacing
 * 
 * @param bottomBarItemList List of navigation items
 * @param selectedIndex Currently selected tab index
 * @param onChanged Callback function when tab is tapped
 */
class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({
    Key? key,
    required this.bottomBarItemList,
    required this.onChanged,
    this.selectedIndex = 0,
  }) : super(key: key);

  /// List of bottom bar items with their properties
  final List<CustomBottomBarItem> bottomBarItemList;

  /// Current selected index of the bottom bar
  final int selectedIndex;

  /// Callback function triggered when a bottom bar item is tapped
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(38.h, 12.h, 38.h, 12.h),
      decoration: BoxDecoration(
        color: appTheme.whiteCustom,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.h),
          topRight: Radius.circular(24.h),
        ),
        border: Border(
          top: BorderSide(
            color: appTheme.gray_300,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.color190000,
            offset: Offset(0, -4),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(bottomBarItemList.length, (index) {
          final isSelected = selectedIndex == index;
          final item = bottomBarItemList[index];

          return Expanded(
            child: InkWell(
              onTap: () {
                onChanged(index);
              },
              child: _buildBottomBarItem(item, isSelected),
            ),
          );
        }),
      ),
    );
  }

  /// Builds individual bottom bar item widget
  Widget _buildBottomBarItem(CustomBottomBarItem item, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: isSelected ? 28.h : null,
          width: isSelected ? 44.h : null,
          decoration: isSelected
              ? BoxDecoration(
                  color: appTheme.red_50,
                  borderRadius: BorderRadius.circular(14.h),
                )
              : null,
          child: Center(
            child: CustomImageView(
              imagePath: isSelected ? item.activeIcon : item.icon,
              height: 20.h,
              width: 20.h,
            ),
          ),
        ),
        SizedBox(height: isSelected ? 2.h : 6.h),
        Text(
          item.title ?? '',
          style: TextStyleHelper.instance.label11MediumInter.copyWith(
              color: isSelected ? Color(0xFFEF4444) : appTheme.gray_600,
              height: 1.27),
        ),
      ],
    );
  }
}

/// Data model for custom bottom bar items
class CustomBottomBarItem {
  CustomBottomBarItem({
    this.icon,
    this.activeIcon,
    this.title,
    this.routeName,
  });

  /// Path to the inactive state icon
  final String? icon;

  /// Path to the active state icon
  final String? activeIcon;

  /// Title text displayed below the icon
  final String? title;

  /// Route name for navigation
  final String? routeName;
}
