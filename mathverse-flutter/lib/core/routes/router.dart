import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/presentation/pages/assistant_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/calculator/presentation/pages/calculator_page.dart';
import '../../features/derivatives/presentation/pages/derivative_page.dart';
import '../../features/dl/presentation/pages/dl_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/graph/presentation/pages/graph_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/homepage/presentation/pages/home_page.dart';
import '../../features/integrals/presentation/pages/integral_page.dart';
import '../../features/limits/presentation/pages/limit_page.dart';
import '../../features/matrix/presentation/pages/matrix_page.dart';
import '../../features/ocr/presentation/pages/ocr_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/pages/statistic_page.dart';
import '../../features/taylor/presentation/pages/taylor_page.dart';
import '../navigation/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigator,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => _buildPage(
            child: const HomePage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/calculator',
          name: 'calculator',
          pageBuilder: (context, state) => _buildPage(
            child: const CalculatorPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/derivatives',
          name: 'derivatives',
          pageBuilder: (context, state) => _buildPage(
            child: const DerivativePage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/integrals',
          name: 'integrals',
          pageBuilder: (context, state) => _buildPage(
            child: const IntegralPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/limits',
          name: 'limits',
          pageBuilder: (context, state) => _buildPage(
            child: const LimitPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/taylor',
          name: 'taylor',
          pageBuilder: (context, state) => _buildPage(
            child: const TaylorPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/dl',
          name: 'dl',
          pageBuilder: (context, state) => _buildPage(
            child: const DLPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/graph',
          name: 'graph',
          pageBuilder: (context, state) => _buildPage(
            child: const GraphPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/matrix',
          name: 'matrix',
          pageBuilder: (context, state) => _buildPage(
            child: const MatrixPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/statistics',
          name: 'statistics',
          pageBuilder: (context, state) => _buildPage(
            child: const StatisticPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/ocr',
          name: 'ocr',
          pageBuilder: (context, state) => _buildPage(
            child: const OcrPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/assistant',
          name: 'assistant',
          pageBuilder: (context, state) => _buildPage(
            child: const AssistantPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/history',
          name: 'history',
          pageBuilder: (context, state) => _buildPage(
            child: const HistoryPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          pageBuilder: (context, state) => _buildPage(
            child: const FavoritesPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => _buildPage(
            child: const SettingsPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => _buildPage(
            child: const ProfilePage(),
            state: state,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      parentNavigatorKey: _rootNavigator,
      pageBuilder: (context, state) => _buildPage(
        child: const LoginPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      parentNavigatorKey: _rootNavigator,
      pageBuilder: (context, state) => _buildPage(
        child: const RegisterPage(),
        state: state,
      ),
    ),
  ],
);

Page<void> _buildPage({required Widget child, required GoRouterState state}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        ),
      );
    },
  );
}
