import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/retailer_override_settings_notifier.dart';

class RetailerOverrideSettingsScreen extends ConsumerStatefulWidget {
  RetailerOverrideSettingsScreen({Key? key}) : super(key: key);

  @override
  RetailerOverrideSettingsScreenState createState() =>
      RetailerOverrideSettingsScreenState();
}

class RetailerOverrideSettingsScreenState
    extends ConsumerState<RetailerOverrideSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        appBar: _buildAppBar(context),
        body: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 24.h,
                      left: 16.h,
                      right: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPokemonCenterSection(context),
                        _buildQueueDelaySection(context),
                        _buildReopenCooldownSection(context),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSaveSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56.h,
      leadingWidth: double.infinity,
      leading: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.h,
          vertical: 4.h,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => onTapBackButton(context),
              child: Container(
                height: 48.h,
                width: 48.h,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.imgArrowLeft,
                  height: 24.h,
                  width: 24.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: 16.h,
                  bottom: 8.h,
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Retailer-Specific Overrides",
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 18.fSize,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildPokemonCenterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.h,
      children: [
        Text(
          "Pokémon Center Queue",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 14.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.21,
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Auto Open Pokémon Center Queue",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.21,
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(retailerOverrideSettingsNotifier);
                  return Switch(
                    value: state.isAutoOpenEnabled ?? false,
                    onChanged: (value) {
                      ref
                          .read(retailerOverrideSettingsNotifier.notifier)
                          .toggleAutoOpen(value);
                    },
                    activeThumbColor: Color(0xFFEF4444),
                    activeTrackColor: Color(0xFFEF4444).withAlpha(77),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withAlpha(77),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildQueueDelaySection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20.h,
        children: [
          Text(
            "Queue Auto-Open Delay (seconds)",
            style: TextStyle(
              color: Color(0xFF0E121B),
              fontSize: 14.fSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.21,
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(retailerOverrideSettingsNotifier);
              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFFEF4444),
                  inactiveTrackColor: Color(0xFFEF4444).withAlpha(77),
                  thumbColor: Color(0xFFEF4444),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.h),
                  trackHeight: 4.h,
                ),
                child: Slider(
                  value: state.queueDelayValue ?? 0.5,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    ref
                        .read(retailerOverrideSettingsNotifier.notifier)
                        .updateQueueDelay(value);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildReopenCooldownSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 38.h),
          child: Text(
            "Reopen Cooldown (seconds)",
            style: TextStyle(
              color: Color(0xFF0E121B),
              fontSize: 14.fSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.21,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20.h),
          child: Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(retailerOverrideSettingsNotifier);
              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFFEF4444),
                  inactiveTrackColor: Color(0xFFEF4444).withAlpha(77),
                  thumbColor: Color(0xFFEF4444),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.h),
                  trackHeight: 4.h,
                ),
                child: Slider(
                  value: state.cooldownValue ?? 0.5,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    ref
                        .read(retailerOverrideSettingsNotifier.notifier)
                        .updateCooldown(value);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildSaveSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              ref.listen(
                retailerOverrideSettingsNotifier,
                (previous, current) {
                  if (current.isSaved ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Settings saved successfully!'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                  }
                },
              );

              return GestureDetector(
                onTap: () => onTapSave(context),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.h,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: Text(
                    "Save",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.21,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Navigates back to the previous screen.
  void onTapBackButton(BuildContext context) {
    NavigatorService.goBack();
  }

  /// Handles save button tap
  void onTapSave(BuildContext context) {
    ref.read(retailerOverrideSettingsNotifier.notifier).saveSettings();
  }
}
