import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const Z1App());
}

class Z1App extends StatelessWidget {
  const Z1App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: getIt<AuthBloc>(),
      child: CupertinoApp.router(
        title: 'Z1 全网连锁',
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(
          primaryColor: AppTheme.primaryColor,
          brightness: Brightness.light,
          scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}