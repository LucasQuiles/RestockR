import '../models/notifications_alerts_settings_model.dart';
import '../../../core/app_export.dart';

part 'notifications_alerts_settings_state.dart';

final notificationsAlertsSettingsNotifier = StateNotifierProvider.autoDispose<
    NotificationsAlertsSettingsNotifier, NotificationsAlertsSettingsState>(
  (ref) => NotificationsAlertsSettingsNotifier(
    NotificationsAlertsSettingsState(
      notificationsAlertsSettingsModel: NotificationsAlertsSettingsModel(),
    ),
  ),
);

class NotificationsAlertsSettingsNotifier
    extends StateNotifier<NotificationsAlertsSettingsState> {
  NotificationsAlertsSettingsNotifier(NotificationsAlertsSettingsState state)
      : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      notificationsAlertsSettingsModel: NotificationsAlertsSettingsModel(
        isRestockSoundEnabled: false,
      ),
    );
  }

  void toggleRestockSoundAlert(bool value) {
    state = state.copyWith(
      notificationsAlertsSettingsModel:
          state.notificationsAlertsSettingsModel?.copyWith(
        isRestockSoundEnabled: value,
      ),
    );
  }
}
