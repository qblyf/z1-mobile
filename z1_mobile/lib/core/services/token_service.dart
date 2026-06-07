import 'package:shared_preferences/shared_preferences.dart';

/// Token 存储服务
/// 使用 SharedPreferences 存储 Token（兼容模拟器）
class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _permissionTokenKey = 'permission_token';

  /// 按权限包 key 存储 permissionsJWT 的前缀
  /// （后端每个权限包 key 对应一个独立 JWT，无整包 key）
  static const _permissionPkgPrefix = 'permission_pkg_';

  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  /// 获取 Access Token
  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  /// 获取 Refresh Token
  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  /// 获取 Permission Token（用于权限验证）
  String? getPermissionToken() {
    return _prefs.getString(_permissionTokenKey);
  }

  /// 按权限包 key 保存 permissionsJWT（值自带 "Bearer " 前缀）
  Future<void> savePermissionFor(String key, String jwt) async {
    await _prefs.setString('$_permissionPkgPrefix$key', jwt);
  }

  /// 按权限包 key 读取 permissionsJWT
  String? getPermissionFor(String key) {
    return _prefs.getString('$_permissionPkgPrefix$key');
  }

  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? permissionToken,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }
    if (permissionToken != null) {
      await _prefs.setString(_permissionTokenKey, permissionToken);
    }
  }

  /// 清除 Token（退出登录时调用）
  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_permissionTokenKey);
    // 清理所有按 key 存储的权限包 JWT
    final pkgKeys =
        _prefs.getKeys().where((k) => k.startsWith(_permissionPkgPrefix));
    for (final k in pkgKeys) {
      await _prefs.remove(k);
    }
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
