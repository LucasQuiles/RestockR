import '../models/profile_settings_model.dart';
import '../../../core/app_export.dart';

part 'profile_settings_state.dart';

final profileSettingsNotifier = StateNotifierProvider.autoDispose<
    ProfileSettingsNotifier, ProfileSettingsState>(
  (ref) => ProfileSettingsNotifier(
    ProfileSettingsState(
      profileSettingsModel: ProfileSettingsModel(),
    ),
  ),
);

class ProfileSettingsNotifier extends StateNotifier<ProfileSettingsState> {
  ProfileSettingsNotifier(ProfileSettingsState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      profileSettingsModel: ProfileSettingsModel(
        userName: 'John Smith',
        userEmail: 'johnsmith@gmail.com',
      ),
      isLoading: false,
    );
  }

  void navigateToNotificationsSettings() {
    state = state.copyWith(
      selectedMenuItem: 'notifications',
    );
  }

  void navigateToGlobalFiltering() {
    state = state.copyWith(
      selectedMenuItem: 'global_filtering',
    );
  }

  void navigateToRetailerOverrides() {
    state = state.copyWith(
      selectedMenuItem: 'retailer_overrides',
    );
  }
}
