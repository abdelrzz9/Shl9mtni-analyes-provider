import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 900;
  bool get isDesktop => MediaQuery.of(this).size.width >= 900;

  bool get isSmallScreen => MediaQuery.of(this).size.width < 600;
  bool get isMediumScreen =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 900;
  bool get isLargeScreen => MediaQuery.of(this).size.width >= 900;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double get maxContentWidth {
    if (isDesktop) return 800;
    if (isTablet) return 600;
    return double.infinity;
  }

  EdgeInsets get screenPadding {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  double get horizontalPadding {
    if (isDesktop) return 40;
    if (isTablet) return 24;
    return 16;
  }

  bool get useNavigationRail => isDesktop;
  bool get useNavigationBar => isMobile || isTablet;
  bool get showDrawer => isDesktop;

  double get navigationRailWidth => 88;
  double get bottomNavHeight => 64;
}

extension ThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
