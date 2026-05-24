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
  /// 会员列表（GET）
  static String memberList({String keyword = '', int page = 1, int pageSize = 20}) =>
      '/members/list?keyword=$keyword&page=$page&pageSize=$pageSize';
  /// 会员详情（GET）
  static String memberSpecified(int memberId) => '/members/specified?userIdents=$memberId';
  /// 新增会员
  static const String memberAdd = '/members/add';
  /// 积分查询：直接用 GET /members/self 返回的 experience 字段
  /// POST /members/experience 是积分调整接口
  static const String memberExperienceEdit = '/members/experience';

  // ===== 商品 =====
  /// 商品列表
  static const String productList = '/product/list';
  /// 商品选择基础数据（分类+商品）- 使用 /sku/select-base 接口
  static const String productSelectBase = '/sku/select-base';
  /// 批量查询商品
  static String productSelect(String ids) => '/product/select?ids=$ids';

  // ===== SKU（标品） =====
  /// SKU选择基础数据（标品）
  static const String skuSelectBase = '/sku/select-base';
  /// SPU总库存查询（POST）
  /// Body: { spuIDs: [1, 2, 3], warehouseIDs?: [1, 2] }
  /// 返回: [{spuID, stock, lockStock, saleStock}]
  static const String spuGetStock = '/spu/get-stock';
  /// SKU库存查询（GET）
  /// Query: spu={spuId}
  /// 返回: [{skuID, virtualStock, saleStock}]
  static String spuSkuStock(int spuId) => '/spu/sku-stock?spu=$spuId';

  // ===== 分类 =====
  /// 分类列表（type: 1=商品分类，pid=0 表示顶级）
  /// 返回数据通过 pid 字段构建分类树
  static String categoryList({int type = 1}) => '/category/list?type=$type';
  /// 顶级分类列表
  static const String categoryTop = '/category/top';
  /// 商城分类列表（3级结构：品类->品牌->系列）
  /// 使用 pids 字段构建层级关系
  static const String mallCategoryList = '/mall-category/list';
  /// SPU列表（按分类ID）
  static String spuList({int? cateId}) => cateId != null ? '/spu/list?cateId=$cateId' : '/spu/list';
  /// SPU列表（按商城分类ID）
  static String spuListByMallCate(int mallCateId) => '/spu/list?mallCateId=$mallCateId';

  // ===== 服务 =====
  /// 服务列表
  static const String serveList = '/serve/list';

  // ===== 优惠券 =====
  /// 会员优惠券列表
  static const String couponSelf = '/coupons/self';

  // ===== 代金券（现金券） =====
  /// 可用代金券列表（零售开单用）
  static const String availableCashCoupons = '/cash-coupon/available';
  /// 代金券列表（会员持有）
  static const String cashCouponList = '/cash-coupon/list';

  // ===== 换新补贴 =====
  /// 可用换新补贴券列表
  static const String availableRenewSubsidy = '/renew-subsidy/available';
  /// 换新补贴券分类列表（换新补贴专用）
  static const String couponClassList = '/coupon-class/list';
  /// 可用换新补贴券（按分类）
  static String availableCouponClass(String classId) => '/renew-subsidy/available?couponClassId=$classId';

  // ===== 仓库 =====
  /// 仓库列表（添加 state=1 过滤禁用仓库）
  static String warehouseList({int? state}) {
    return state != null ? '/warehouse/list-base?state=$state' : '/warehouse/list-base';
  }
  /// 仓库列表（条件查询，state=1 仅返回启用状态）
  static String warehouseListCondition({int? state, int limit = 100, int offset = 0}) {
    return '/warehouse/list-condition?state=${state ?? 1}&limit=$limit&offset=$offset';
  }

  // ===== 盘库 =====
  /// 盘库列表（添加分页参数）
  static String stocktakingList({int page = 1, int pageSize = 20}) =>
      '/stock-taking/list?page=$page&pageSize=$pageSize';

  // ===== 采购 =====
  /// 采购列表
  static const String purchaseList = '/purchase/list';
  /// 采购单详情
  static String purchaseDetail(int id) => '/purchase/detail?id=$id';
  /// 采购入库
  static const String purchaseIntoWarehouse = '/purchase/into-warehouse';
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
  /// 创建调拨单
  static const String transferAdd = '/transfer/add';
  /// 调拨单详情
  static String transferDetail(int id) => '/transfer/detail?id=$id';
  /// 确认发货
  static const String transferShipping = '/transfer-lock/shipping';
  /// 确认入库
  static const String transferReceived = '/transfer-lock/received';

  // ===== 通用 =====
  /// 用户信息（登录后获取）
  static const String userSelf = '/members/self';
  /// 登出
  static const String logout = '/auth/logout';

  // ===== 序列号查询 =====
  /// 序列号查询（模糊搜索）
  static const String serialSearch = '/serial/search';
  /// 序列号查询（全匹配）
  static const String serialSearchFullMatch = '/serial/search/full-match';
  /// 条码查商品（遗留接口）
  static String productBarcode(String code) => '/product/barcode/$code';

  // ===== 商品 =====
  /// 商品列表（支持 spuId 等条件查询，返回 hasSerial 等完整字段）
  static String productListBySpuId({int? spuId}) => spuId != null ? '/product/list?spuId=$spuId' : '/product/list';

  // ===== 商品价格 =====
  /// 商品价格列表（批量获取价格）
  static const String productPriceList = '/product-price/list';

  // ===== 回收单（以旧换新） =====
  /// 可绑定回收单列表
  static const String allowBindAhsOrderList = '/ahs/allow-bind';
  /// 校验回收单是否可关联
  static String checkAhsOrder(int ahsOrderId) => '/ahs/check/$ahsOrderId';

  // ===== 积分兑换 =====
  /// 积分兑换转订单（POST）
  static const String pointsRedeemOrderToMallOrder = '/points-redeem/order/to-mall-order';
}

/// 辅助方法：URL 参数编码
String _encodeParams(Map<String, dynamic> params) {
  return params.entries
      .where((e) => e.value != null)
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
      .join('&');
}