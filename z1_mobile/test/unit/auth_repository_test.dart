import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z1_mobile/core/api/result.dart';
import 'package:z1_mobile/core/errors/exceptions.dart';
import 'package:z1_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:z1_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:z1_mobile/features/auth/data/models/user_model.dart';
import 'package:z1_mobile/features/auth/domain/entities/user.dart' as entities;
import 'package:z1_mobile/features/auth/domain/repositories/auth_repository.dart';

// ===== Mocks =====

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

// ===== 测试用的具体实现 =====

class TestAuthRepository implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  TestAuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AppException, AuthSuccess>> login(LoginParams params) async {
    try {
      final request = LoginRequest(
        mobilePhone: params.phone,
        password: params.pwd,
      );
      final result = await remoteDataSource.login(request);
      
      return result.fold(
        (failure) => Left(AppException(message: failure.message)),
        (response) async {
          await localDataSource.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? '',
          );
          return Right(AuthSuccess(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? '',
          ));
        },
      );
    } catch (e) {
      return Left(AppException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, LogoutSuccess>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearTokens();
      return const Right(LogoutSuccess());
    } catch (e) {
      return Left(AppException(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.isAuthenticated();
  }

  @override
  Future<Either<AppException, entities.User>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getUserInfo();
      return result.fold(
        (failure) => Left(AppException(message: failure.message)),
        (userModel) => Right(entities.User(
          id: userModel.userIdent.toString(),
          name: userModel.realName,
          phone: userModel.mobilePhone,
          email: userModel.email,
        )),
      );
    } catch (e) {
      return Left(AppException(message: e.toString()));
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearTokens() async {
    await localDataSource.clearTokens();
  }
}

void main() {
  late TestAuthRepository repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = TestAuthRepository(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(const LoginRequest(
      mobilePhone: '',
      password: '',
    ));
    registerFallbackValue(const LoginParams(phone: '', pwd: ''));
  });

  group('AuthRepository - login', () {
    const testPhone = '13800138000';
    const testPwd = 'password123';
    const testAccessToken = 'test_access_token';
    const testRefreshToken = 'test_refresh_token';

    final testLoginResponse = LoginResponse(
      accessToken: testAccessToken,
      refreshToken: testRefreshToken,
      expiresIn: 3600,
      user: const AuthUser(userIdent: 1, realName: '测试用户', mobilePhone: testPhone),
    );

    test('登录成功返回 AuthSuccess', () async {
      // arrange
      when(() => mockRemoteDataSource.login(any())).thenAnswer(
        (_) async => Success(testLoginResponse),
      );
      when(() => mockLocalDataSource.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      // act
      final result = await repository.login(
        const LoginParams(phone: testPhone, pwd: testPwd),
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right'),
        (r) {
          expect(r.accessToken, testAccessToken);
          expect(r.refreshToken, testRefreshToken);
        },
      );
      verify(() => mockLocalDataSource.saveTokens(
            accessToken: testAccessToken,
            refreshToken: testRefreshToken,
          )).called(1);
    });

    test('登录失败返回错误', () async {
      // arrange
      when(() => mockRemoteDataSource.login(any())).thenAnswer(
        (_) async => Failure(ApiFailure(
          type: ApiErrorType.unauthorized,
          message: '用户名或密码错误',
        )),
      );

      // act
      final result = await repository.login(
        const LoginParams(phone: testPhone, pwd: 'wrong_password'),
      );

      // assert
      expect(result.isLeft(), true);
    });
  });

  group('AuthRepository - logout', () {
    test('登出成功返回 LogoutSuccess', () async {
      // arrange
      when(() => mockRemoteDataSource.logout()).thenAnswer(
        (_) async => const Success(null),
      );
      when(() => mockLocalDataSource.clearTokens()).thenAnswer((_) async {});

      // act
      final result = await repository.logout();

      // assert
      expect(result.isRight(), true);
      verify(() => mockLocalDataSource.clearTokens()).called(1);
    });

    test('登出失败返回错误', () async {
      // arrange
      when(() => mockRemoteDataSource.logout()).thenAnswer(
        (_) async => Failure(ApiFailure(
          type: ApiErrorType.serverError,
          message: '服务器错误',
        )),
      );

      // act
      final result = await repository.logout();

      // assert
      expect(result.isLeft(), true);
    });
  });

  group('AuthRepository - isAuthenticated', () {
    test('当存在有效 Token 时返回 true', () async {
      // arrange
      when(() => mockLocalDataSource.isAuthenticated())
          .thenReturn(true);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, true);
    });

    test('当不存在 Token 时返回 false', () async {
      // arrange
      when(() => mockLocalDataSource.isAuthenticated())
          .thenReturn(false);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, false);
    });
  });

  group('AuthRepository - getCurrentUser', () {
    test('获取用户信息成功', () async {
      // arrange
      const testUserModel = AuthUser(
        userIdent: 1,
        realName: '测试用户',
        mobilePhone: '13800138000',
        email: 'test@example.com',
      );
      when(() => mockRemoteDataSource.getUserInfo()).thenAnswer(
        (_) async => Success(testUserModel),
      );

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right'),
        (r) {
          expect(r.id, '1');
          expect(r.name, '测试用户');
          expect(r.phone, '13800138000');
        },
      );
    });

    test('获取用户信息失败', () async {
      // arrange
      when(() => mockRemoteDataSource.getUserInfo()).thenAnswer(
        (_) async => Failure(ApiFailure(
          type: ApiErrorType.unauthorized,
          message: '未登录',
        )),
      );

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result.isLeft(), true);
    });
  });

  group('AuthRepository - saveTokens', () {
    test('保存 Token 成功', () async {
      // arrange
      when(() => mockLocalDataSource.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      // act
      await repository.saveTokens(
        accessToken: 'token123',
        refreshToken: 'refresh456',
      );

      // assert
      verify(() => mockLocalDataSource.saveTokens(
            accessToken: 'token123',
            refreshToken: 'refresh456',
          )).called(1);
    });
  });

  group('AuthRepository - clearTokens', () {
    test('清除 Token 成功', () async {
      // arrange
      when(() => mockLocalDataSource.clearTokens()).thenAnswer((_) async {});

      // act
      await repository.clearTokens();

      // assert
      verify(() => mockLocalDataSource.clearTokens()).called(1);
    });
  });
}