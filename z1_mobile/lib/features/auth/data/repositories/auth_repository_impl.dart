import 'package:dartz/dartz.dart';

import '../../../../core/api/api_error.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// 认证仓库实现
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AppException, AuthSuccess>> login(LoginParams params) async {
    try {
      final response = await remoteDataSource.login(
        params.phone,
        params.pwd,
      );

      final accessToken = response['token'] as String? ?? '';

      await saveTokens(accessToken: accessToken, refreshToken: '');

      return Right(AuthSuccess(
        accessToken: accessToken,
        refreshToken: '',
      ));
    } on ApiException catch (e) {
      return Left(AppException(message: e.message));
    } catch (e) {
      return Left(AppException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, LogoutSuccess>> logout() async {
    try {
      await remoteDataSource.logout();
      await clearTokens();
      return const Right(LogoutSuccess());
    } on ApiException catch (e) {
      return Left(AppException(message: e.message));
    } catch (e) {
      return Left(AppException(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.isAuthenticated();
  }

  @override
  Future<Either<AppException, User>> getCurrentUser() async {
    try {
      final response = await remoteDataSource.getUserInfo();
      final user = User(
        id: response['id'] as String,
        name: response['name'] as String,
        avatar: response['avatar'] as String?,
        phone: response['phone'] as String?,
        email: response['email'] as String?,
        roles: (response['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        shopId: response['shop_id'] as String?,
        shopName: response['shop_name'] as String?,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(AppException(message: e.message));
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
    await localDataSource.clearUser();
  }
}