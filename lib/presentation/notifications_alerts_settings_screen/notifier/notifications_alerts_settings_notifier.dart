import '../models/notifications_alerts_settings_model.dart';
import '../../../core/app_export.dart';
import '../../../data/auth/auth_repository.dart';

part 'notifications_alerts_settings_state.dart';

final notificationsAlertsSettingsNotifier = StateNotifierProvider.autoDispose<
    NotificationsAlertsSettingsNotifier, NotificationsAlertsSettingsState>(
  (ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    return NotificationsAlertsSettingsNotifier(
      NotificationsAlertsSettingsState(
        notificationsAlertsSettingsModel: NotificationsAlertsSettingsModel(),
      ),
      authRepository: authRepo,
    );
  },
);

class NotificationsAlertsSettingsNotifier
    extends StateNotifier<NotificationsAlertsSettingsState> {
  final AuthRepository _authRepository;

  NotificationsAlertsSettingsNotifier(
    NotificationsAlertsSettingsState state, {
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(state) {
    initialize();
  }

  Future<void> initialize() async {
    // Load current user preferences
    final userProfile = await _authRepository.getCurrentUser();

    if (userProfile != null) {
      state = state.copyWith(
        notificationsAlertsSettingsModel: NotificationsAlertsSettingsModel(
          isRestockSoundEnabled: userProfile.restockBell,
        ),
      );
    } else {
      state = state.copyWith(
        notificationsAlertsSettingsModel: NotificationsAlertsSettingsModel(
          isRestockSoundEnabled: false,
        ),
      );
    }
  }

  Future<void> toggleRestockSoundAlert(bool value) async {
    // Optimistically update UI
    state = state.copyWith(
      notificationsAlertsSettingsModel:
          state.notificationsAlertsSettingsModel?.copyWith(
        isRestockSoundEnabled: value,
      ),
    );

    // Persist to backend
    final success = await _authRepository.updateUserPreferences({
      'restockBell': value,
    });

    if (!success) {
      // Revert on failure
      state = state.copyWith(
        notificationsAlertsSettingsModel:
            state.notificationsAlertsSettingsModel?.copyWith(
          isRestockSoundEnabled: !value,
        ),
      );
      print('❌ Failed to update restock sound alert preference');
    } else {
      print('✅ Restock sound alert preference updated: $value');
    }
  }
}
