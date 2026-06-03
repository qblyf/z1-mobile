import 'package:equatable/equatable.dart';

import '../../../../types/api/mall-order-types.dart';
import 'mall_order_model.dart';

/// 商城订单行项（扁平化的 `MallOrderInfo` 联合类型）
///
/// 协议层 `MallOrderInfo` 是抽象类，有三个子类型（商品 / 服务 / 非标）。详情页
/// MVP 阶段不做差异化展示，统一扁平为一行：「名称 x数量  ¥单价 → ¥折后」。
///
/// 各子类型保留差异化字段（skuID/serviceID/itemID）以便后续接入差异化 UI 时
/// 不必重新解析。
class MallOrderLineItem extends Equatable {
  /// 行项类型：product / service / nonStandard
  final MallOrderLineItemKind kind;

  /// 业务 ID（对应 skuID / serviceID / itemID 中的一个，按 kind 解释）
  final int referenceId;

  /// 展示名称（后端 join 给出，缺失则按类型展示「商品」「服务」「定制」占位）
  final String name;

  /// 单价（分）
  final int unitPrice;

  /// 折后金额（分）
  final int discountPrice;

  /// 数量
  final int qty;

  const MallOrderLineItem({
    required this.kind,
    required this.referenceId,
    required this.name,
    required this.unitPrice,
    required this.discountPrice,
    required this.qty,
  });

  /// 容错解析：根据子类型字段判定 kind，不直接调协议层 `MallOrderInfo.fromJson`
  /// 因协议层对未知 schema 会抛 ArgumentError，而 list/detail 接口可能新增子类型。
  factory MallOrderLineItem.fromJson(Map<String, dynamic> json) {
    final MallOrderLineItemKind kind;
    final int referenceId;
    final int unitPrice;
    final String name;

    if (json.containsKey('skuID')) {
      kind = MallOrderLineItemKind.product;
      referenceId = (json['skuID'] as int?) ?? 0;
      unitPrice = (json['skuPrice'] as int?) ?? 0;
      name = (json['skuName'] as String?) ?? '商品';
    } else if (json.containsKey('serviceID')) {
      kind = MallOrderLineItemKind.service;
      referenceId = (json['serviceID'] as int?) ?? 0;
      unitPrice = (json['servicePrice'] as int?) ?? 0;
      name = (json['serviceName'] as String?) ?? '服务';
    } else if (json.containsKey('itemID')) {
      kind = MallOrderLineItemKind.nonStandard;
      referenceId = (json['itemID'] as int?) ?? 0;
      unitPrice = (json['itemPrice'] as int?) ?? 0;
      name = (json['itemName'] as String?) ?? '定制商品';
    } else {
      kind = MallOrderLineItemKind.unknown;
      referenceId = 0;
      unitPrice = 0;
      name = '未知行项';
    }

    return MallOrderLineItem(
      kind: kind,
      referenceId: referenceId,
      name: name,
      unitPrice: unitPrice,
      discountPrice: (json['discountPrice'] as int?) ?? unitPrice,
      qty: (json['qty'] as int?) ?? 1,
    );
  }

  double get unitPriceYuan => unitPrice / 100;
  double get discountPriceYuan => discountPrice / 100;

  @override
  List<Object?> get props => [kind, referenceId, qty, discountPrice];
}

/// 行项子类型分类（与协议层 `MallOrderInfo` 子类一一对应 + 兜底 unknown）
enum MallOrderLineItemKind {
  product('商品'),
  service('服务'),
  nonStandard('定制'),
  unknown('未知');

  final String label;
  const MallOrderLineItemKind(this.label);
}

/// 收货人信息（自提订单 postInfo 为 null）
class MallOrderShippingInfo extends Equatable {
  final String name;
  final String mobilePhone;
  final String address;

  const MallOrderShippingInfo({
    required this.name,
    required this.mobilePhone,
    required this.address,
  });

  factory MallOrderShippingInfo.fromJson(Map<String, dynamic> json) {
    return MallOrderShippingInfo(
      name: json['name'] as String? ?? '',
      mobilePhone: json['mobilePhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  /// 手机号脱敏：139****6666
  String get maskedMobilePhone {
    if (mobilePhone.length < 11) return mobilePhone;
    return '${mobilePhone.substring(0, 3)}****${mobilePhone.substring(7)}';
  }

  @override
  List<Object?> get props => [name, mobilePhone, address];
}

/// 商城订单详情展示模型
///
/// 在 `MallOrderModel` 基础上扩展详情场景需要的字段：收货人、行项明细、
/// 折扣信息、积分抵扣等。物流追踪、退款流程、代金券明细等 MVP 之外的字段
/// 暂不进入此模型。
///
/// ## 真实响应样本（2026-05-29 抓取，环境 z1-fun.zsqk.com.cn/deno）
///
/// 接口：`GET /mall-order/detail?mallOrderNumbers=<NUM>`
/// 顶层包装：`{ "code": 10000, "res": [ MallOrder ] }` —— **res 是数组**，按
/// 请求顺序对应；单查也是数组（取 `[0]`）。
///
/// 订单不存在：`{code:10000, res:[]}`（HTTP 200，不抛错误）。datasource 层
/// 检测到空数组转 `Failure("订单不存在")`。
///
/// 抽样 4 种状态（status=7/22/31/42）单条响应：
/// ```json
/// {
///   "mallID": 43702, "number": "202505121744175017",
///   "customerIdent": "744862572", "departmentID": 35, "status": 7,
///   "transport": "store", "postInfo": null, "postAmount": null,
///   "orderAmount": 13800, "discountAmount": 13800,
///   "costAmount": 1302, "payAmount": 13800,
///   "coinsUsed": 0, "coinsUsedAmount": 0,
///   "info": [{"qty":1,"skuID":589,"services":[],"skuPrice":13800,
///             "discountInfo":[],"discountPrice":13800}],
///   "cashCoupons": [], "coupons": [],
///   "paymentsID": [48959], "paymentAt": 1747043069, "createdAt": 1747043057,
///   "remarks": "", "images": [], "labelIDs": [100, 67], "salesChannel": 2,
///   "assistantIdent": {
///     "masher": null, "cashier": null, "engineer": null, "operator": null,
///     "deliverer": null, "guideData": null, "inspector": null
///   },
///   "isDisplay": true,
///   "postCouponID": null, "postageID": null,
///   "shoppingGuide": null, "deliveryInfo": null, "sellerIdent": "100000000",
///   "recycleOrderNumber": null, "jointOrderNumber": null,
///   "mainOrderNumber": null, "discountApprovalZID": null,
///   "sharer": "744862572"
/// }
/// ```
///
/// 关键差异（详情 vs 协议层 / 原先假设）：
/// - **`info[]` 仍缺 `skuName`/`serviceName`/`itemName`** —— 同 list，需 fallback。
/// - **`assistantIdent` 是 object**（实测含 7 个 null 角色字段）—— 协议层已正确
///   建模为 `AssistantIdent`（9 字段：masher/cashier/engineer/operator/deliverer/
///   guideData/inspector + qwCustomerService/recruitIdent，后两者响应不返回但
///   `fromJson as UserIdent?` 返回 null 不崩）。展示层 MVP 未用。
/// - **所有 100% 抽样 `transport=store`**（自提）—— 测试环境无 `post` 邮寄
///   样本；`postInfo`/`postAmount`/`postageID`/`postCouponID` 全 null。
/// - **`recycleOrderNumber`/`jointOrderNumber`/`mainOrderNumber`/
///   `discountApprovalZID`/`shoppingGuide`/`deliveryInfo`** 抽样 100% 为 null，
///   协议层 required 需放宽为可空。
/// - 唯一在 `info[]` 中观察到的子类型是 `skuID`（商品），未见 `serviceID`/
///   `itemID`，但 `MallOrderLineItem.fromJson` 已留兜底。
class MallOrderDetailModel extends Equatable {
  /// 复用列表卡片同一份窄视图（号/状态/金额/会员/创建时间等）
  final MallOrderModel summary;

  /// 商品 / 服务 / 非标行项明细
  final List<MallOrderLineItem> lineItems;

  /// 收货人信息（自提订单为 null）
  final MallOrderShippingInfo? shippingInfo;

  /// 折扣总额（分）
  final int discountAmount;

  /// 积分抵现金额（分，null 表示未使用积分）
  final int? coinsUsedAmount;

  /// 邮费（分，null 表示无邮费）
  final int? postAmount;

  /// 备注
  final String? remarks;

  /// 支付时间（Unix 秒，null 表示未支付）
  final int? paymentAt;

  const MallOrderDetailModel({
    required this.summary,
    required this.lineItems,
    required this.shippingInfo,
    required this.discountAmount,
    required this.coinsUsedAmount,
    required this.postAmount,
    required this.remarks,
    required this.paymentAt,
  });

  /// 容错解析：详情接口与列表共享 schema，差异是字段更全。
  factory MallOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final infoList = (json['info'] as List<dynamic>?) ?? const [];
    final postInfo = json['postInfo'];

    return MallOrderDetailModel(
      summary: MallOrderModel.fromJson(json),
      lineItems: infoList
          .map((e) => MallOrderLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingInfo: postInfo is Map<String, dynamic>
          ? MallOrderShippingInfo.fromJson(postInfo)
          : null,
      discountAmount: (json['discountAmount'] as int?) ?? 0,
      coinsUsedAmount: json['coinsUsedAmount'] as int?,
      postAmount: json['postAmount'] as int?,
      remarks: json['remarks'] as String?,
      paymentAt: json['paymentAt'] as int?,
    );
  }

  double get discountAmountYuan => discountAmount / 100;
  double? get coinsUsedAmountYuan =>
      coinsUsedAmount != null ? coinsUsedAmount! / 100 : null;
  double? get postAmountYuan =>
      postAmount != null ? postAmount! / 100 : null;

  /// 自提订单（无邮寄信息）
  bool get isSelfPickup => summary.transport == MallOrderTransportType.store;

  @override
  List<Object?> get props => [summary, lineItems, shippingInfo, discountAmount];
}
