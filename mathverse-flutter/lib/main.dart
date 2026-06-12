import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';

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

class _MathAppState extends State<MathApp> {
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = di.sl<AuthCubit>();
    _authCubit.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'MathVerse',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
