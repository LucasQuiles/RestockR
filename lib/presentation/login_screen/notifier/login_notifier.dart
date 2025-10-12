import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../../../core/app_export.dart';

part 'login_state.dart';

final loginNotifier =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(
    LoginState(
      loginModel: LoginModel(),
    ),
  ),
);

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(LoginState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      usernameController: TextEditingController(),
      passwordController: TextEditingController(),
      isLoading: false,
      isLoginSuccess: false,
      hasError: false,
    );
  }

  void updateUsername(String username) {
    final model = state.loginModel?.copyWith(username: username);
    state = state.copyWith(loginModel: model);
  }

  void updatePassword(String password) {
    final model = state.loginModel?.copyWith(password: password);
    state = state.copyWith(loginModel: model);
  }

  void performLogin() async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      final username = state.usernameController?.text ?? '';
      final password = state.passwordController?.text ?? '';

      // Mock login validation
      if (username.isNotEmpty && password.length >= 6) {
        // Clear form fields after successful login
        state.usernameController?.clear();
        state.passwordController?.clear();

        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          hasError: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: false,
          hasError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoginSuccess: false,
        hasError: true,
      );
    }
  }

  @override
  void dispose() {
    state.usernameController?.dispose();
    state.passwordController?.dispose();
    super.dispose();
  }
}
