import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/notifications_alerts_settings_notifier.dart';

class NotificationsAlertsSettingsScreen extends ConsumerStatefulWidget {
  NotificationsAlertsSettingsScreen({Key? key}) : super(key: key);

  @override
  NotificationsAlertsSettingsScreenState createState() =>
      NotificationsAlertsSettingsScreenState();
}

class NotificationsAlertsSettingsScreenState
    extends ConsumerState<NotificationsAlertsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_100,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 24.h),
          child: _buildNotificationSettings(context),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF4F4F4),
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56.h,
      titleSpacing: 0,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 4.h),
        child: Row(
          children: [
            CustomIconButton(
              iconPath: ImageConstant.imgArrowLeft,
              backgroundColor: Color(0xFFFFFFFF),
              borderRadius: 12.h,
              height: 48.h,
              width: 48.h,
              padding: EdgeInsets.all(12.h),
              onTap: () {
                onTapBackButton(context);
              },
            ),
            Container(
              margin: EdgeInsets.only(left: 16.h),
              child: Text(
                'Notifications & Alerts',
                style: TextStyle(
                  fontSize: 18.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.22,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildNotificationSettings(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageView(
              imagePath: ImageConstant.imgFrameBlack9001,
              height: 20.h,
              width: 20.h,
            ),
            Container(
              margin: EdgeInsets.only(left: 8.h),
              child: Text(
                'Enable Restock Sound Alert',
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.21,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            Spacer(),
            Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(notificationsAlertsSettingsNotifier);

                return Switch(
                  value: state.notificationsAlertsSettingsModel
                          ?.isRestockSoundEnabled ??
                      false,
                  onChanged: (value) {
                    ref
                        .read(notificationsAlertsSettingsNotifier.notifier)
                        .toggleRestockSoundAlert(value);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates back to the previous screen
  void onTapBackButton(BuildContext context) {
    NavigatorService.goBack();
  }
}
