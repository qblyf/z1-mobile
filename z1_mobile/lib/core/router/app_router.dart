import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/workbench/presentation/pages/workbench_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/retail/presentation/pages/retail_entry_page.dart';
import '../../features/order/presentation/pages/order_list_page.dart';
import '../../features/order/presentation/pages/order_detail_page.dart';
import '../../features/retail/presentation/pages/retail_product_page.dart';
import '../../features/retail/presentation/pages/retail_confirm_page.dart';
import '../../features/retail/presentation/pages/retail_payment_page.dart';
import '../../features/retail/presentation/pages/retail_complete_page.dart';
import '../../features/retail/data/models/retail_order_model.dart';
import '../../features/member/presentation/pages/member_home_page.dart';
import '../../features/member/presentation/pages/member_detail_page.dart';
import '../../features/task/presentation/pages/task_home_page.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // 登录页（不需要底部导航）
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // 主页面壳（底部导航）
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // 首页
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            // 零售开单入口
            GoRoute(
              path: 'retail/entry',
              builder: (context, state) => const RetailEntryPage(),
            ),
            // 商品选购
            GoRoute(
              path: 'retail/product',
              builder: (context, state) {
                final order = state.extra as RetailOrder?;
                return RetailProductPage(initialOrder: order);
              },
            ),
            // 订单确认
            GoRoute(
              path: 'retail/confirm',
              builder: (context, state) {
                final order = state.extra as RetailOrder;
                return RetailConfirmPage(order: order);
              },
            ),
            // 收款
            GoRoute(
              path: 'retail/payment',
              builder: (context, state) {
                final order = state.extra as RetailOrder;
                return RetailPaymentPage(order: order);
              },
            ),
            // 完成
            GoRoute(
              path: 'retail/complete',
              builder: (context, state) {
                final order = state.extra as RetailOrder;
                return RetailCompletePage(order: order);
              },
            ),
            // 订单列表
            GoRoute(
              path: 'order/list',
              builder: (context, state) => const OrderListPage(),
            ),
            // 订单详情
            GoRoute(
              path: 'order/:orderNumber',
              builder: (context, state) {
                final orderNumber = state.pathParameters['orderNumber'] ?? '';
                return OrderDetailPage(orderNumber: orderNumber);
              },
            ),
          ],
        ),
        // 会员
        GoRoute(
          path: '/member',
          builder: (context, state) => const MemberHomePage(),
          routes: [
            GoRoute(
              path: ':memberId',
              builder: (context, state) {
                final memberId = int.tryParse(state.pathParameters['memberId'] ?? '') ?? 0;
                return MemberDetailPage(memberId: memberId);
              },
            ),
          ],
        ),
        // 工作台
        GoRoute(
          path: '/workbench',
          builder: (context, state) => const WorkbenchPage(),
        ),
        // 任务
        GoRoute(
          path: '/task',
          builder: (context, state) => const TaskHomePage(),
        ),
        // 我的
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);