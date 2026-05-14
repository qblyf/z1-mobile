import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';

/// 认证结果
abstract class AuthResult {
  const AuthResult();
}

/// 登录结果
class AuthSuccess extends AuthResult {
  final String accessToken;
  final String refreshToken;

  const AuthSuccess({
    required this.accessToken,
    required this.refreshToken,
  });
}

/// 登出结果
class LogoutSuccess extends AuthResult {
  const LogoutSuccess();
}

/// 认证失败
class AuthFailure extends AuthResult {
  final String message;

  const AuthFailure({required this.message});
}

/// 登录参数
class LoginParams extends Equatable {
  final String phone;
  final String pwd;

  const LoginParams({
    required this.phone,
    required this.pwd,
  });

  @override
  List<Object?> get props => [phone, pwd];
}

/// 认证仓库接口
abstract class AuthRepository {
  /// 登录
  Future<Either<AppException, AuthSuccess>> login(LoginParams params);

  /// 登出
  Future<Either<AppException, LogoutSuccess>> logout();

  /// 检查是否已登录
  Future<bool> isAuthenticated();

  /// 获取当前用户信息
  Future<Either<AppException, User>> getCurrentUser();

  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// 清除 Token
  Future<void> clearTokens();
}