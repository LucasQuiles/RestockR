part of 'login_notifier.dart';

class LoginState extends Equatable {
  final TextEditingController? usernameController;
  final TextEditingController? passwordController;
  final bool? isLoading;
  final bool? isLoginSuccess;
  final bool? hasError;
  final String? errorMessage;
  final LoginModel? loginModel;

  LoginState({
    this.usernameController,
    this.passwordController,
    this.isLoading = false,
    this.isLoginSuccess = false,
    this.hasError = false,
    this.errorMessage,
    this.loginModel,
  });

  @override
  List<Object?> get props => [
        usernameController,
        passwordController,
        isLoading,
        isLoginSuccess,
        hasError,
        errorMessage,
        loginModel,
      ];

  LoginState copyWith({
    TextEditingController? usernameController,
    TextEditingController? passwordController,
    bool? isLoading,
    bool? isLoginSuccess,
    bool? hasError,
    String? errorMessage,
    LoginModel? loginModel,
  }) {
    return LoginState(
      usernameController: usernameController ?? this.usernameController,
      passwordController: passwordController ?? this.passwordController,
      isLoading: isLoading ?? this.isLoading,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      loginModel: loginModel ?? this.loginModel,
    );
  }
}
