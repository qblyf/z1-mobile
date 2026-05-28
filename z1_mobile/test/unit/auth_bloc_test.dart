import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z1_mobile/core/api/result.dart';
import 'package:z1_mobile/core/errors/exceptions.dart';
import 'package:z1_mobile/core/services/token_service.dart';
import 'package:z1_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:z1_mobile/features/auth/data/models/user_model.dart';
import 'package:z1_mobile/features/auth/presentation/bloc/auth_bloc.dart';

import '../mocks/auth_mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockTokenService mockTokenService;

  setUpAll(() {
    registerFallbackValue(const LoginRequest(
      mobilePhone: '',
      password: '',
    ));
  });

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockTokenService = MockTokenService();
    authBloc = AuthBloc(
      authDatasource: mockAuthRemoteDataSource,
      tokenService: mockTokenService,
    );
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

    final testLoginResponse = LoginResponse(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
      user: testUser,
    );

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        '当未登录时应发出 AuthUnauthenticated 状态',
        setUp: () {
          when(() => mockTokenService.isLoggedIn())
              .thenReturn(false);
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
        '登录成功时应发出 AuthAuthenticated 状态',
        setUp: () {
          when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
            (_) async => Success(testLoginResponse),
          );
          when(() => mockTokenService.saveTokens(
                accessToken: any(named: 'accessToken'),
                refreshToken: any(named: 'refreshToken'),
              )).thenAnswer((_) async {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          mobilePhone: '13800138000',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthAuthenticated>().having(
            (state) => state.user?.mobilePhone,
            'user phone',
            '13800138000',
          ),
        ],
        verify: (_) {
          verify(() => mockTokenService.saveTokens(
                accessToken: 'test_access_token',
                refreshToken: 'test_refresh_token',
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '登录失败时应发出 AuthError 状态',
        setUp: () {
          when(() => mockAuthRemoteDataSource.login(any())).thenAnswer(
            (_) async => Failure(ApiFailure(
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
        setUp: () {
          when(() => mockTokenService.clearTokens()).thenAnswer((_) async {});
        },
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