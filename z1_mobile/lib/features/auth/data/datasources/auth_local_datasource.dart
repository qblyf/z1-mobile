import '../../../../core/services/token_service.dart';
import '../../domain/entities/user.dart';

/// 本地数据源接口
abstract class AuthLocalDataSource {
  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// 获取 Token
  String? getAccessToken();
  String? getRefreshToken();

  /// 清除 Token
  Future<void> clearTokens();

  /// 检查是否已登录
  bool isAuthenticated();

  /// 保存用户信息
  Future<void> saveUser(User user);

  /// 获取用户信息
  Future<User?> getUser();

  /// 清除用户信息
  Future<void> clearUser();
}

/// 本地数据源实现
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenService tokenService;

  AuthLocalDataSourceImpl({required this.tokenService});

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    tokenService.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  String? getAccessToken() {
    return tokenService.getAccessToken();
  }

  @override
  String? getRefreshToken() {
    return tokenService.getRefreshToken();
  }

  @override
  Future<void> clearTokens() async {
    tokenService.clearTokens();
  }

  @override
  bool isAuthenticated() {
    return tokenService.isLoggedIn();
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