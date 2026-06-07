import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/datasources/warehouse_remote_datasource.dart';
import 'core/services/token_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/session_remote_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/member/data/datasources/member_remote_datasource.dart';
import 'features/member/presentation/bloc/member_home_bloc.dart';
import 'features/member/presentation/bloc/member_detail_bloc.dart';
import 'features/order/data/datasources/order_detail_remote_datasource.dart';
import 'features/order/data/datasources/order_list_remote_datasource.dart';
import 'features/order/presentation/bloc/order_detail_bloc.dart';
import 'features/order/presentation/bloc/order_list_bloc.dart';
import 'features/retail/data/datasources/product_remote_datasource.dart';
import 'features/retail/data/datasources/member_remote_datasource.dart';
import 'features/retail/data/datasources/coin_discount_remote_datasource.dart';
import 'features/retail/data/datasources/service_remote_datasource.dart';
import 'features/retail/data/datasources/recycle_order_remote_datasource.dart';
import 'features/retail/presentation/bloc/product_select_bloc.dart';
import 'features/retail/presentation/bloc/product_bloc.dart';
import 'features/retail/presentation/bloc/member_bloc.dart';
import 'features/retail/presentation/bloc/coin_discount_bloc.dart';
import 'features/retail/presentation/bloc/service_bloc.dart';
import 'features/retail/presentation/bloc/recycle_order_bloc.dart';
import 'features/mall_order/data/datasources/mall_order_remote_datasource.dart';
import 'features/mall_order/presentation/bloc/mall_order_detail_bloc.dart';
import 'features/mall_order/presentation/bloc/mall_order_list_bloc.dart';
import 'features/inventory/data/datasources/purchase_remote_datasource.dart';
import 'features/inventory/data/datasources/serial_search_remote_datasource.dart';
import 'features/inventory/data/datasources/stocktaking_remote_datasource.dart';
import 'features/inventory/data/datasources/transfer_remote_datasource.dart';
import 'features/inventory/presentation/bloc/purchase_detail_bloc.dart';
import 'features/inventory/presentation/bloc/purchase_inbound_bloc.dart';
import 'features/inventory/presentation/bloc/purchase_list_bloc.dart';
import 'features/inventory/presentation/bloc/serial_search_bloc.dart';
import 'features/inventory/presentation/bloc/stocktaking_detail_bloc.dart';
import 'features/inventory/presentation/bloc/stocktaking_list_bloc.dart';
import 'features/inventory/presentation/bloc/transfer_add_bloc.dart';
import 'features/inventory/presentation/bloc/transfer_detail_bloc.dart';
import 'features/inventory/presentation/bloc/transfer_list_bloc.dart';
import 'features/workbench/data/datasources/workbench_remote_datasource.dart';
import 'features/workbench/presentation/bloc/workbench_bloc.dart';

final getIt = GetIt.instance;

/// 配置依赖注入
Future<void> configureDependencies() async {
  // 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Token Service
  final tokenService = TokenService(prefs: sharedPreferences);
  getIt.registerSingleton<TokenService>(tokenService);

  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'https://z1-fun.zsqk.com.cn/deno',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  getIt.registerSingleton<Dio>(dio);

  // API Client
  final apiClient = ApiClient(dio: dio, tokenService: tokenService);
  getIt.registerSingleton<ApiClient>(apiClient);

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: apiClient),
  );
  getIt.registerLazySingleton<SessionRemoteDataSource>(
    () => SessionRemoteDataSourceImpl(apiClient: apiClient),
  );

  // 共享仓库数据源
  getIt.registerLazySingleton<WarehouseRemoteDataSource>(
    () => WarehouseRemoteDataSourceImpl(apiClient: apiClient),
  );

  // BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      authDatasource: getIt<AuthRemoteDataSource>(),
      sessionDatasource: getIt<SessionRemoteDataSource>(),
      tokenService: tokenService,
    ),
  );

  // Home BLoC
  getIt.registerLazySingleton<HomeBloc>(
    () => HomeBloc(
      dataSource: HomeRemoteDataSourceImpl(apiClient: getIt()),
      authBloc: getIt<AuthBloc>(),
    ),
  );

  // Member DataSource
  getIt.registerLazySingleton<MemberRemoteDataSource>(
    () => MemberRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Member BLoCs
  getIt.registerFactory<MemberHomeBloc>(
    () => MemberHomeBloc(dataSource: getIt<MemberRemoteDataSource>()),
  );

  getIt.registerFactory<MemberDetailBloc>(
    () => MemberDetailBloc(dataSource: getIt<MemberRemoteDataSource>()),
  );

  // Order DataSources & BLoCs
  getIt.registerLazySingleton<OrderListRemoteDataSource>(
    () => OrderListRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<OrderDetailRemoteDataSource>(
    () => OrderDetailRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<OrderListBloc>(
    () => OrderListBloc(dataSource: getIt<OrderListRemoteDataSource>()),
  );

  getIt.registerFactory<OrderDetailBloc>(
    () => OrderDetailBloc(dataSource: getIt<OrderDetailRemoteDataSource>()),
  );

  // Retail DataSources
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<RetailMemberRemoteDataSource>(
    () => RetailMemberRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Retail BLoCs
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(dataSource: getIt<ProductRemoteDataSource>()),
  );

  getIt.registerFactory<ProductSelectBloc>(
    () => ProductSelectBloc(dataSource: getIt<ProductRemoteDataSource>()),
  );

  getIt.registerFactory<MemberBloc>(
    () => MemberBloc(dataSource: getIt<RetailMemberRemoteDataSource>()),
  );

  getIt.registerLazySingleton<CoinDiscountRemoteDataSource>(
    () => CoinDiscountRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<CoinDiscountBloc>(
    () => CoinDiscountBloc(dataSource: getIt<CoinDiscountRemoteDataSource>()),
  );

  // Service DataSource & Bloc
  getIt.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<ServiceBloc>(
    () => ServiceBloc(dataSource: getIt<ServiceRemoteDataSource>()),
  );

  // RecycleOrder DataSource & Bloc
  getIt.registerLazySingleton<RecycleOrderRemoteDataSource>(
    () => RecycleOrderRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<RecycleOrderBloc>(
    () => RecycleOrderBloc(dataSource: getIt<RecycleOrderRemoteDataSource>()),
  );

  // Mall order DataSource & BLoCs
  getIt.registerLazySingleton<MallOrderRemoteDataSource>(
    () => MallOrderRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<MallOrderListBloc>(
    () => MallOrderListBloc(dataSource: getIt<MallOrderRemoteDataSource>()),
  );

  getIt.registerFactory<MallOrderDetailBloc>(
    () => MallOrderDetailBloc(dataSource: getIt<MallOrderRemoteDataSource>()),
  );

  // Inventory DataSources
  getIt.registerLazySingleton<StocktakingRemoteDataSource>(
    () => StocktakingRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<SerialSearchRemoteDataSource>(
    () => SerialSearchRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Inventory BLoCs
  getIt.registerFactory<StocktakingListBloc>(
    () => StocktakingListBloc(dataSource: getIt<StocktakingRemoteDataSource>()),
  );

  getIt.registerFactory<StocktakingAddBloc>(
    () => StocktakingAddBloc(dataSource: getIt<StocktakingRemoteDataSource>()),
  );

  getIt.registerFactory<StocktakingDetailBloc>(
    () =>
        StocktakingDetailBloc(dataSource: getIt<StocktakingRemoteDataSource>()),
  );

  getIt.registerFactory<TransferListBloc>(
    () => TransferListBloc(dataSource: getIt<TransferRemoteDataSource>()),
  );

  getIt.registerFactory<TransferAddBloc>(
    () => TransferAddBloc(dataSource: getIt<TransferRemoteDataSource>()),
  );

  getIt.registerFactory<TransferDetailBloc>(
    () => TransferDetailBloc(dataSource: getIt<TransferRemoteDataSource>()),
  );

  getIt.registerFactory<PurchaseListBloc>(
    () => PurchaseListBloc(dataSource: getIt<PurchaseRemoteDataSource>()),
  );

  getIt.registerFactory<PurchaseDetailBloc>(
    () => PurchaseDetailBloc(dataSource: getIt<PurchaseRemoteDataSource>()),
  );

  getIt.registerFactory<PurchaseInboundBloc>(
    () => PurchaseInboundBloc(dataSource: getIt<PurchaseRemoteDataSource>()),
  );

  getIt.registerFactory<SerialSearchBloc>(
    () => SerialSearchBloc(dataSource: getIt<SerialSearchRemoteDataSource>()),
  );

  // Workbench DataSource & Bloc
  getIt.registerLazySingleton<WorkbenchRemoteDataSource>(
    () => WorkbenchRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<WorkbenchBloc>(
    () => WorkbenchBloc(dataSource: getIt<WorkbenchRemoteDataSource>()),
  );
}
