part of 'retailer_override_settings_notifier.dart';

class RetailerOverrideSettingsState extends Equatable {
  final bool? isAutoOpenEnabled;
  final double? queueDelayValue;
  final double? cooldownValue;
  final bool? isLoading;
  final bool? isSaved;
  final RetailerOverrideSettingsModel? retailerOverrideSettingsModel;

  RetailerOverrideSettingsState({
    this.isAutoOpenEnabled,
    this.queueDelayValue,
    this.cooldownValue,
    this.isLoading = false,
    this.isSaved = false,
    this.retailerOverrideSettingsModel,
  });

  @override
  List<Object?> get props => [
        isAutoOpenEnabled,
        queueDelayValue,
        cooldownValue,
        isLoading,
        isSaved,
        retailerOverrideSettingsModel,
      ];

  RetailerOverrideSettingsState copyWith({
    bool? isAutoOpenEnabled,
    double? queueDelayValue,
    double? cooldownValue,
    bool? isLoading,
    bool? isSaved,
    RetailerOverrideSettingsModel? retailerOverrideSettingsModel,
  }) {
    return RetailerOverrideSettingsState(
      isAutoOpenEnabled: isAutoOpenEnabled ?? this.isAutoOpenEnabled,
      queueDelayValue: queueDelayValue ?? this.queueDelayValue,
      cooldownValue: cooldownValue ?? this.cooldownValue,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      retailerOverrideSettingsModel:
          retailerOverrideSettingsModel ?? this.retailerOverrideSettingsModel,
    );
  }
}
