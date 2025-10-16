import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/profile_settings_notifier.dart';
import '../help_tutorial_screen/help_tutorial_modal.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  ProfileSettingsScreenState createState() => ProfileSettingsScreenState();
}

class ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_100,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            _buildProfileContent(context),
          ],
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
              backgroundColor: Colors.white,
              borderRadius: 12.h,
              height: 48.h,
              width: 48.h,
              padding: EdgeInsets.all(12.h),
              onTap: () {
                onTapBackButton(context);
              },
            ),
            Container(
              margin: EdgeInsets.only(left: 94.h),
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 18.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildProfileContent(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileCard(context),
            SizedBox(height: 16.h),
            Text(
              'General',
              style: TextStyle(
                color: Color(0xFF21252B),
                fontSize: 18.fSize,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            _buildSettingsMenuCard(context),
            SizedBox(height: 16.h),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildUserProfileCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(profileSettingsNotifier);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.h),
          ),
          child: Row(
            children: [
              CustomIconButton(
                iconPath: ImageConstant.imgIcons1Red500,
                backgroundColor: Color(0xFFF4F4F4),
                borderRadius: 20.h,
                height: 40.h,
                width: 40.h,
                padding: EdgeInsets.all(8.h),
              ),
              SizedBox(width: 8.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.profileSettingsModel?.userName ?? 'John Smith',
                      style: TextStyle(
                        color: Color(0xFF21252B),
                        fontSize: 16.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state.profileSettingsModel?.userEmail ??
                          'johnsmith@gmail.com',
                      style: TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 14.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CustomImageView(
                imagePath: ImageConstant.imgIconsBlack900,
                height: 24.h,
                width: 24.h,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildSettingsMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        children: [
          _buildMenuRow(
            context,
            iconPath: ImageConstant.imgRightIcon,
            title: 'Notifications & Alerts',
            onTap: () {
              onTapNotificationsAlerts(context);
            },
          ),
          _buildMenuRow(
            context,
            iconPath: ImageConstant.imgIcons1Red50024x24,
            title: 'Global Filtering',
            onTap: () {
              onTapGlobalFiltering(context);
            },
          ),
          _buildMenuRow(
            context,
            iconPath: ImageConstant.imgFrameRed500,
            title: 'Retailer-Specific Overrides',
            onTap: () {
              onTapRetailerOverrides(context);
            },
          ),
          _buildMenuRow(
            context,
            icon: Icons.help_outline,
            title: 'Help & Tutorial',
            isLast: true,
            onTap: () {
              onTapHelp(context);
            },
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildMenuRow(
    BuildContext context, {
    String? iconPath,
    IconData? icon,
    required String title,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Color(0xFFF4F4F4),
                    width: 1.h,
                  ),
                ),
        ),
        child: Row(
          children: [
            if (iconPath != null)
              CustomImageView(
                imagePath: iconPath,
                height: 24.h,
                width: 24.h,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24.h,
                color: Color(0xFFEF4444),
              ),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CustomImageView(
              imagePath: ImageConstant.imgArrowRight,
              height: 24.h,
              width: 24.h,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates back to the previous screen.
  void onTapBackButton(BuildContext context) {
    NavigatorService.goBack();
  }

  /// Navigates to notifications and alerts settings screen.
  void onTapNotificationsAlerts(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.notificationsAlertsSettingsScreen);
  }

  /// Navigates to global filtering settings screen.
  void onTapGlobalFiltering(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.globalFilteringSettingsScreen);
  }

  /// Navigates to retailer override settings screen.
  void onTapRetailerOverrides(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.retailerOverrideSettingsScreen);
  }

  /// Shows help and tutorial modal.
  void onTapHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpTutorialModal(),
    );
  }

  /// Section Widget
  Widget _buildLogoutButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(profileSettingsNotifier);

        return GestureDetector(
          onTap: state.isLoading == true
              ? null
              : () async {
                  await ref.read(profileSettingsNotifier.notifier).logout();
                  // Navigate to login screen after logout
                  NavigatorService.pushNamedAndRemoveUntil(
                    AppRoutes.loginScreen,
                  );
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
            decoration: BoxDecoration(
              color: Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20.h,
                ),
                SizedBox(width: 8.h),
                Text(
                  state.isLoading == true ? 'Logging out...' : 'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.fSize,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
