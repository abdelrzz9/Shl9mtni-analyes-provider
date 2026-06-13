import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const double displayLargeSize = 57;
  static const double displayMediumSize = 45;
  static const double displaySmallSize = 36;

  static const double headlineLargeSize = 32;
  static const double headlineMediumSize = 28;
  static const double headlineSmallSize = 24;

  static const double titleLargeSize = 22;
  static const double titleMediumSize = 16;
  static const double titleSmallSize = 14;

  static const double bodyLargeSize = 16;
  static const double bodyMediumSize = 14;
  static const double bodySmallSize = 12;

  static const double labelLargeSize = 14;
  static const double labelMediumSize = 12;
  static const double labelSmallSize = 11;

  static const double mathDisplaySize = 28;
  static const double mathResultSize = 24;
  static const double mathExpressionSize = 20;
  static const double mathStepSize = 16;

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: displayLargeSize,
      fontWeight: bold,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: displayMediumSize,
      fontWeight: bold,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontSize: displaySmallSize,
      fontWeight: semiBold,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: headlineLargeSize,
      fontWeight: semiBold,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: headlineMediumSize,
      fontWeight: semiBold,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: headlineSmallSize,
      fontWeight: semiBold,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: titleLargeSize,
      fontWeight: medium,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: titleMediumSize,
      fontWeight: medium,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: titleSmallSize,
      fontWeight: medium,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: bodyLargeSize,
      fontWeight: regular,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: bodyMediumSize,
      fontWeight: regular,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: bodySmallSize,
      fontWeight: regular,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: labelLargeSize,
      fontWeight: medium,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: labelMediumSize,
      fontWeight: medium,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: labelSmallSize,
      fontWeight: medium,
      letterSpacing: 0.5,
    ),
  );
}
