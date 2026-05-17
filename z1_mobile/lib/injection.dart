import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/services/token_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/member/data/datasources/member_remote_datasource.dart';
import 'features/member/presentation/bloc/member_home_bloc.dart';
import 'features/member/presentation/bloc/member_detail_bloc.dart';
import 'features/retail/data/datasources/product_remote_datasource.dart';
import 'features/retail/data/datasources/member_remote_datasource.dart';
import 'features/retail/data/datasources/coin_discount_remote_datasource.dart';
import 'features/retail/presentation/bloc/product_bloc.dart';
import 'features/retail/presentation/bloc/member_bloc.dart';
import 'features/retail/presentation/bloc/coin_discount_bloc.dart';

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

  // BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      authDatasource: getIt<AuthRemoteDataSource>(),
      tokenService: tokenService,
    ),
  );

  // Home BLoC
  getIt.registerLazySingleton<HomeBloc>(
    () => HomeBloc(dataSource: HomeRemoteDataSourceImpl(apiClient: getIt())),
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

  getIt.registerFactory<MemberBloc>(
    () => MemberBloc(dataSource: getIt<RetailMemberRemoteDataSource>()),
  );

  getIt.registerLazySingleton<CoinDiscountRemoteDataSource>(
    () => CoinDiscountRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerFactory<CoinDiscountBloc>(
    () => CoinDiscountBloc(dataSource: getIt<CoinDiscountRemoteDataSource>()),
  );
}