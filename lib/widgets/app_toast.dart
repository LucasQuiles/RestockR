import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_export.dart';

enum AppToastVariant { success, error, warning, info }

void showAppToast(
  BuildContext context, {
  required String message,
  AppToastVariant variant = AppToastVariant.info,
  Duration duration = const Duration(milliseconds: 2200),
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  Color baseColor = appTheme.gray_900;
  IconData leadingIcon = Icons.info_rounded;
  switch (variant) {
    case AppToastVariant.success:
      baseColor = appTheme.teal_600;
      leadingIcon = Icons.check_rounded;
      break;
    case AppToastVariant.error:
      baseColor = appTheme.red_500;
      leadingIcon = Icons.error_outline;
      break;
    case AppToastVariant.warning:
      baseColor = Color(0xFFFFC107);
      leadingIcon = Icons.warning_amber_rounded;
      break;
    case AppToastVariant.info:
      break;
  }

  scaffoldMessenger.clearSnackBars();

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: baseColor.withAlpha((0.22 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: baseColor.withAlpha((0.35 * 255).round())),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  leadingIcon,
                  color: baseColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyleHelper.instance.body14MediumInter
                        .copyWith(color: appTheme.white_A700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
    ),
  );
}
