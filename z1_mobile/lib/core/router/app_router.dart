import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// App 路由配置
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// 路由名称
  static const String login = '/login';
  static const String home = '/home';

  /// 路由列表
  static final List<GoRoute> _routes = [
    GoRoute(
      path: login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ];

  /// Router 配置
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: _routes,
    redirect: (context, state) {
      // 注意：这里需要从 Provider 获取 AuthBloc 来检查状态
      // 由于 GoRouter 的 redirect 是静态的，我们在这里做简单处理
      // 实际认证逻辑在页面组件中处理
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '页面未找到',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );

  /// 跳转到登录页
  static void goLogin(BuildContext context) {
    context.go(login);
  }

  /// 跳转到首页
  static void goHome(BuildContext context) {
    context.go(home);
  }

  /// 跳转到指定路径
  static void goTo(BuildContext context, String path) {
    context.go(path);
  }

  /// Push 到指定路径
  static Future<T?> push<T>(BuildContext context, String path) {
    return context.push<T>(path);
  }

  /// Pop
  static void pop<T>(BuildContext context, [T? result]) {
    context.pop(result);
  }
}