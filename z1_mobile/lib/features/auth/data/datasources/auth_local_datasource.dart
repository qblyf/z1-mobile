import '../../../../core/services/token_service.dart';
import '../../domain/entities/user.dart';

/// 本地数据源接口（占位，未接入 DI）
///
/// ⚠️ 当前没有任何调用方：
/// - Token 由 `TokenService` 直接持有，无需经过此层
/// - 用户信息持久化业务尚未启动（profile 页只展示登录时返回的 user 字段）
///
/// 保留这个文件是为 Clean Architecture 留好插槽。真正接入时：
/// 1. `saveUser` / `getUser` / `clearUser` 用 `SharedPreferences` + `jsonEncode(User)` 实现
/// 2. 在 `injection.dart` 注册 `AuthLocalDataSourceImpl`
/// 3. 让 `AuthRepository` 调用此层，而非直接调 `TokenService`
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
    await tokenService.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
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
    await tokenService.clearTokens();
  }

  @override
  bool isAuthenticated() {
    return tokenService.isLoggedIn();
  }

  @override
  Future<void> saveUser(User user) async {
    // TODO(用户信息持久化): 占位实现。未来用 `SharedPreferences.setString('user', jsonEncode(user.toJson()))`
  }

  @override
  Future<User?> getUser() async {
    // TODO(用户信息持久化): 占位实现。未来读 `SharedPreferences.getString('user')` 并 jsonDecode 为 User
    return null;
  }

  @override
  Future<void> clearUser() async {
    // TODO(用户信息持久化): 占位实现。未来 `SharedPreferences.remove('user')`
  }
}