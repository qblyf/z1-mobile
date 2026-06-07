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
  /// params: types(1=卖,2=退,3=换), status, minCreatedAt, maxCreatedAt, page, pageSize
  static String shopSaleList({Map<String, dynamic>? params}) {
    return '/order/shop-sale-list${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 查询零售单数量
  /// params: types, status, minCreatedAt, maxCreatedAt
  static String shopSaleCount([Map<String, dynamic>? params]) {
    return '/order/shop-sale-count${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 零售单详情（订单商品列表）
  static String shopSaleInfo(int orderId) => '/order-product/details-by-order-id?orderID=$orderId';
  /// 零售单详情（按单号查订单基本信息）
  static String shopSaleInfoByNumber(String orderNumber) => '/order/shop-sale-list?number=$orderNumber';

  // ===== 退货退款 =====
  /// 退货退款列表（门店）
  /// params: id, orderNumber, status, page, pageSize
  static String returnRefundList({Map<String, dynamic>? params}) {
    return '/return-refund-application/list${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 退货退款列表（商城）
  /// params: id, mallOrderNumber, status, page, pageSize
  static String returnRefundMallList({Map<String, dynamic>? params}) {
    return '/return-refund-application/mall${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 退货退款数量统计
  static const String returnRefundCount = '/return-refund-application/count';
  /// 创建退货退款
  static const String returnRefundAdd = '/return-refund-application/add';
  /// 审核退货退款
  static const String returnRefundAudit = '/return-refund-application/audit';
  /// 完成退款
  static const String returnRefundComplete = '/return-refund-application/complete';
  /// 驳回退货退款
  static const String returnRefundReject = '/return-refund-application/reject-audit';
  /// 取消退货退款
  static const String returnRefundCancel = '/return-refund-application/cancel';
  /// 顾客同意退货
  static const String returnRefundCustomerAgree = '/return-refund-application/customer/agree';
  /// 顾客添加描述
  static const String returnRefundCustomerAddDescript = '/return-refund-application/customer/add-descript';

  // ===== 预订单 =====
  /// 预订单列表（门店）
  /// params: status(unpaid/paid/completed/apply-refund/refunded/canceled), page, pageSize
  static String preSaleOrderList({Map<String, dynamic>? params}) {
    return '/pre-sale-order/list${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 预订单列表（商城）
  /// params: status, page, pageSize
  static String preSaleOrderMallList({Map<String, dynamic>? params}) {
    return '/pre-sale-order/mall-list${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 预订单数量统计
  static const String preSaleOrderCount = '/pre-sale-order/count';
  /// 预订单详情
  static String preSaleOrderDetail(int id) => '/pre-sale-order/mall-detail?id=$id';
  /// 创建预订单
  static const String preSaleOrderAdd = '/pre-sale-order/add';
  /// 编辑预订单（设置 mallOrderNumber 转正式订单）
  static const String preSaleOrderEdit = '/pre-sale-order/edit';
  /// 支付定金
  static const String preSaleOrderPay = '/pre-sale-order/pay';
  /// 申请退款
  static const String preSaleOrderReturnRefund = '/pre-sale-order/return-refund';
  /// 审核退款
  static const String preSaleOrderAuditRefund = '/pre-sale-order/audit-return-refund';

  // ===== 商城订单 =====
  /// 商城订单列表
  /// params: status, page, pageSize
  static String mallOrderList({Map<String, dynamic>? params}) {
    return '/mall-order/list${params != null && params.isNotEmpty ? '?${_encodeParams(params)}' : ''}';
  }
  /// 商城订单数量
  static const String mallOrderCount = '/mall-order/count';
  /// 创建商城订单（用于预订单转正式订单）
  static const String mallOrderAdd = '/mall-order/add';
  /// 商城订单详情
  static String mallOrderDetail(int id) => '/mall-order/detail?id=$id';
  /// 门店订单详情（通过商城订单号）
  static String mallOrderToOrder(String number) => '/mall-order/order-mall-order-detail?number=$number';
  /// 确认发货
  static const String mallOrderOutWarehouse = '/mall-order/outed-of-warehouse';
  /// 完成订单
  static const String mallOrderFinish = '/mall-order/finish';
  /// 待支付取消
  static const String mallOrderUnpaidCancel = '/mall-order/unpaid-cancel';
  /// 已支付取消（需审核）
  static const String mallOrderPaidCancel = '/mall-order/paid-cancel';

  // ===== 换货 =====
  /// 门店换货
  static const String orderChangeShopSale = '/order-change/add/shop-sale';
  /// 网销换货
  static const String orderChangeNetSale = '/order-change/add/net-sale';
  /// 批发换货
  static const String orderChangeOutSale = '/order-change/add/out-sale';

  // ===== 金额单位说明 =====
  // 所有金额字段单位是分（cent），显示时需除以 100

  // ===== 会员 =====
  /// 手机号搜索会员（GET）
  static const String memberSearchByPhones = '/members/list-phones';
  /// 会员列表（GET）
  static String memberList({String keyword = '', int page = 1, int pageSize = 20}) =>
      '/members/list?keyword=$keyword&page=$page&pageSize=$pageSize';
  /// 会员详情（GET）
  /// 后端路径：/member/specified（单数 member，不是复数 members）
  /// 调用方式：`apiClient.get(memberSpecifiedPath, queryParameters: {'userIdents': id})`
  static const String memberSpecifiedPath = '/member/specified';
  /// 新增会员
  static const String memberAdd = '/members/add';
  /// 积分查询：直接用 GET /members/self 返回的 experience 字段
  /// POST /members/experience 是积分调整接口
  static const String memberExperienceEdit = '/members/experience';
  /// 积分查询（GET，含历史明细）
  /// query: userIdents
  static const String memberCreditscore = '/members/creditscore';
  /// 积分调整（POST）
  /// body: { userIdents, adjustValue, reason }
  static const String memberCreditscoreAdjust = '/members/creditscore/adjust';

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
  static const String spuListByMallCate = '/spu/list';
  /// SKU列表（按SPU ID）
  static const String skuBySpu = '/product/sku-by-spu';

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
  /// 按员工主部门取可用仓库 ID 列表（返回 {code, list:[...]}，需真实 Use-Permissions）
  static String warehouseIdsByMainDept(int deptId) =>
      '/warehouse/get-warehouse-ids-by-main-dept-id?departmentID=$deptId';

  // ===== 权限包 =====
  /// 发放权限包（返回 res.permissionsJWT[自带 Bearer 前缀] + res.data.deptIDs）
  static String permissionPackageGrant(String key) =>
      '/permission-package/grant?key=$key';
  /// 零售开单/查询权限包 key（含 shopSaleAdd / GetWarehouseIDsByMainDeptID）
  static const String permKeyShopSaleApply = 'shopSaleApplyView';

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

  // ===== 审批 =====
  /// 审批列表（GET，支持 status/approvalTypes/platforms 筛选）
  static const String approvalList = '/approval/list';
  /// 审批数量统计（GET）
  static const String approvalCount = '/approval/count';

  // ===== 任务 =====
  /// 任务列表（GET，支持 status/date 筛选）
  static const String taskList = '/task/list';
  /// 日历数据（GET，带 startDate/endDate 参数）
  static const String taskCalendar = '/task/calendar';
  /// 创建任务（POST）
  static const String taskAdd = '/task/add';
  /// 任务详情（GET）
  static String taskDetail(int id) => '/task/$id';
  /// 完成任务（POST）
  static String taskComplete(int id) => '/task/$id/complete';
  /// 删除任务（DELETE）
  static String taskDelete(int id) => '/task/$id/delete';
}

/// 辅助方法：URL 参数编码
String _encodeParams(Map<String, dynamic> params) {
  return params.entries
      .where((e) => e.value != null)
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
      .join('&');
}