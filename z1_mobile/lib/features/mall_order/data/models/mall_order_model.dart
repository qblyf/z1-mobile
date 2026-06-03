import 'package:equatable/equatable.dart';

import '../../../../types/api/mall-order-types.dart';

/// 商城订单列表项展示模型（窄视图）
///
/// 协议层 `MallOrder` 有 38 个字段且包含 `info` / `cashCoupons` / `coupons` 等
/// 联合类型；列表场景只需要 ~10 个字段做展示，本模型只截取这些。详情场景见
/// `MallOrderDetailModel`。
///
/// ⚠️ 不调用 `MallOrder.fromJson`：协议层 `required` 约束严格，而后端 list
/// 响应通常只返回精简字段。本模型直接从原始 `Map` 取值，
/// 缺失字段用合理默认值兜底，避免协议层 `required` 强约束在响应不完整时 cast 崩溃。
///
/// ## 真实响应样本（2026-05-29 抓取，环境 z1-fun.zsqk.com.cn/deno）
///
/// 接口：`GET /mall-order/list?page=1&pageSize=5`
/// 顶层包装：`{ "code": 10000, "res": [ ...items ] }` — ⚠️ 不是 `{list, total}`
///
/// 单条 item（取自首条）：
/// ```json
/// {
///   "mallID": 46346,
///   "number": "202602031807012241",
///   "customerIdent": "235787983",     // ⚠️ string 不是 int!
///   "departmentID": 35,
///   "status": 7,                       // 已完成
///   "transport": "store",              // 100% 都是 store（自提）
///   "orderAmount": 1694600,            // 分
///   "discountAmount": 1684600,
///   "payAmount": 1684500,
///   "postAmount": null,
///   "coinsUsed": 100, "coinsUsedAmount": 100,
///   "postInfo": null,
///   "info": [                          // SKU 行项；本接口未 join skuName
///     {"qty":1,"skuID":16219,"skuPrice":1500000,"discountPrice":1490000,
///      "services":[...],"discountInfo":[{"type":"gift",...},{"type":"coupon",...}]}
///   ],
///   "createdAt": 1770113221, "paymentAt": 1770113232,
///   "remarks": ""
///   // 其它字段（assistantIdent / labelIDs / salesChannel / isDisplay 等）展示层未用
/// }
/// ```
///
/// 关键差异（响应 vs 协议层 / 原先假设）：
/// - **响应没有 join `customerName`** —— 列表卡片需要在 BLoC 层异步补查会员表。
/// - **响应没有 `skuName`** —— `firstItemSummary` 走 `'商品 x{qty}'` fallback。
/// - **`customerIdent` 是 string** —— 已修正模型字段类型（曾经误写为 int）。
/// - 多个 `null` 字段（`postAmount` / `postInfo` / `shoppingGuide` / `postageID` 等）
///   —— 当前 `?? 0` / `?? ''` 兜底都被吃到，必需保留。
/// - 抽样 100 条状态分布：`status=7` 已完成 ~55 条 / `status=31` 未支付撤销 ~44 条 /
///   `status=42` 已发货已退款 1 条 —— 6 tab 压缩映射验证可用。
///
/// 请求参数差异（详见 `mall_order_remote_datasource.dart`）：
/// - **分页用 `offset + limit`**，`page + pageSize` 被忽略
/// - **状态筛选用 `status=21,22,23` 逗号串**，`status[]=...` 数组被忽略
/// - 错误响应：HTTP 403 + `{ code: 90000, message: "..." }`
class MallOrderModel extends Equatable {
  /// 销售订单编号（业务主键，详情/路由都用这个）
  final String number;

  /// 已废弃的 mallID（部分 detail 接口仍按 int id 查询，过渡期保留）
  final int mallID;

  /// 协议层状态枚举（12 值），用于状态徽章精细展示
  final MallOrderStatus status;

  /// 顾客标识符（用于异步查询会员姓名）
  ///
  /// ⚠️ 后端响应中为 string（如 `"235787983"`），不是 int。
  /// 协议层若标的是 int 需要在两层之间显式做差异声明，这里以响应为准。
  final String customerIdent;

  /// 会员姓名（若 list 响应已 join，则直接取；否则置空，由调用方按需补查）
  final String customerName;

  /// 商品摘要（如 "足金手镯 x1"）；若后端没返 summary，列表卡片 fallback 显示 itemCount
  final String firstItemSummary;

  /// 行项总数
  final int itemCount;

  /// 订单原始金额（分）
  final int orderAmount;

  /// 实付金额（分，不含积分抵扣 / 代金券）
  final int payAmount;

  /// 创建时间（Unix 秒）
  final int createdAt;

  /// 运输方式（自提订单无 postInfo）
  final MallOrderTransportType transport;

  const MallOrderModel({
    required this.number,
    required this.mallID,
    required this.status,
    required this.customerIdent,
    required this.customerName,
    required this.firstItemSummary,
    required this.itemCount,
    required this.orderAmount,
    required this.payAmount,
    required this.createdAt,
    required this.transport,
  });

  /// 容错解析：直接从原始 Map 取字段，缺失则兜底
  factory MallOrderModel.fromJson(Map<String, dynamic> json) {
    final infoList = (json['info'] as List<dynamic>?) ?? const [];
    final summary = _summarizeFirstItem(infoList);

    return MallOrderModel(
      number: json['number'] as String? ?? '',
      mallID: (json['mallID'] as int?) ?? 0,
      status: MallOrderStatus.fromValue((json['status'] as int?) ?? 1),
      customerIdent: json['customerIdent']?.toString() ?? '',
      // 后端 list 接口若 join 了会员表，直接取；否则空字符串，调用方按需补查
      customerName: json['customerName'] as String? ?? '',
      firstItemSummary: summary,
      itemCount: infoList.length,
      orderAmount: (json['orderAmount'] as int?) ?? 0,
      payAmount: (json['payAmount'] as int?) ?? 0,
      createdAt: (json['createdAt'] as int?) ?? 0,
      transport: _parseTransport(json['transport']),
    );
  }

  /// 展示层 6 tab 中的归类，详情徽章可直接复用
  MallOrderDisplayStatus get displayStatus =>
      MallOrderDisplayStatus.fromMallOrderStatus(status);

  double get orderAmountYuan => orderAmount / 100;
  double get payAmountYuan => payAmount / 100;

  /// 仅展示数量摘要，避免依赖协议层 SKU 命名（list 接口未必返回 skuName）
  static String _summarizeFirstItem(List<dynamic> infoList) {
    if (infoList.isEmpty) return '';
    final first = infoList.first as Map<String, dynamic>;
    final qty = (first['qty'] as int?) ?? 1;
    // 后端若 join 了 name 字段任一，优先展示
    for (final key in const ['skuName', 'serviceName', 'itemName']) {
      final name = first[key] as String?;
      if (name != null && name.isNotEmpty) return '$name x$qty';
    }
    // fallback：按 ID 字段判别子类型
    for (final entry in const [('skuID', '商品'), ('serviceID', '服务'), ('itemID', '定制')]) {
      if (first.containsKey(entry.$1)) return '${entry.$2} x$qty';
    }
    return 'x$qty';
  }

  static MallOrderTransportType _parseTransport(dynamic raw) {
    if (raw is String) return MallOrderTransportType.fromValue(raw);
    return MallOrderTransportType.post;
  }

  @override
  List<Object?> get props => [number, mallID, status, createdAt, payAmount];
}

/// 展示层订单状态分组（PRD 6 tab 模型）
///
/// 协议层 12 个 `MallOrderStatus` 值在 UI 上压缩成 6 个 tab：
///
/// | 展示层 tab        | 协议层 status (int) | 含义               |
/// |-------------------|---------------------|--------------------|
/// | all               | -                   | 不过滤             |
/// | pendingPay        | 1                   | 待支付             |
/// | paid              | 21 / 22 / 23        | 部分支付 / 已支付 / 已支付未完成 |
/// | shipped           | 6 / 61              | 已出库 / 已送达    |
/// | completed         | 7 / 8               | 已完成 / 已评价（评价 8 归入完成 tab） |
/// | refunded          | 31 / 32 / 41 / 42   | 未支付撤销 / 已支付撤销 / 未发货已退款 / 已发货已退款 |
///
/// 协议层 enum 见 `lib/types/api/mall-order-types.dart` 的 `MallOrderStatus`。
/// 详情徽章直接显示协议层 enum 的中文 label（已涵盖 12 个状态），本枚举仅用于
/// 列表 tab 高亮和接口请求参数 `status[]` 转换。
enum MallOrderDisplayStatus {
  all('全部'),
  pendingPay('待支付'),
  paid('已支付'),
  shipped('已发货'),
  completed('已完成'),
  refunded('已退款');

  final String label;
  const MallOrderDisplayStatus(this.label);

  /// 唯一真相：展示层 tab → 协议层 status 集合。
  /// `apiStatusValues` 与 `fromMallOrderStatus` 都从这张表派生，避免双 switch 脱节。
  static const Map<MallOrderDisplayStatus, List<MallOrderStatus>> _tabToStatuses = {
    MallOrderDisplayStatus.all: [],
    MallOrderDisplayStatus.pendingPay: [MallOrderStatus.pendingPayment],
    MallOrderDisplayStatus.paid: [
      MallOrderStatus.partiallyPaid,
      MallOrderStatus.paid,
      MallOrderStatus.paidIncomplete,
    ],
    MallOrderDisplayStatus.shipped: [
      MallOrderStatus.shipped,
      MallOrderStatus.delivered,
    ],
    MallOrderDisplayStatus.completed: [
      MallOrderStatus.completed,
      MallOrderStatus.reviewed,
    ],
    MallOrderDisplayStatus.refunded: [
      MallOrderStatus.unpaidCancelled,
      MallOrderStatus.paidCancelled,
      MallOrderStatus.refundedBeforeShip,
      MallOrderStatus.refundedAfterShip,
    ],
  };

  /// 该 tab 对应的协议层 status int 值集合（list 接口 `status` 参数）
  /// `all` 返回空列表表示不传该参数
  List<int> get apiStatusValues =>
      _tabToStatuses[this]!.map((s) => s.value).toList(growable: false);

  /// 协议层 enum → 展示层 tab 的归类（详情徽章亦可用）
  static MallOrderDisplayStatus fromMallOrderStatus(MallOrderStatus status) {
    for (final entry in _tabToStatuses.entries) {
      if (entry.value.contains(status)) return entry.key;
    }
    // 理论上 _tabToStatuses 已穷举 12 个 status；防御性兜底
    return MallOrderDisplayStatus.all;
  }
}
