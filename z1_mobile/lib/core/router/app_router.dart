import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../features/member/presentation/pages/member_add_page.dart';
import '../../features/member/presentation/pages/member_creditscore_page.dart';
import '../../features/member/presentation/pages/member_creditscore_edit_page.dart';
import '../../features/task/presentation/pages/task_home_page.dart';
import '../../features/inventory/presentation/pages/inventory_home_page.dart';
import '../../features/inventory/presentation/pages/stocktaking_list_page.dart';
import '../../features/inventory/presentation/pages/stocktaking_add_page.dart';
import '../../features/inventory/presentation/pages/stocktaking_detail_page.dart';
import '../../features/inventory/presentation/pages/transfer_list_page.dart';
import '../../features/inventory/presentation/pages/transfer_add_page.dart';
import '../../features/inventory/presentation/pages/transfer_detail_page.dart';
import '../../features/inventory/presentation/pages/purchase_list_page.dart';
import '../../features/inventory/presentation/pages/purchase_detail_page.dart';
import '../../features/inventory/presentation/pages/purchase_inbound_page.dart';
import '../../features/inventory/presentation/pages/serial_search_page.dart';
import '../../features/retail/presentation/bloc/product_bloc.dart';
import '../../features/retail/presentation/bloc/product_select_bloc.dart';
import '../../features/retail/presentation/bloc/member_bloc.dart';
import '../../features/retail/presentation/bloc/coin_discount_bloc.dart';
import '../../features/retail/presentation/bloc/service_bloc.dart';
import '../../features/retail/presentation/pages/select_cash_coupons_page.dart';
import '../../features/retail/presentation/pages/select_renew_subsidy_page.dart';
import '../../features/retail/presentation/pages/select_recycle_order_page.dart';
import '../../injection.dart';
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
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<MemberBloc>(),
                child: const RetailEntryPage(),
              ),
            ),
            // 商品选购
            GoRoute(
              path: 'retail/product',
              builder: (context, state) {
                final order = state.extra as RetailOrder?;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<ProductSelectBloc>()),
                    BlocProvider(create: (_) => getIt<ServiceBloc>()),
                  ],
                  child: RetailProductPage(initialOrder: order),
                );
              },
            ),
            // 订单确认
            GoRoute(
              path: 'retail/confirm',
              builder: (context, state) {
                final order = state.extra as RetailOrder;
                return BlocProvider(
                  create: (_) => getIt<CoinDiscountBloc>(),
                  child: RetailConfirmPage(order: order),
                );
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
            // 代金券选择
            GoRoute(
              path: 'retail/cash-coupons',
              builder: (context, state) {
                return const SelectCashCouponsPage();
              },
            ),
            // 换新补贴选择
            GoRoute(
              path: 'retail/renew-subsidy',
              builder: (context, state) {
                return const SelectRenewSubsidyPage();
              },
            ),
            // 回收单选择（以旧换新）
            GoRoute(
              path: 'retail/recycle-order',
              builder: (context, state) {
                return const SelectRecycleOrderPage();
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
              path: 'add',
              name: 'memberAdd',
              builder: (context, state) => const MemberAddPage(),
            ),
            GoRoute(
              path: ':memberId/creditscore',
              name: 'memberCreditscore',
              builder: (context, state) {
                final memberId = int.tryParse(state.pathParameters['memberId'] ?? '') ?? 0;
                return MemberCreditscorePage(memberId: memberId);
              },
            ),
            GoRoute(
              path: ':memberId/creditscore/edit',
              name: 'memberCreditscoreEdit',
              builder: (context, state) {
                final memberId = int.tryParse(state.pathParameters['memberId'] ?? '') ?? 0;
                return MemberCreditscoreEditPage(memberId: memberId);
              },
            ),
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
        // 库存管理
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryHomePage(),
          routes: [
            GoRoute(
              path: 'stocktaking',
              builder: (context, state) => const StocktakingListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'stocktakingAdd',
                  builder: (context, state) => const StocktakingAddPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'stocktakingDetail',
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    return StocktakingDetailPage(id: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'transfer',
              builder: (context, state) => const TransferListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'transferAdd',
                  builder: (context, state) => const TransferAddPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'transferDetail',
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    return TransferDetailPage(id: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'purchase-list',
              builder: (context, state) => const PurchaseListPage(),
            ),
            GoRoute(
              path: 'purchase/:id',
              name: 'purchaseDetail',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return PurchaseDetailPage(id: id);
              },
            ),
            GoRoute(
              path: 'purchase-inbound/:id',
              name: 'purchaseInbound',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return PurchaseInboundPage(id: id);
              },
            ),
            GoRoute(
              path: 'serial-search',
              builder: (context, state) => const SerialSearchPage(),
            ),
          ],
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