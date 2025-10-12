part of 'profile_settings_notifier.dart';

class ProfileSettingsState extends Equatable {
  final ProfileSettingsModel? profileSettingsModel;
  final bool? isLoading;
  final String? selectedMenuItem;

  ProfileSettingsState({
    this.profileSettingsModel,
    this.isLoading = false,
    this.selectedMenuItem,
  });

  @override
  List<Object?> get props => [
        profileSettingsModel,
        isLoading,
        selectedMenuItem,
      ];

  ProfileSettingsState copyWith({
    ProfileSettingsModel? profileSettingsModel,
    bool? isLoading,
    String? selectedMenuItem,
  }) {
    return ProfileSettingsState(
      profileSettingsModel: profileSettingsModel ?? this.profileSettingsModel,
      isLoading: isLoading ?? this.isLoading,
      selectedMenuItem: selectedMenuItem ?? this.selectedMenuItem,
    );
  }
}
