import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/calculator/data/repositories/calculator_repository_impl.dart';
import '../features/calculator/domain/repositories/calculator_repository.dart';
import '../features/derivatives/data/repositories/derivative_repository_impl.dart';
import '../features/derivatives/domain/repositories/derivative_repository.dart';
import '../features/dl/data/repositories/dl_repository_impl.dart';
import '../features/dl/domain/repositories/dl_repository.dart';
import '../features/graph/data/repositories/graph_repository_impl.dart';
import '../features/graph/domain/repositories/graph_repository.dart';
import '../features/history/data/repositories/history_repository_impl.dart';
import '../features/history/domain/repositories/history_repository.dart';
import '../features/integrals/data/repositories/integral_repository_impl.dart';
import '../features/integrals/domain/repositories/integral_repository.dart';
import '../features/limits/data/repositories/limit_repository_impl.dart';
import '../features/limits/domain/repositories/limit_repository.dart';
import '../features/matrix/data/repositories/matrix_repository_impl.dart';
import '../features/matrix/domain/repositories/matrix_repository.dart';
import '../features/statistics/data/repositories/statistic_repository_impl.dart';
import '../features/statistics/domain/repositories/statistic_repository.dart';
import '../features/taylor/data/repositories/taylor_repository_impl.dart';
import '../features/taylor/domain/repositories/taylor_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));

  sl.registerLazySingleton<CalculatorRepository>(() => CalculatorRepositoryImpl());
  sl.registerLazySingleton<DerivativeRepository>(() => DerivativeRepositoryImpl());
  sl.registerLazySingleton<IntegralRepository>(() => IntegralRepositoryImpl());
  sl.registerLazySingleton<LimitRepository>(() => LimitRepositoryImpl());
  sl.registerLazySingleton<TaylorRepository>(() => TaylorRepositoryImpl());
  sl.registerLazySingleton<DLRepository>(() => DLRepositoryImpl());
  sl.registerLazySingleton<MatrixRepository>(() => MatrixRepositoryImpl());
  sl.registerLazySingleton<StatisticRepository>(() => StatisticRepositoryImpl());
  sl.registerLazySingleton<GraphRepository>(() => GraphRepositoryImpl());
  sl.registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl(sl<ApiClient>()));
}
