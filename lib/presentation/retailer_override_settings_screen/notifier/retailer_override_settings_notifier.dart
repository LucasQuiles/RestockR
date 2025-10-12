import '../models/retailer_override_settings_model.dart';
import '../../../core/app_export.dart';

part 'retailer_override_settings_state.dart';

final retailerOverrideSettingsNotifier = StateNotifierProvider.autoDispose<
    RetailerOverrideSettingsNotifier, RetailerOverrideSettingsState>(
  (ref) => RetailerOverrideSettingsNotifier(
    RetailerOverrideSettingsState(
      retailerOverrideSettingsModel: RetailerOverrideSettingsModel(),
    ),
  ),
);

class RetailerOverrideSettingsNotifier
    extends StateNotifier<RetailerOverrideSettingsState> {
  RetailerOverrideSettingsNotifier(RetailerOverrideSettingsState state)
      : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      isAutoOpenEnabled: false,
      queueDelayValue: 0.5,
      cooldownValue: 0.5,
      isSaved: false,
    );
  }

  void toggleAutoOpen(bool value) {
    state = state.copyWith(
      isAutoOpenEnabled: value,
      isSaved: false,
    );
  }

  void updateQueueDelay(double value) {
    state = state.copyWith(
      queueDelayValue: value,
      isSaved: false,
    );
  }

  void updateCooldown(double value) {
    state = state.copyWith(
      cooldownValue: value,
      isSaved: false,
    );
  }

  void saveSettings() {
    state = state.copyWith(
      isLoading: true,
    );

    // Simulate API call
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isSaved: true,
        );
      }
    });
  }
}
