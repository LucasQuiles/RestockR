part of 'notifications_alerts_settings_notifier.dart';

class NotificationsAlertsSettingsState extends Equatable {
  final NotificationsAlertsSettingsModel? notificationsAlertsSettingsModel;

  NotificationsAlertsSettingsState({
    this.notificationsAlertsSettingsModel,
  });

  @override
  List<Object?> get props => [
        notificationsAlertsSettingsModel,
      ];

  NotificationsAlertsSettingsState copyWith({
    NotificationsAlertsSettingsModel? notificationsAlertsSettingsModel,
  }) {
    return NotificationsAlertsSettingsState(
      notificationsAlertsSettingsModel: notificationsAlertsSettingsModel ??
          this.notificationsAlertsSettingsModel,
    );
  }
}
