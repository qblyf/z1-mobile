import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';

/// 本地数据源接口
abstract class AuthLocalDataSource {
  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// 获取 Token
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  /// 清除 Token
  Future<void> clearTokens();

  /// 检查是否已登录
  Future<bool> isAuthenticated();

  /// 保存用户信息
  Future<void> saveUser(User user);

  /// 获取用户信息
  Future<User?> getUser();

  /// 清除用户信息
  Future<void> clearUser();
}

/// 本地数据源实现
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveUser(User user) async {
    // TODO: 实现用户信息存储
  }

  @override
  Future<User?> getUser() async {
    // TODO: 实现用户信息获取
    return null;
  }

  @override
  Future<void> clearUser() async {
    // TODO: 实现用户信息清除
  }
}