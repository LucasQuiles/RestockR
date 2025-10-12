part of 'login_notifier.dart';

class LoginState extends Equatable {
  final TextEditingController? usernameController;
  final TextEditingController? passwordController;
  final bool? isLoading;
  final bool? isLoginSuccess;
  final bool? hasError;
  final LoginModel? loginModel;

  LoginState({
    this.usernameController,
    this.passwordController,
    this.isLoading = false,
    this.isLoginSuccess = false,
    this.hasError = false,
    this.loginModel,
  });

  @override
  List<Object?> get props => [
        usernameController,
        passwordController,
        isLoading,
        isLoginSuccess,
        hasError,
        loginModel,
      ];

  LoginState copyWith({
    TextEditingController? usernameController,
    TextEditingController? passwordController,
    bool? isLoading,
    bool? isLoginSuccess,
    bool? hasError,
    LoginModel? loginModel,
  }) {
    return LoginState(
      usernameController: usernameController ?? this.usernameController,
      passwordController: passwordController ?? this.passwordController,
      isLoading: isLoading ?? this.isLoading,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
      hasError: hasError ?? this.hasError,
      loginModel: loginModel ?? this.loginModel,
    );
  }
}
