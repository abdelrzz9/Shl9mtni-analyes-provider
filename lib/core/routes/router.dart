import 'package:go_router/go_router.dart';

import '../../features/assistant/presentation/pages/assistant_page.dart';
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
import '../../features/statistics/presentation/pages/statistic_page.dart';
import '../../features/taylor/presentation/pages/taylor_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
    GoRoute(path: AppRoutes.calculator, builder: (context, state) => const CalculatorPage()),
    GoRoute(path: AppRoutes.derivatives, builder: (context, state) => const DerivativePage()),
    GoRoute(path: AppRoutes.integrals, builder: (context, state) => const IntegralPage()),
    GoRoute(path: AppRoutes.limits, builder: (context, state) => const LimitPage()),
    GoRoute(path: AppRoutes.taylor, builder: (context, state) => const TaylorPage()),
    GoRoute(path: AppRoutes.dl, builder: (context, state) => const DLPage()),
    GoRoute(path: AppRoutes.matrix, builder: (context, state) => const MatrixPage()),
    GoRoute(path: AppRoutes.statistics, builder: (context, state) => const StatisticPage()),
    GoRoute(path: AppRoutes.graph, builder: (context, state) => const GraphPage()),
    GoRoute(path: AppRoutes.history, builder: (context, state) => const HistoryPage()),
    GoRoute(path: AppRoutes.favorites, builder: (context, state) => const FavoritesPage()),
    GoRoute(path: AppRoutes.ocr, builder: (context, state) => const OcrPage()),
    GoRoute(path: AppRoutes.assistant, builder: (context, state) => const AssistantPage()),
  ],
);
