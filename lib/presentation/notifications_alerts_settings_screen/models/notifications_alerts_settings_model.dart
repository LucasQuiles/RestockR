import '../../../core/app_export.dart';

/// This class is used in the [notifications_alerts_settings_screen] screen.

// ignore_for_file: must_be_immutable
class NotificationsAlertsSettingsModel extends Equatable {
  NotificationsAlertsSettingsModel({
    this.isRestockSoundEnabled,
    this.id,
  }) {
    isRestockSoundEnabled = isRestockSoundEnabled ?? false;
    id = id ?? "";
  }

  bool? isRestockSoundEnabled;
  String? id;

  NotificationsAlertsSettingsModel copyWith({
    bool? isRestockSoundEnabled,
    String? id,
  }) {
    return NotificationsAlertsSettingsModel(
      isRestockSoundEnabled:
          isRestockSoundEnabled ?? this.isRestockSoundEnabled,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        isRestockSoundEnabled,
        id,
      ];
}
