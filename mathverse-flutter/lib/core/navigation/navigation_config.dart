import 'package:flutter/material.dart';

enum NavigationSection {
  home,
  math,
  tools,
  data,
  intelligence,
  personal,
}

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final NavigationSection section;
  final bool requiresAuth;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.section = NavigationSection.math,
    this.requiresAuth = false,
  });
}

class NavigationConfig {
  NavigationConfig._();

  static const String home = '/';
  static const String calculator = '/calculator';
  static const String derivatives = '/derivatives';
  static const String integrals = '/integrals';
  static const String limits = '/limits';
  static const String taylor = '/taylor';
  static const String dl = '/dl';
  static const String graph = '/graph';
  static const String matrix = '/matrix';
  static const String statistics = '/statistics';
  static const String ocr = '/ocr';
  static const String assistant = '/assistant';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static const List<NavigationItem> primaryItems = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: home,
      section: NavigationSection.home,
    ),
    NavigationItem(
      label: 'Calculator',
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate_rounded,
      route: calculator,
      section: NavigationSection.math,
    ),
    NavigationItem(
      label: 'Graph',
      icon: Icons.show_chart_outlined,
      activeIcon: Icons.show_chart_rounded,
      route: graph,
      section: NavigationSection.math,
    ),
    NavigationItem(
      label: 'AI Assistant',
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy_rounded,
      route: assistant,
      section: NavigationSection.intelligence,
    ),
  ];

  static const List<NavigationItem> mathItems = [
    NavigationItem(
      label: 'Derivatives',
      icon: Icons.functions_outlined,
      activeIcon: Icons.functions_rounded,
      route: derivatives,
    ),
    NavigationItem(
      label: 'Integrals',
      icon: Icons.integration_instructions_outlined,
      activeIcon: Icons.integration_instructions_rounded,
      route: integrals,
    ),
    NavigationItem(
      label: 'Limits',
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up_rounded,
      route: limits,
    ),
    NavigationItem(
      label: 'Taylor Series',
      icon: Icons.linear_scale_outlined,
      activeIcon: Icons.linear_scale_rounded,
      route: taylor,
    ),
    NavigationItem(
      label: 'DL',
      icon: Icons.auto_fix_high_outlined,
      activeIcon: Icons.auto_fix_high_rounded,
      route: dl,
    ),
  ];

  static const List<NavigationItem> toolItems = [
    NavigationItem(
      label: 'Matrix',
      icon: Icons.grid_on_outlined,
      activeIcon: Icons.grid_on_rounded,
      route: matrix,
    ),
    NavigationItem(
      label: 'Statistics',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      route: statistics,
    ),
    NavigationItem(
      label: 'OCR Scanner',
      icon: Icons.document_scanner_outlined,
      activeIcon: Icons.document_scanner_rounded,
      route: ocr,
    ),
  ];

  static const List<NavigationItem> personalItems = [
    NavigationItem(
      label: 'History',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      route: history,
    ),
    NavigationItem(
      label: 'Favorites',
      icon: Icons.star_outlined,
      activeIcon: Icons.star_rounded,
      route: favorites,
    ),
  ];

  static String labelForRoute(String route) {
    final allItems = [
      ...primaryItems,
      ...mathItems,
      ...toolItems,
      ...personalItems,
    ];
    return allItems.firstWhere(
      (item) => item.route == route,
      orElse: () => const NavigationItem(
        label: '',
        icon: Icons.circle,
        activeIcon: Icons.circle,
        route: '',
      ),
    ).label;
  }
}
