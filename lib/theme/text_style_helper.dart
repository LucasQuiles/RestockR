import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline24BoldInter => TextStyle(
        fontSize: 24.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title22BoldInter => TextStyle(
        fontSize: 22.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: appTheme.red_500,
      );

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title18BoldInter => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  TextStyle get title18SemiBoldInter => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  TextStyle get title16MediumInter => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: appTheme.gray_700,
      );

  TextStyle get title16SemiBoldInter => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14MediumInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      );

  TextStyle get body14SemiBoldInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      );

  TextStyle get body14RegularInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: appTheme.blackCustom,
      );

  TextStyle get body12MediumInter => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: appTheme.gray_700,
      );

  TextStyle get body12SemiBoldInter => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label11MediumInter => TextStyle(
        fontSize: 11.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      );

  TextStyle get label10MediumInter => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: appTheme.gray_700,
      );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get textStyle10 => TextStyle(
        color: appTheme.red_500,
      );

  TextStyle get bodyTextInter => TextStyle(
        fontFamily: 'Inter',
      );
}
