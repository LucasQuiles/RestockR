import '../../../core/app_export.dart';

/// This class is used in the [splash_screen] screen.

// ignore_for_file: must_be_immutable
class SplashModel extends Equatable {
  SplashModel({
    this.logoPath,
    this.isAnimationCompleted,
    this.id,
  }) {
    logoPath = logoPath ?? ImageConstant.imgFrame132;
    isAnimationCompleted = isAnimationCompleted ?? false;
    id = id ?? "";
  }

  String? logoPath;
  bool? isAnimationCompleted;
  String? id;

  SplashModel copyWith({
    String? logoPath,
    bool? isAnimationCompleted,
    String? id,
  }) {
    return SplashModel(
      logoPath: logoPath ?? this.logoPath,
      isAnimationCompleted: isAnimationCompleted ?? this.isAnimationCompleted,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        logoPath,
        isAnimationCompleted,
        id,
      ];
}
