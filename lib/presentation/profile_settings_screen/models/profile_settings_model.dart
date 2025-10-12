import '../../../core/app_export.dart';

/// This class is used in the [ProfileSettingsScreen] screen.

// ignore_for_file: must_be_immutable
class ProfileSettingsModel extends Equatable {
  ProfileSettingsModel({
    this.userName,
    this.userEmail,
    this.id,
  }) {
    userName = userName ?? "John Smith";
    userEmail = userEmail ?? "johnsmith@gmail.com";
    id = id ?? "";
  }

  String? userName;
  String? userEmail;
  String? id;

  ProfileSettingsModel copyWith({
    String? userName,
    String? userEmail,
    String? id,
  }) {
    return ProfileSettingsModel(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        userEmail,
        id,
      ];
}
