/// API 基础常量（baseUrl / 超时 / apiPrefix）
///
/// 业务端点请使用 `core/api/api_endpoints.dart` 中的 `ApiEndpoints`。
class ApiConstants {
  ApiConstants._();

  /// 基础 URL
  static const String baseUrl = 'https://z1-fun.zsqk.com.cn/deno';

  /// 超时时间（毫秒）
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  /// 完整 API 前缀（拦截器内部刷新 token 时拼接绝对地址用）
  static String get apiPrefix => baseUrl;
}
