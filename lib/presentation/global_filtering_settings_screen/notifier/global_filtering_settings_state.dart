part of 'global_filtering_settings_notifier.dart';

class GlobalFilteringSettingsState extends Equatable {
  final TextEditingController? minimumTargetController;
  final GlobalFilteringSettingsModel? globalFilteringSettingsModel;

  GlobalFilteringSettingsState({
    this.minimumTargetController,
    this.globalFilteringSettingsModel,
  });

  @override
  List<Object?> get props => [
        minimumTargetController,
        globalFilteringSettingsModel,
      ];

  GlobalFilteringSettingsState copyWith({
    TextEditingController? minimumTargetController,
    GlobalFilteringSettingsModel? globalFilteringSettingsModel,
  }) {
    return GlobalFilteringSettingsState(
      minimumTargetController:
          minimumTargetController ?? this.minimumTargetController,
      globalFilteringSettingsModel:
          globalFilteringSettingsModel ?? this.globalFilteringSettingsModel,
    );
  }
}
