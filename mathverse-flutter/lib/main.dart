import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/usecases/get_history.dart';
import 'features/history/presentation/bloc/history_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const MathApp());
}

class MathApp extends StatefulWidget {
  const MathApp({super.key});

  @override
  State<MathApp> createState() => _MathAppState();
}

class _MathAppState extends State<MathApp> with WidgetsBindingObserver {
  late final AuthCubit _authCubit;
  final ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = di.sl<AuthCubit>();
    _authCubit.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(
          create: (_) {
            final repo = HistoryRepositoryImpl();
            return HistoryBloc(
              getHistory: GetHistory(repo),
              addHistoryEntry: AddHistoryEntry(repo),
              deleteHistoryEntry: DeleteHistoryEntry(repo),
              clearHistory: ClearHistory(repo),
              toggleFavorite: ToggleFavorite(repo),
            )..add(const LoadHistory());
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'MathVerse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
