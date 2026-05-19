import 'package:shared_preferences/shared_preferences.dart';

/// Token 存储服务
/// 使用 SharedPreferences 存储 Token（兼容模拟器）
class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

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

  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// 清除 Token（退出登录时调用）
  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}