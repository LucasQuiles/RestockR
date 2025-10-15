import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../../../core/app_export.dart';
import '../../../data/auth/auth_repository.dart';

part 'login_state.dart';

final loginNotifier =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    return LoginNotifier(
      LoginState(
        loginModel: LoginModel(),
      ),
      authRepo,
    );
  },
);

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginNotifier(LoginState state, this._authRepository) : super(state) {
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
      errorMessage: null,
    );

    try {
      final username = state.usernameController?.text ?? '';
      final password = state.passwordController?.text ?? '';

      print('🔐 Attempting login with username: $username');

      // Call real auth repository
      final result = await _authRepository.signIn(username, password);

      if (result.success) {
        print('🔐 Login successful!');
        // Clear form fields after successful login
        state.usernameController?.clear();
        state.passwordController?.clear();

        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          hasError: false,
          errorMessage: null,
        );
      } else {
        print('🔐 Login failed: ${result.error}');
        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: false,
          hasError: true,
          errorMessage: result.error ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      print('🔐 Login exception: ${e.toString()}');
      state = state.copyWith(
        isLoading: false,
        isLoginSuccess: false,
        hasError: true,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  void performDiscordLogin({String? guildId}) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      print('🔐 Attempting Discord login with guildId: $guildId');

      // Call Discord OAuth
      final result = await _authRepository.signInWithDiscord(guildId: guildId);

      if (result.success) {
        print('🔐 Discord login successful!');
        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          hasError: false,
          errorMessage: null,
        );
      } else {
        print('🔐 Discord login failed: ${result.error}');
        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: false,
          hasError: true,
          errorMessage: result.error ?? 'Discord login failed. Please try again.',
        );
      }
    } catch (e) {
      print('🔐 Discord login exception: ${e.toString()}');
      state = state.copyWith(
        isLoading: false,
        isLoginSuccess: false,
        hasError: true,
        errorMessage: 'Discord OAuth error: ${e.toString()}',
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
