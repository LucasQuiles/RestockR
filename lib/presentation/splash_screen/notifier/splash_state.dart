part of 'splash_notifier.dart';

class SplashState extends Equatable {
  final SplashModel? splashModel;
  final bool? isLoading;
  final bool? isNavigating;

  SplashState({
    this.splashModel,
    this.isLoading = false,
    this.isNavigating = false,
  });

  @override
  List<Object?> get props => [
        splashModel,
        isLoading,
        isNavigating,
      ];

  SplashState copyWith({
    SplashModel? splashModel,
    bool? isLoading,
    bool? isNavigating,
  }) {
    return SplashState(
      splashModel: splashModel ?? this.splashModel,
      isLoading: isLoading ?? this.isLoading,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
