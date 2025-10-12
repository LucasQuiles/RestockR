import '../../../core/app_export.dart';

/// This class is used in the [RetailerOverrideSettingsScreen] screen.

// ignore_for_file: must_be_immutable
class RetailerOverrideSettingsModel extends Equatable {
  RetailerOverrideSettingsModel({
    this.isAutoOpenEnabled,
    this.queueDelayValue,
    this.cooldownValue,
    this.id,
  }) {
    isAutoOpenEnabled = isAutoOpenEnabled ?? false;
    queueDelayValue = queueDelayValue ?? 0.5;
    cooldownValue = cooldownValue ?? 0.5;
    id = id ?? "";
  }

  bool? isAutoOpenEnabled;
  double? queueDelayValue;
  double? cooldownValue;
  String? id;

  RetailerOverrideSettingsModel copyWith({
    bool? isAutoOpenEnabled,
    double? queueDelayValue,
    double? cooldownValue,
    String? id,
  }) {
    return RetailerOverrideSettingsModel(
      isAutoOpenEnabled: isAutoOpenEnabled ?? this.isAutoOpenEnabled,
      queueDelayValue: queueDelayValue ?? this.queueDelayValue,
      cooldownValue: cooldownValue ?? this.cooldownValue,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        isAutoOpenEnabled,
        queueDelayValue,
        cooldownValue,
        id,
      ];
}
