import 'package:flutter/material.dart';

// ignore_for_file: non_constant_identifier_names

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  final String _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  final Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

  // A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get gray_900 => Color(0xFF1A1A1A);
  Color get gray_100 => Color(0xFFF4F4F4);
  Color get gray_500 => Color(0xFF999999);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get blue_gray_100 => Color(0xFFCCCCCC);
  Color get gray_700 => Color(0xFF666666);
  Color get teal_600 => Color(0xFF059666);
  Color get gray_300 => Color(0xFFE6E6E6);
  Color get gray_600 => Color(0xFF808080);
  Color get red_500 => Color(0xFFEF4444);
  Color get red_50 => Color(0xFFFEF2F2);
  Color get black_900 => Color(0xFF000000);
  Color get blue_A400 => Color(0xFF3C78FA);
  Color get indigo_A400 => Color(0xFF445AEF);
  Color get gray_100_01 => Color(0xFFF0F2FD);
  Color get teal_900 => Color(0xFF064E36);
  Color get teal_800 => Color(0xFF047852);
  Color get gray_900_01 => Color(0xFF022C1E);
  Color get green_A200 => Color(0xFF6EE7BF);
  Color get teal_400 => Color(0xFF10B981);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get redCustom => Colors.red;
  Color get greyCustom => Colors.grey;
  Color get blackCustom => Colors.black;
  Color get color330000 => Color(0x33000000);
  Color get color190000 => Color(0x19000000);
  Color get colorFFE0E0 => Color(0xFFE0E0E0);
  Color get colorFF9CA3 => Color(0xFF9CA3AF);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;

  // New Colors
  Color get gray_200 => Color(0xFFE5E5E5);
  Color get red_600 => Color(0xFFDC2626);
  Color get gray_800 => Color(0xFF21252B);
  Color get gray_900_02 => Color(0xFF0E121B);
}
