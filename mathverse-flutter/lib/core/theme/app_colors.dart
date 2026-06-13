import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6366F1);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1E1B4B);

  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryContainer = Color(0xFFEDE9FE);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF2E1065);

  static const Color tertiary = Color(0xFF06B6D4);
  static const Color tertiaryContainer = Color(0xFFCFFAFE);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF164E63);

  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF14532D);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF78350F);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF1E3A5F);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceDim = Color(0xFFE7E7EC);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F2F6);
  static const Color surfaceContainer = Color(0xFFECECF1);
  static const Color surfaceContainerHigh = Color(0xFFE6E6EB);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E5);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  static const Color background = Color(0xFFF8F9FC);

  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkPrimaryContainer = Color(0xFF312E81);
  static const Color darkOnPrimary = Color(0xFF1E1B4B);
  static const Color darkOnPrimaryContainer = Color(0xFFE0E7FF);

  static const Color darkSecondary = Color(0xFFA78BFA);
  static const Color darkSecondaryContainer = Color(0xFF4C1D95);
  static const Color darkOnSecondary = Color(0xFF2E1065);
  static const Color darkOnSecondaryContainer = Color(0xFFEDE9FE);

  static const Color darkTertiary = Color(0xFF22D3EE);
  static const Color darkTertiaryContainer = Color(0xFF155E75);
  static const Color darkOnTertiary = Color(0xFF164E63);
  static const Color darkOnTertiaryContainer = Color(0xFFCFFAFE);

  static const Color darkError = Color(0xFFF87171);
  static const Color darkErrorContainer = Color(0xFF7F1D1D);
  static const Color darkOnError = Color(0xFF7F1D1D);
  static const Color darkOnErrorContainer = Color(0xFFFEE2E2);

  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkSuccessContainer = Color(0xFF14532D);
  static const Color darkOnSuccess = Color(0xFF14532D);
  static const Color darkOnSuccessContainer = Color(0xFFDCFCE7);

  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkWarningContainer = Color(0xFF78350F);
  static const Color darkOnWarning = Color(0xFF78350F);
  static const Color darkOnWarningContainer = Color(0xFFFEF3C7);

  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkInfoContainer = Color(0xFF1E3A5F);
  static const Color darkOnInfo = Color(0xFF1E3A5F);
  static const Color darkOnInfoContainer = Color(0xFFDBEAFE);

  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceDim = Color(0xFF141218);
  static const Color darkSurfaceBright = Color(0xFF3B383E);
  static const Color darkSurfaceContainerLow = Color(0xFF201F23);
  static const Color darkSurfaceContainer = Color(0xFF242327);
  static const Color darkSurfaceContainerHigh = Color(0xFF2F2D32);
  static const Color darkSurfaceContainerHighest = Color(0xFF3A383D);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  static const Color darkBackground = Color(0xFF0F0E12);

  static const Color shimmerBase = Color(0xFFE0E0E5);
  static const Color shimmerHighlight = Color(0xFFF2F2F6);
  static const Color darkShimmerBase = Color(0xFF2F2D32);
  static const Color darkShimmerHighlight = Color(0xFF3B383E);

  static const Color chart1 = Color(0xFF6366F1);
  static const Color chart2 = Color(0xFF8B5CF6);
  static const Color chart3 = Color(0xFF06B6D4);
  static const Color chart4 = Color(0xFF22C55E);
  static const Color chart5 = Color(0xFFF59E0B);
  static const Color chart6 = Color(0xFFEF4444);
  static const Color chart7 = Color(0xFFEC4899);
  static const Color chart8 = Color(0xFF14B8A6);

  static const List<Color> chartColors = [
    chart1, chart2, chart3, chart4,
    chart5, chart6, chart7, chart8,
  ];

  static const Color gradientStart = Color(0xFF6366F1);
  static const Color gradientMiddle = Color(0xFF8B5CF6);
  static const Color gradientEnd = Color(0xFF06B6D4);
  static const Color darkGradientStart = Color(0xFF818CF8);
  static const Color darkGradientMiddle = Color(0xFFA78BFA);
  static const Color darkGradientEnd = Color(0xFF22D3EE);

  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color darkGlassLight = Color(0x1A000000);
  static const Color darkGlassBorder = Color(0x33FFFFFF);

  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayMedium = Color(0x1A000000);
  static const Color darkOverlayLight = Color(0x0AFFFFFF);
  static const Color darkOverlayMedium = Color(0x1AFFFFFF);

  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}
