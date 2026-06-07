import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z1_mobile/core/api/result.dart';
import 'package:z1_mobile/features/auth/data/models/user_model.dart';
import 'package:z1_mobile/features/auth/presentation/bloc/auth_bloc.dart';

import '../mocks/auth_mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockSessionRemoteDataSource mockSessionRemoteDataSource;
  late MockTokenService mockTokenService;

  setUpAll(() {
    registerFallbackValue(const LoginRequest(
      mobilePhone: '',
      password: '',
    ));
  });

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockSessionRemoteDataSource = MockSessionRemoteDataSource();
    mockTokenService = MockTokenService();
    authBloc = AuthBloc(
      authDatasource: mockAuthRemoteDataSource,
      sessionDatasource: mockSessionRemoteDataSource,
      tokenService: mockTokenService,
    );

    // 通用 stub
    when(() => mockTokenService.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
          permissionToken: any(named: 'permissionToken'),
        )).thenAnswer((_) async {});
    when(() => mockTokenService.savePermissionFor(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockTokenService.clearTokens()).thenAnswer((_) async {});
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testUser = AuthUser(
      userIdent: 1,
      realName: '测试用户',
      mobilePhone: '13800138000',
    );

    const testLoginResponse = LoginResponse(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
      user: testUser,
    );

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        '当未登录时应发出 AuthUnauthenticated 状态',
        setUp: () {
          when(() => mockTokenService.isLoggedIn()).thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        '登录成功（enrich 无新增信息）应发出单个 AuthAuthenticated 状态',
        setUp: () {
          when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
            (_) async => const Success(testLoginResponse),
          );
          // enrich：token 无 deptID + 权限包失败 → 不产生新状态
          when(() => mockTokenService.getAccessToken()).thenReturn(null);
          when(() => mockSessionRemoteDataSource.grantPermissionPackage(any()))
              .thenAnswer((_) async =>
                  const Failure(ApiFailure(type: ApiErrorType.serverError, message: 'x')));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          mobilePhone: '13800138000',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.mobilePhone,
            'user phone',
            '13800138000',
          ),
        ],
        verify: (_) {
          verify(() => mockTokenService.saveTokens(
                accessToken: 'test_access_token',
                refreshToken: 'test_refresh_token',
                permissionToken: null,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '登录成功后 enrich 注入默认仓应两段式 emit',
        setUp: () {
          final token =
              'h.${base64Url.encode(utf8.encode('{"deptID":35}'))}.s';
          when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
            (_) async => const Success(testLoginResponse),
          );
          when(() => mockTokenService.getAccessToken()).thenReturn(token);
          when(() => mockSessionRemoteDataSource.grantPermissionPackage(any()))
              .thenAnswer((_) async => const Success('Bearer jwt'));
          when(() => mockSessionRemoteDataSource.getDefaultWarehouseByDept(
                any(),
                permissionJwt: any(named: 'permissionJwt'),
              )).thenAnswer((_) async => const Success(63));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          mobilePhone: '13800138000',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthAuthenticated>()
              .having((s) => s.user.defaultWarehouseID, 'wh before', null),
          isA<AuthAuthenticated>()
              .having((s) => s.user.defaultWarehouseID, 'wh after', 63)
              .having((s) => s.user.deptID, 'dept', 35),
        ],
        verify: (_) {
          verify(() => mockTokenService.savePermissionFor(
              'shopSaleApplyView', 'Bearer jwt')).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '登录失败时应发出 AuthError 状态',
        setUp: () {
          when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
            (_) async => const Failure(ApiFailure(
              type: ApiErrorType.validationError,
              message: '用户名或密码错误',
            )),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          mobilePhone: '13800138000',
          password: 'wrong_password',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError('用户名或密码错误'),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        '登出应发出 AuthUnauthenticated 状态',
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockTokenService.clearTokens()).called(1);
        },
      );
    });
  });
}
