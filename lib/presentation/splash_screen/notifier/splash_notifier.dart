import '../../../core/app_export.dart';
import '../models/splash_model.dart';

part 'splash_state.dart';

final splashNotifier =
    StateNotifierProvider.autoDispose<SplashNotifier, SplashState>(
  (ref) => SplashNotifier(
    SplashState(
      splashModel: SplashModel(),
    ),
  ),
);

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier(SplashState state) : super(state) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(
      splashModel: SplashModel(
        logoPath: ImageConstant.imgFrame132,
        isAnimationCompleted: false,
      ),
      isLoading: false,
    );
  }

  void completeAnimation() {
    state = state.copyWith(
      splashModel: state.splashModel?.copyWith(
        isAnimationCompleted: true,
      ),
    );
  }

  void navigateToNextScreen() {
    state = state.copyWith(
      isNavigating: true,
    );
  }
}
