import 'package:go_router/go_router.dart';

import '../../features/calculator/presentation/pages/calculator_page.dart';
import '../../features/homepage/presentation/pages/home_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.calculator,
      builder: (context, state) => const CalculatorPage(),
    ),
  ],
);
