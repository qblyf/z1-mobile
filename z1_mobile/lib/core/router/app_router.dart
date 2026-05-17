import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/retail/data/models/retail_order_model.dart';
import '../../../features/retail/presentation/pages/retail_entry_page.dart';
import '../../../features/retail/presentation/pages/retail_product_page.dart';
import '../../../features/retail/presentation/pages/retail_confirm_page.dart';
import '../../../features/retail/presentation/pages/retail_payment_page.dart';
import '../../../features/retail/presentation/pages/retail_complete_page.dart';
import '../../../features/retail/presentation/pages/coupon_select_page.dart';
import '../../../features/order/presentation/pages/order_list_page.dart';
import '../../../features/order/presentation/pages/order_detail_page.dart';
import '../../../features/member/presentation/pages/member_home_page.dart';
import '../../../features/member/presentation/pages/member_detail_page.dart';
import '../../../features/workbench/presentation/pages/workbench_page.dart';
import '../../../features/task/presentation/pages/task_home_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_scaffold.dart';

/// App 路由配置
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  /// 路由名称常量
  static const String login = '/login';
  static const String home = '/home';
  static const String retailEntry = '/order/retail/entry';
  static const String retailProduct = '/order/retail/product';
  static const String retailConfirm = '/order/retail/confirm';
  static const String retailCouponSelect = '/order/retail/coupon-select';
  static const String retailPayment = '/order/retail/payment';
  static const String retailComplete = '/order/retail/complete';
  static const String orderList = '/order/list';
  static String orderDetail(String orderNumber) => '/order/$orderNumber';

  /// 跳转到登录页
  static void goLogin(BuildContext context) {
    context.go(login);
  }

  /// 跳转到首页
  static void goHome(BuildContext context) {
    context.go(home);
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      // 登录页（无 TabBar）
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // 主页面壳（底部导航）
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Tab 1: 首页
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              // 零售开单链路
              GoRoute(
                path: 'retail/entry',
                name: 'retailEntry',
                builder: (context, state) => const RetailEntryPage(),
              ),
              GoRoute(
                path: 'retail/product',
                name: 'retailProduct',
                builder: (context, state) {
                  final order = state.extra as RetailOrder?;
                  return RetailProductPage(initialOrder: order);
                },
              ),
              GoRoute(
                path: 'retail/confirm',
                name: 'retailConfirm',
                builder: (context, state) {
                  final order = state.extra as RetailOrder;
                  return RetailConfirmPage(order: order);
                },
              ),
              GoRoute(
                path: 'retail/coupon-select',
                name: 'retailCouponSelect',
                builder: (context, state) => const CouponSelectPage(),
              ),
              GoRoute(
                path: 'retail/payment',
                name: 'retailPayment',
                builder: (context, state) {
                  final order = state.extra as RetailOrder;
                  return RetailPaymentPage(order: order);
                },
              ),
              GoRoute(
                path: 'retail/complete',
                name: 'retailComplete',
                builder: (context, state) {
                  final order = state.extra as RetailOrder;
                  return RetailCompletePage(order: order);
                },
              ),
              // 订单列表
              GoRoute(
                path: 'order/list',
                name: 'homeOrderList',
                builder: (context, state) => const OrderListPage(),
              ),
              // 订单详情
              GoRoute(
                path: 'order/:orderNumber',
                name: 'homeOrderDetail',
                builder: (context, state) {
                  final orderNumber = state.pathParameters['orderNumber'] ?? '';
                  return OrderDetailPage(orderNumber: orderNumber);
                },
              ),
            ],
          ),

          // Tab 2: 会员
          GoRoute(
            path: '/member',
            name: 'member',
            builder: (context, state) => const MemberHomePage(),
            routes: [
              GoRoute(
                path: ':memberId',
                name: 'memberDetail',
                builder: (context, state) {
                  final memberId = int.tryParse(state.pathParameters['memberId'] ?? '') ?? 0;
                  return MemberDetailPage(memberId: memberId);
                },
              ),
            ],
          ),

          // Tab 3: 工作台
          GoRoute(
            path: '/workbench',
            name: 'workbench',
            builder: (context, state) => const WorkbenchPage(),
          ),

          // Tab 4: 任务
          GoRoute(
            path: '/task',
            name: 'task',
            builder: (context, state) => const TaskHomePage(),
          ),

          // Tab 5: 我的
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // /order 顶层路由（在 Shell 内，与 /home 平级）
          GoRoute(
            path: '/order',
            name: 'order',
            builder: (context, state) => const OrderListPage(),
            routes: [
              // 零售开单链路（从首页/工作台跳转时不走 /order 前缀，但独立入口可走 /order/retail/*）
              GoRoute(
                path: 'retail/entry',
                name: 'orderRetailEntry',
                builder: (context, state) => const RetailEntryPage(),
              ),
              GoRoute(
                path: 'retail/product',
                name: 'orderRetailProduct',
                builder: (context, state) {
                  final order = state.extra as RetailOrder?;
                  return RetailProductPage(initialOrder: order);
                },
              ),
              GoRoute(
                path: 'retail/confirm',
                name: 'orderRetailConfirm',
                builder: (context, state) {
                  final order = state.extra as RetailOrder;
                  return RetailConfirmPage(order: order);
                },
              ),
              GoRoute(
                path: 'retail/coupon-select',
                name: 'orderRetailCouponSelect',
                builder: (context, state) => const CouponSelectPage(),
              ),
              GoRoute(
                path: 'retail/payment',
                name: 'orderRetailPayment',
                builder: (context, state) {
                  final order = state.extra as RetailOrder;
                  return RetailPaymentPage(order: order);
                },
              ),
              GoRoute(
                path: 'retail/complete',
                name: 'orderRetailComplete',
                builder: (context, state) {
                  final order = state.extra as RetailOrder;
                  return RetailCompletePage(order: order);
                },
              ),
              // 订单列表
              GoRoute(
                path: 'list',
                name: 'orderList',
                builder: (context, state) => const OrderListPage(),
              ),
              // 订单详情
              GoRoute(
                path: ':orderNumber',
                name: 'orderDetail',
                builder: (context, state) {
                  final orderNumber = state.pathParameters['orderNumber'] ?? '';
                  return OrderDetailPage(orderNumber: orderNumber);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('页面未找到'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () => context.go(home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}