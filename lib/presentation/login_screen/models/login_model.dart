import '../../../core/app_export.dart';

/// This class is used in the [LoginScreen] screen.

// ignore_for_file: must_be_immutable
class LoginModel extends Equatable {
  LoginModel({
    this.username,
    this.password,
    this.id,
  }) {
    username = username ?? "";
    password = password ?? "";
    id = id ?? "";
  }

  String? username;
  String? password;
  String? id;

  LoginModel copyWith({
    String? username,
    String? password,
    String? id,
  }) {
    return LoginModel(
      username: username ?? this.username,
      password: password ?? this.password,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        username,
        password,
        id,
      ];
}
