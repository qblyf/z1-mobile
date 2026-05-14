/// API 常量配置
class ApiConstants {
  ApiConstants._();

  /// 基础 URL
  static const String baseUrl = 'https://z1-fun.zsqk.com.cn/deno';

  /// 超时时间（毫秒）
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  /// API 版本
  static const String apiVersion = 'v1';

  /// 完整 API 前缀（如果后端需要 /v1 前缀）
  static String get apiPrefix => baseUrl;

  /// 认证相关
  static const String login = '/members/phone-login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String userSelf = '/user/self';

  /// 订单相关
  static const String shopSaleList = '/order/shop-sale-list';
  static const String shopSaleAdd = '/order/shop-sale/add';

  /// 会员相关
  static const String membersList = '/members/list';

  /// 库存相关
  static const String stockTakingList = '/stock-taking/list';

  /// 商品相关
  static const String productList = '/product/list';

  /// 序列号查询
  static const String serialTrace = '/goods/serial-trace';
}