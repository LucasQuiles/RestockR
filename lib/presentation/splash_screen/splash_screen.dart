import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../core/auth/auth_status.dart';
import '../../widgets/custom_image_view.dart';
import 'notifier/splash_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  void _startSplashSequence() {
    _animationController.forward();

    // Wait for animation, then check auth status
    Future.delayed(Duration(milliseconds: 2800), () {
      if (mounted) {
        _navigateBasedOnAuthStatus();
      }
    });
  }

  void _navigateBasedOnAuthStatus() {
    final authStatus = ref.read(authSessionProvider);

    switch (authStatus) {
      case AuthSessionStatus.authenticated:
        // User is logged in, go to main app with bottom navigation
        NavigatorService.pushNamedAndRemoveUntil(
          AppRoutes.productWatchlistScreen,
        );
        break;
      case AuthSessionStatus.unauthenticated:
      case AuthSessionStatus.unknown:
        // Not logged in or unknown, go to login
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backendConfig = ref.watch(backendConfigProvider);
    final envName = backendConfig.environment.toUpperCase();
    final showEnvBadge =
        backendConfig.environment.toLowerCase() != 'production';

    return Scaffold(
      backgroundColor: appTheme.gray_100,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _buildLogoSection(context),
            ),
            if (showEnvBadge)
              Positioned(
                bottom: 24.h,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.h,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                    child: Text(
                      envName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.fSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildLogoSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(splashNotifier);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.58,
                  child: CustomImageView(
                    imagePath: state.splashModel?.logoPath ??
                        ImageConstant.imgFrame132,
                    height: 60.h,
                    width: 218.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
