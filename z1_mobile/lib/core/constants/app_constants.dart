/// App 级常量
class AppConstants {
  AppConstants._();

  /// App 名称
  static const String appName = 'Z1 全网连锁';

  /// App 版本
  static const String appVersion = '1.0.0';

  /// 调试模式
  static const bool isDebug = true;

  /// Token 存储 Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';

  /// 用户信息存储 Keys
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userInfoKey = 'user_info';
  static const String rememberMeKey = 'remember_me';
  static const String savedAccountKey = 'saved_account';
  static const String savedPasswordKey = 'saved_password';

  /// 门店信息存储 Keys
  static const String currentShopIdKey = 'current_shop_id';
  static const String currentShopNameKey = 'current_shop_name';

  /// 默认分页大小
  static const int defaultPageSize = 20;

  /// 扫码类型
  static const String barcodeType = 'barcode';
  static const String qrcodeType = 'qrcode';
  static const String serialType = 'serial';
}