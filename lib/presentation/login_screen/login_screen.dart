import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_labeled_form_field.dart';
import 'notifier/login_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_100,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(left: 16.h, right: 16.h),
              child: Column(
                spacing: 32.h,
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 30.h),
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomImageView(
                        imagePath: ImageConstant.imgFrame132,
                        height: 48.h,
                        width: 174.h,
                      ),
                    ),
                  ),
                  _buildLoginForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildLoginForm(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.whiteCustom,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.h),
          topRight: Radius.circular(16.h),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 28.h),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Text(
              "Welcome!",
              style: TextStyleHelper.instance.title22BoldInter
                  .copyWith(height: 1.23),
            ),
            SizedBox(height: 4.h),
            Text(
              "Enter your email to get started.",
              style: TextStyleHelper.instance.title16MediumInter
                  .copyWith(height: 1.25),
            ),
            SizedBox(height: 32.h),
            Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(loginNotifier);

                ref.listen(
                  loginNotifier,
                  (previous, current) {
                    if (current.isLoginSuccess ?? false) {
                      showAppToast(
                        context,
                        message: 'Login successful',
                        variant: AppToastVariant.success,
                      );
                      NavigatorService.pushNamedAndRemoveUntil(
                          AppRoutes.productMonitorScreen);
                    }

                    if (current.hasError ?? false) {
                      final errorMessage = current.errorMessage ??
                          'Login failed. Please check your credentials and try again.';
                      showAppToast(
                        context,
                        message: errorMessage,
                        variant: AppToastVariant.error,
                      );
                    }
                  },
                );

                return Column(
                  children: [
                    CustomLabeledFormField(
                      labelText: "Username*",
                      hintText: "John Doe",
                      isRequired: true,
                      controller: state.usernameController,
                      validator: (value) => _validateUsername(value),
                      onChanged: (value) {
                        ref.read(loginNotifier.notifier).updateUsername(value);
                      },
                    ),
                    CustomLabeledFormField(
                      labelText: "Password*",
                      hintText: "********",
                      isRequired: true,
                      isPassword: true,
                      controller: state.passwordController,
                      margin: EdgeInsets.only(top: 16.h),
                      validator: (value) => _validatePassword(value),
                      onChanged: (value) {
                        ref.read(loginNotifier.notifier).updatePassword(value);
                      },
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => onTapForgotPassword(context),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyleHelper.instance.body12MediumInter
                              .copyWith(
                                  color: appTheme.blue_A400, height: 1.25),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    CustomButton(
                      text: "Login",
                      backgroundColor: appTheme.red_500,
                      textColor: appTheme.whiteCustom,
                      width: double.infinity,
                      borderRadius: 12.0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.h, vertical: 14.h),
                      onPressed: (state.isLoading ?? false)
                          ? null
                          : () => onTapLogin(context),
                    ),
                    SizedBox(height: 16.h),
                    // Divider with "or" text
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: appTheme.gray_300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.h),
                          child: Text(
                            "or",
                            style: TextStyleHelper.instance.body14MediumInter
                                .copyWith(color: appTheme.gray_600),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: appTheme.gray_300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Discord login button
                    CustomButton(
                      text: "Login with Discord",
                      backgroundColor: Color(0xFF5865F2), // Discord blurple
                      textColor: appTheme.whiteCustom,
                      width: double.infinity,
                      borderRadius: 12.0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.h, vertical: 14.h),
                      onPressed: (state.isLoading ?? false)
                          ? null
                          : () => onTapDiscordLogin(context),
                    ),
                    SizedBox(height: 234.h),
                    Container(
                      width: double.infinity,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "By continuing, you agree to our ",
                              style: TextStyleHelper.instance.body12MediumInter
                                  .copyWith(height: 1.33),
                            ),
                            TextSpan(
                              text: "Terms and Conditions",
                              style: TextStyleHelper.instance.body12MediumInter
                                  .copyWith(
                                      color: appTheme.black_900, height: 1.33),
                            ),
                            TextSpan(
                              text: " and ",
                              style: TextStyleHelper.instance.body12MediumInter
                                  .copyWith(height: 1.33),
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyleHelper.instance.body12MediumInter
                                  .copyWith(
                                      color: appTheme.black_900, height: 1.33),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Validation function for username field
  String? _validateUsername(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Username is required';
    }
    return null;
  }

  /// Validation function for password field
  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if ((value?.length ?? 0) < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handles login button press
  void onTapLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(loginNotifier.notifier).performLogin();
    }
  }

  /// Handles Discord login button press
  void onTapDiscordLogin(BuildContext context) {
    // Get guildId from config
    final config = ref.read(backendConfigProvider);
    final guildId = config.discordGuildId;
    print('🔐 Discord login: Using guildId from config: $guildId');
    ref.read(loginNotifier.notifier).performDiscordLogin(guildId: guildId);
  }

  /// Handles forgot password tap
  void onTapForgotPassword(BuildContext context) {
    // Navigate to forgot password screen or show dialog
    showAppToast(
      context,
      message: 'Forgot password functionality coming soon',
      variant: AppToastVariant.warning,
    );
  }
}
