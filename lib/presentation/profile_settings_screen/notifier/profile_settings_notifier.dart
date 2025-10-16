import '../models/profile_settings_model.dart';
import '../../../core/app_export.dart';
import '../../../data/auth/auth_repository.dart';

part 'profile_settings_state.dart';

final profileSettingsNotifier = StateNotifierProvider.autoDispose<
    ProfileSettingsNotifier, ProfileSettingsState>(
  (ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    return ProfileSettingsNotifier(
      ProfileSettingsState(
        profileSettingsModel: ProfileSettingsModel(),
      ),
      authRepo,
    );
  },
);

class ProfileSettingsNotifier extends StateNotifier<ProfileSettingsState> {
  final AuthRepository _authRepository;

  ProfileSettingsNotifier(ProfileSettingsState state, this._authRepository)
      : super(state) {
    initialize();
  }

  void initialize() async {
    state = state.copyWith(
      isLoading: true,
    );

    try {
      // Fetch real user data from API
      final userProfile = await _authRepository.getCurrentUser();

      if (userProfile != null) {
        state = state.copyWith(
          profileSettingsModel: ProfileSettingsModel(
            userName: userProfile.username,
            userEmail: userProfile.email ?? 'No email provided',
          ),
          isLoading: false,
        );
      } else {
        // Fallback to defaults if no user data
        state = state.copyWith(
          profileSettingsModel: ProfileSettingsModel(
            userName: 'User',
            userEmail: 'Not logged in',
          ),
          isLoading: false,
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Fallback to defaults on error
      state = state.copyWith(
        profileSettingsModel: ProfileSettingsModel(
          userName: 'User',
          userEmail: 'Error loading profile',
        ),
        isLoading: false,
      );
    }
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

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
