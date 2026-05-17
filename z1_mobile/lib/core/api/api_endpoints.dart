/// API 端点定义
/// 参考 z1-mid/src/model/z1/ 的 API 路径
class ApiEndpoints {
  ApiEndpoints._();

  // ===== 认证 =====
  static const String login = '/members/phone-login';
  static const String refreshToken = '/auth/refresh-token';

  // ===== 订单 =====
  /// 创建零售单
  static const String shopSaleAdd = '/order/sale-shop-add';
  /// 查询零售单列表
  static const String shopSaleList = '/order/shop-sale-list';
  /// 查询零售单数量
  static String shopSaleCount([Map<String, dynamic>? params]) {
    return '/order/shop-sale-count${params != null ? '?${_encodeParams(params)}' : ''}';
  }
  /// 零售单详情（订单商品列表）
  static String shopSaleInfo(int orderId) => '/order-product/list?orderID=$orderId';
  /// 零售单详情
  static String shopSaleInfoByNumber(String orderNumber) => '/order/shop-sale-info/$orderNumber';

  // ===== 金额单位说明 =====
  // 所有金额字段单位是分（cent），显示时需除以 100

  // ===== 会员 =====
  /// 手机号搜索会员（GET）
  static const String memberSearchByPhones = '/members/list-phones';
  /// 会员详情
  static String memberDetail(int ident) => '/members/$ident';
  /// 新增会员
  static const String memberAdd = '/members/add';
  /// 积分查询：直接用 GET /members/self 返回的 experience 字段
  /// POST /members/experience 是积分调整接口
  static const String memberExperienceEdit = '/members/experience/edit';

  // ===== 商品 =====
  /// 商品列表
  static const String productList = '/product/list';
  /// 条码查商品
  static String productStockByCode(String code) => '/product-stock-by-code?code=$code';

  // ===== 优惠券 =====
  /// 会员优惠券列表
  static const String couponSelf = '/coupons/self';

  // ===== 仓库 =====
  /// 仓库列表
  static const String warehouseList = '/warehouse/list-base';

  // ===== 盘库 =====
  /// 盘库列表
  static const String stocktakingList = '/stock-taking/list';

  // ===== 采购 =====
  /// 采购列表
  static const String purchaseList = '/purchase/list';
  /// 盘库详情
  static String stocktakingDetail(int id) => '/stock-taking/detail?ids[]=$id';
  /// 新建盘库
  static const String stocktakingAdd = '/stock-taking/add';
  /// 盘库商品列表
  static String stocktakingProducts(int id) => '/stock-taking/$id/products';
  /// 完成盘库
  static String stocktakingEnd(int id) => '/stock-taking/end';
  /// 重新盘库
  static String stocktakingRestart(int id) => '/stock-taking/restocktaking';
  /// 盘库方案列表
  static const String stocktakingPlanList = '/stock-taking-plan/list';

  // ===== 调拨 =====
  /// 调拨列表
  static const String transferList = '/transfer/list';

  // ===== 通用 =====
  /// 用户信息（登录后获取）
  static const String userSelf = '/members/self';
  /// 登出
  static const String logout = '/auth/logout';

  // ===== 序列号查询 =====
  /// 序列号查询
  static const String serialSearch = '/goods/serial-search';
  /// 条码查商品
  static String productBarcode(String code) => '/product/barcode/$code';
}

/// 辅助方法：URL 参数编码
String _encodeParams(Map<String, dynamic> params) {
  return params.entries
      .where((e) => e.value != null)
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
      .join('&');
}