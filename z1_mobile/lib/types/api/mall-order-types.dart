// ============================================================
// 商城订单类型
// 从 z1-mid SDK mall-order-types.ts 翻译而来
// 源文件：/Users/fan/www/AI/z1/z1-mid/src/types/mall-order-types.ts
// ============================================================

import 'package:z1_mobile/types/api/order-types.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

// ============================================================
// ID 别名（外部依赖，部分类型 SDK 中尚未在 Dart 端定义，
// 暂用 int/String 兜底，待后续生成对应类型文件后再 import）
// ============================================================

/// 商城订单 ID（已废弃，建议使用销售订单编号 number）
@Deprecated('避免使用商城订单 ID, 要使用销售订单编号')
typedef MallOrderID = int;

/// 销售订单编号
typedef MallOrderNumber = String;

/// 优惠券 ID（待生成 coupon-types.dart）
typedef CouponID = int;

/// 优惠券类 ID（待生成 coupon-class-types.dart）
typedef CouponClassID = int;

/// 非标商品 ID（待生成 nonstandard-types.dart）
typedef ItemID = int;

/// 标签 ID（待生成 label-types.dart）
typedef LabelID = int;

// ============================================================
// 枚举类型
// ============================================================

/// 销售订单折扣信息类型
enum DiscountInfoType {
  changePrice('changePrice'),     // 改价
  coupon('coupon'),               // 优惠券
  gift('gift'),                   // 赠品
  replacementSubsidy('replacementSubsidy'); // 换新补贴

  final String value;
  const DiscountInfoType(this.value);

  static DiscountInfoType fromValue(String value) {
    return DiscountInfoType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DiscountInfoType.changePrice,
    );
  }
}

/// 商城订单状态
enum MallOrderStatus {
  pendingPayment(1),        // 待支付
  partiallyPaid(21),        // 部分支付
  paid(22),                 // 已支付
  paidIncomplete(23),       // 已支付未完成（锁货流程未完成）
  unpaidCancelled(31),      // 未支付撤销
  paidCancelled(32),        // 已支付撤销
  refundedBeforeShip(41),   // 未发货已退款
  refundedAfterShip(42),    // 已发货已退款
  shipped(6),               // 已出库
  delivered(61),            // 已送达
  completed(7),             // 已完成
  reviewed(8);              // 已评价

  final int value;
  const MallOrderStatus(this.value);

  static MallOrderStatus fromValue(int value) {
    return MallOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MallOrderStatus.pendingPayment,
    );
  }

  /// 中文标签
  String get label {
    switch (this) {
      case MallOrderStatus.pendingPayment: return '待支付';
      case MallOrderStatus.partiallyPaid: return '部分支付';
      case MallOrderStatus.paid: return '已支付';
      case MallOrderStatus.paidIncomplete: return '待确认';
      case MallOrderStatus.unpaidCancelled: return '已取消';
      case MallOrderStatus.paidCancelled: return '已取消';
      case MallOrderStatus.refundedBeforeShip: return '已退款';
      case MallOrderStatus.refundedAfterShip: return '已退款';
      case MallOrderStatus.shipped: return '已发货';
      case MallOrderStatus.delivered: return '已送达';
      case MallOrderStatus.completed: return '已完成';
      case MallOrderStatus.reviewed: return '已评价';
    }
  }
}

/// 运输方式
enum MallOrderTransportType {
  post('post'),    // 邮寄
  store('store');  // 自提

  final String value;
  const MallOrderTransportType(this.value);

  static MallOrderTransportType fromValue(String value) {
    return MallOrderTransportType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MallOrderTransportType.post,
    );
  }
}

/// 商城订单分组字段
enum MallOrderField {
  departmentID('departmentID'), // 部门
  customerIdent('customerIdent'), // 顾客
  status('status'),               // 订单状态
  sellerIdent('sellerIdent');     // 营业员

  final String value;
  const MallOrderField(this.value);
}

/// 协销人员类型
enum AssistantIdentType {
  cashier('cashier'),                       // 收银员
  inspector('inspector'),                   // 验机员
  masher('masher'),                         // 贴膜员
  guideData('guideData'),                   // 导资料
  engineer('engineer'),                     // 工程师
  operator('operator'),                     // 操作员
  deliverer('deliverer'),                   // 配送人
  qwCustomerService('qwCustomerService'),  // 企微客服
  recruitIdent('recruitIdent');            // 拉新人

  final String value;
  const AssistantIdentType(this.value);

  static AssistantIdentType fromValue(String value) {
    return AssistantIdentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssistantIdentType.cashier,
    );
  }
}

// ============================================================
// 折扣信息（联合类型）
// SDK 中是 union type，Dart 用基类 + 多个子类，并通过 type 字段区分
// ============================================================

/// 商城订单折扣信息（基类）
abstract class MallOrderDiscountInfo {
  final DiscountInfoType type;
  final RMBFen discount;

  const MallOrderDiscountInfo({
    required this.type,
    required this.discount,
  });

  Map<String, dynamic> toJson();

  /// 根据 type 字段反序列化为对应子类
  factory MallOrderDiscountInfo.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = typeStr == null
        ? DiscountInfoType.changePrice
        : DiscountInfoType.fromValue(typeStr);

    switch (type) {
      case DiscountInfoType.changePrice:
        // 改价：sku 改价 / 服务改价 / 旧版（无 skuID）
        if (json.containsKey('serviceID')) {
          return MallOrderDiscountServiceChangePrice.fromJson(json);
        } else if (json.containsKey('skuID')) {
          return MallOrderDiscountSkuChangePrice.fromJson(json);
        } else {
          return MallOrderDiscountSkuChangePriceOld.fromJson(json);
        }
      case DiscountInfoType.coupon:
        return MallOrderDiscountCoupon.fromJson(json);
      case DiscountInfoType.gift:
        if (json.containsKey('serviceID')) {
          return MallOrderDiscountServiceGift.fromJson(json);
        }
        return MallOrderDiscountSkuGift.fromJson(json);
      case DiscountInfoType.replacementSubsidy:
        return MallOrderDiscountReplacementSubsidy.fromJson(json);
    }
  }
}

/// 折扣-标品改价（旧版，无 skuID，用于兼容旧数据）
@Deprecated('兼容旧数据，处理完后将移除')
class MallOrderDiscountSkuChangePriceOld extends MallOrderDiscountInfo {
  /// 关联改价表
  final int priceChangeID;

  const MallOrderDiscountSkuChangePriceOld({
    required this.priceChangeID,
    required super.discount,
  }) : super(type: DiscountInfoType.changePrice);

  factory MallOrderDiscountSkuChangePriceOld.fromJson(
    Map<String, dynamic> json,
  ) {
    return MallOrderDiscountSkuChangePriceOld(
      priceChangeID: json['priceChangeID'] as int,
      discount: json['discount'] as RMBFen,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'priceChangeID': priceChangeID,
        'discount': discount,
      };
}

/// 折扣-标品/非标改价
class MallOrderDiscountSkuChangePrice extends MallOrderDiscountInfo {
  final int priceChangeID;
  final SkuID skuID;

  const MallOrderDiscountSkuChangePrice({
    required this.priceChangeID,
    required this.skuID,
    required super.discount,
  }) : super(type: DiscountInfoType.changePrice);

  factory MallOrderDiscountSkuChangePrice.fromJson(Map<String, dynamic> json) {
    return MallOrderDiscountSkuChangePrice(
      priceChangeID: json['priceChangeID'] as int,
      skuID: json['skuID'] as SkuID,
      discount: json['discount'] as RMBFen,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'priceChangeID': priceChangeID,
        'skuID': skuID,
        'discount': discount,
      };
}

/// 折扣-服务改价
class MallOrderDiscountServiceChangePrice extends MallOrderDiscountInfo {
  final int priceChangeID;
  final ServiceID serviceID;

  const MallOrderDiscountServiceChangePrice({
    required this.priceChangeID,
    required this.serviceID,
    required super.discount,
  }) : super(type: DiscountInfoType.changePrice);

  factory MallOrderDiscountServiceChangePrice.fromJson(
    Map<String, dynamic> json,
  ) {
    return MallOrderDiscountServiceChangePrice(
      priceChangeID: json['priceChangeID'] as int,
      serviceID: json['serviceID'] as ServiceID,
      discount: json['discount'] as RMBFen,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'priceChangeID': priceChangeID,
        'serviceID': serviceID,
        'discount': discount,
      };
}

/// 折扣-优惠券（仅记录使用金额）
class MallOrderDiscountCoupon extends MallOrderDiscountInfo {
  const MallOrderDiscountCoupon({required super.discount})
      : super(type: DiscountInfoType.coupon);

  factory MallOrderDiscountCoupon.fromJson(Map<String, dynamic> json) {
    return MallOrderDiscountCoupon(discount: json['discount'] as RMBFen);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'discount': discount,
      };
}

/// 折扣-SKU 赠品
class MallOrderDiscountSkuGift extends MallOrderDiscountInfo {
  final SkuID skuID;
  final int qty;

  /// 赠品方案 ID 列表（区分自动/手动赠品）
  final List<int>? giveawayActivityIDs;

  const MallOrderDiscountSkuGift({
    required this.skuID,
    required this.qty,
    required super.discount,
    this.giveawayActivityIDs,
  }) : super(type: DiscountInfoType.gift);

  factory MallOrderDiscountSkuGift.fromJson(Map<String, dynamic> json) {
    return MallOrderDiscountSkuGift(
      skuID: json['skuID'] as SkuID,
      qty: json['qty'] as int,
      discount: json['discount'] as RMBFen,
      giveawayActivityIDs:
          (json['giveawayActivityIDs'] as List<dynamic>?)?.cast<int>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'skuID': skuID,
        'qty': qty,
        'discount': discount,
        if (giveawayActivityIDs != null)
          'giveawayActivityIDs': giveawayActivityIDs,
      };
}

/// 折扣-服务赠品
class MallOrderDiscountServiceGift extends MallOrderDiscountInfo {
  final ServiceID serviceID;
  final int qty;
  final List<int>? giveawayActivityIDs;

  const MallOrderDiscountServiceGift({
    required this.serviceID,
    required this.qty,
    required super.discount,
    this.giveawayActivityIDs,
  }) : super(type: DiscountInfoType.gift);

  factory MallOrderDiscountServiceGift.fromJson(Map<String, dynamic> json) {
    return MallOrderDiscountServiceGift(
      serviceID: json['serviceID'] as ServiceID,
      qty: json['qty'] as int,
      discount: json['discount'] as RMBFen,
      giveawayActivityIDs:
          (json['giveawayActivityIDs'] as List<dynamic>?)?.cast<int>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'serviceID': serviceID,
        'qty': qty,
        'discount': discount,
        if (giveawayActivityIDs != null)
          'giveawayActivityIDs': giveawayActivityIDs,
      };
}

/// 折扣-换新补贴（discount 为优惠券类的 cent）
class MallOrderDiscountReplacementSubsidy extends MallOrderDiscountInfo {
  final CouponClassID couponClassID;

  const MallOrderDiscountReplacementSubsidy({
    required this.couponClassID,
    required super.discount,
  }) : super(type: DiscountInfoType.replacementSubsidy);

  factory MallOrderDiscountReplacementSubsidy.fromJson(
    Map<String, dynamic> json,
  ) {
    return MallOrderDiscountReplacementSubsidy(
      couponClassID: json['couponClassID'] as CouponClassID,
      discount: json['discount'] as RMBFen,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'couponClassID': couponClassID,
        'discount': discount,
      };
}

// ============================================================
// 销售订单服务（兼容旧字段，已废弃）
// ============================================================

/// 销售订单服务
@Deprecated('与 MallOrderServiceInfo 二合一，请优先使用后者')
class MallOrderService {
  final ServiceID serviceID;

  /// 零售价
  final RMBFen servicePrice;

  /// 折扣后金额
  final RMBFen discountPrice;

  const MallOrderService({
    required this.serviceID,
    required this.servicePrice,
    required this.discountPrice,
  });

  factory MallOrderService.fromJson(Map<String, dynamic> json) {
    return MallOrderService(
      serviceID: json['serviceID'] as ServiceID,
      servicePrice: json['servicePrice'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceID': serviceID,
        'servicePrice': servicePrice,
        'discountPrice': discountPrice,
      };
}

/// 代金券信息
class MallOrderCashCouponInfo {
  final CouponID couponID;

  /// 抵用金额
  final RMBFen discount;

  const MallOrderCashCouponInfo({
    required this.couponID,
    required this.discount,
  });

  factory MallOrderCashCouponInfo.fromJson(Map<String, dynamic> json) {
    return MallOrderCashCouponInfo(
      couponID: json['couponID'] as CouponID,
      discount: json['discount'] as RMBFen,
    );
  }

  Map<String, dynamic> toJson() => {
        'couponID': couponID,
        'discount': discount,
      };
}

// ============================================================
// 商城订单信息（联合类型：商品 / 服务 / 非标）
// ============================================================

/// 商城订单信息基类
abstract class MallOrderInfo {
  /// 数量
  final int qty;

  /// 折扣后金额
  final RMBFen discountPrice;

  /// 折扣信息
  final List<MallOrderDiscountInfo>? discountInfo;

  const MallOrderInfo({
    required this.qty,
    required this.discountPrice,
    this.discountInfo,
  });

  Map<String, dynamic> toJson();

  /// 通过字段判断子类型反序列化
  factory MallOrderInfo.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('skuID')) {
      return MallOrderProductInfo.fromJson(json);
    } else if (json.containsKey('serviceID')) {
      return MallOrderServiceInfo.fromJson(json);
    } else if (json.containsKey('itemID')) {
      return MallOrderNonStandardInfo.fromJson(json);
    }
    throw ArgumentError('Unknown MallOrderInfo type: $json');
  }
}

/// 商城订单商品（标品）
class MallOrderProductInfo extends MallOrderInfo {
  final SkuID skuID;

  /// 零售价
  final RMBFen skuPrice;

  /// 服务列表
  final List<MallOrderService>? services;

  /// 改价时是否使用成本价作为折扣价
  final bool? isCostCent;

  const MallOrderProductInfo({
    required this.skuID,
    required super.qty,
    required this.skuPrice,
    required super.discountPrice,
    this.services,
    super.discountInfo,
    this.isCostCent,
  });

  factory MallOrderProductInfo.fromJson(Map<String, dynamic> json) {
    return MallOrderProductInfo(
      skuID: json['skuID'] as SkuID,
      qty: json['qty'] as int,
      skuPrice: json['skuPrice'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => MallOrderService.fromJson(e as Map<String, dynamic>))
          .toList(),
      discountInfo: (json['discountInfo'] as List<dynamic>?)
          ?.map((e) => MallOrderDiscountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCostCent: json['isCostCent'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'skuID': skuID,
        'qty': qty,
        'skuPrice': skuPrice,
        'discountPrice': discountPrice,
        if (services != null)
          'services': services!.map((e) => e.toJson()).toList(),
        if (discountInfo != null)
          'discountInfo': discountInfo!.map((e) => e.toJson()).toList(),
        if (isCostCent != null) 'isCostCent': isCostCent,
      };
}

/// 商城订单服务（销售订单中的服务）
class MallOrderServiceInfo extends MallOrderInfo {
  final ServiceID serviceID;

  /// 零售价
  final RMBFen servicePrice;

  /// 改价时是否使用成本价作为折扣价
  final bool? isCostCent;

  /// 为已售出的标品购买服务
  final GoodsID? goodsID;

  /// 为已售出的非标购买服务
  final ItemID? serviceItemID;

  const MallOrderServiceInfo({
    required this.serviceID,
    required super.qty,
    required this.servicePrice,
    required super.discountPrice,
    super.discountInfo,
    this.isCostCent,
    this.goodsID,
    this.serviceItemID,
  });

  factory MallOrderServiceInfo.fromJson(Map<String, dynamic> json) {
    return MallOrderServiceInfo(
      serviceID: json['serviceID'] as ServiceID,
      qty: json['qty'] as int,
      servicePrice: json['servicePrice'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
      discountInfo: (json['discountInfo'] as List<dynamic>?)
          ?.map((e) => MallOrderDiscountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCostCent: json['isCostCent'] as bool?,
      goodsID: json['goodsID'] as GoodsID?,
      serviceItemID: json['serviceItemID'] as ItemID?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'serviceID': serviceID,
        'qty': qty,
        'servicePrice': servicePrice,
        'discountPrice': discountPrice,
        if (discountInfo != null)
          'discountInfo': discountInfo!.map((e) => e.toJson()).toList(),
        if (isCostCent != null) 'isCostCent': isCostCent,
        if (goodsID != null) 'goodsID': goodsID,
        if (serviceItemID != null) 'serviceItemID': serviceItemID,
      };
}

/// 商城订单非标商品
class MallOrderNonStandardInfo extends MallOrderInfo {
  final ItemID itemID;

  /// 零售价
  final RMBFen itemPrice;

  /// 服务列表
  final List<MallOrderService>? services;

  const MallOrderNonStandardInfo({
    required this.itemID,
    required super.qty, // 永远为 1
    required this.itemPrice,
    required super.discountPrice,
    this.services,
    super.discountInfo,
  });

  factory MallOrderNonStandardInfo.fromJson(Map<String, dynamic> json) {
    return MallOrderNonStandardInfo(
      itemID: json['itemID'] as ItemID,
      qty: json['qty'] as int,
      itemPrice: json['itemPrice'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => MallOrderService.fromJson(e as Map<String, dynamic>))
          .toList(),
      discountInfo: (json['discountInfo'] as List<dynamic>?)
          ?.map((e) => MallOrderDiscountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'itemID': itemID,
        'qty': qty,
        'itemPrice': itemPrice,
        'discountPrice': discountPrice,
        if (services != null)
          'services': services!.map((e) => e.toJson()).toList(),
        if (discountInfo != null)
          'discountInfo': discountInfo!.map((e) => e.toJson()).toList(),
      };
}

// ============================================================
// 邮寄、卡券、配送
// ============================================================

/// 邮寄信息
class MallOrderPostInfo {
  final String name;
  final String mobilePhone;
  final String address;

  const MallOrderPostInfo({
    required this.name,
    required this.mobilePhone,
    required this.address,
  });

  factory MallOrderPostInfo.fromJson(Map<String, dynamic> json) {
    return MallOrderPostInfo(
      name: json['name'] as String,
      mobilePhone: json['mobilePhone'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobilePhone': mobilePhone,
        'address': address,
      };
}

/// 商城订单卡券（代金券/优惠券通用结构）
class MallOrderCoupon {
  final CouponID couponID;
  final RMBFen amount;

  /// 冗余字段（用于记录优惠券使用日志）
  final List<SkuID>? skuIDs;
  final List<ServiceID>? serviceIDs;
  final List<ItemID>? itemIDs;

  const MallOrderCoupon({
    required this.couponID,
    required this.amount,
    this.skuIDs,
    this.serviceIDs,
    this.itemIDs,
  });

  factory MallOrderCoupon.fromJson(Map<String, dynamic> json) {
    return MallOrderCoupon(
      couponID: json['couponID'] as CouponID,
      amount: json['amount'] as RMBFen,
      skuIDs: (json['skuIDs'] as List<dynamic>?)?.cast<SkuID>(),
      serviceIDs: (json['serviceIDs'] as List<dynamic>?)?.cast<ServiceID>(),
      itemIDs: (json['itemIDs'] as List<dynamic>?)?.cast<ItemID>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'couponID': couponID,
        'amount': amount,
        if (skuIDs != null) 'skuIDs': skuIDs,
        if (serviceIDs != null) 'serviceIDs': serviceIDs,
        if (itemIDs != null) 'itemIDs': itemIDs,
      };
}

/// 配送信息
class DeliveryInfo {
  /// 配送员标识符
  final UserIdent customerIdent;

  /// 送达图片
  final List<String>? images;

  /// 配送备注
  final String? remarks;

  const DeliveryInfo({
    required this.customerIdent,
    this.images,
    this.remarks,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      customerIdent: json['customerIdent'] as UserIdent,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'customerIdent': customerIdent,
        if (images != null) 'images': images,
        if (remarks != null) 'remarks': remarks,
      };
}

/// 退绑定服务信息
class BackServiceInfo {
  final ServiceID serviceID;
  final int qty;

  /// 实际退款金额
  final RMBFen discountPrice;

  /// 服务绑定的标品
  final List<GoodsID>? goodsIDs;

  /// 服务绑定的非标
  final List<ItemID>? itemIDs;

  const BackServiceInfo({
    required this.serviceID,
    required this.qty,
    required this.discountPrice,
    this.goodsIDs,
    this.itemIDs,
  });

  factory BackServiceInfo.fromJson(Map<String, dynamic> json) {
    return BackServiceInfo(
      serviceID: json['serviceID'] as ServiceID,
      qty: json['qty'] as int,
      discountPrice: json['discountPrice'] as RMBFen,
      goodsIDs: (json['goodsIDs'] as List<dynamic>?)?.cast<GoodsID>(),
      itemIDs: (json['itemIDs'] as List<dynamic>?)?.cast<ItemID>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceID': serviceID,
        'qty': qty,
        'discountPrice': discountPrice,
        if (goodsIDs != null) 'goodsIDs': goodsIDs,
        if (itemIDs != null) 'itemIDs': itemIDs,
      };
}

// ============================================================
// 协销人员（嵌套结构）
// ============================================================

/// 协销人员（每个角色对应一个 UserIdent）
class AssistantIdent {
  final UserIdent? cashier;
  final UserIdent? inspector;
  final UserIdent? masher;
  final UserIdent? guideData;
  final UserIdent? engineer;
  final UserIdent? operator;
  final UserIdent? deliverer;
  final UserIdent? qwCustomerService;
  final UserIdent? recruitIdent;

  const AssistantIdent({
    this.cashier,
    this.inspector,
    this.masher,
    this.guideData,
    this.engineer,
    this.operator,
    this.deliverer,
    this.qwCustomerService,
    this.recruitIdent,
  });

  factory AssistantIdent.fromJson(Map<String, dynamic> json) {
    return AssistantIdent(
      cashier: json['cashier'] as UserIdent?,
      inspector: json['inspector'] as UserIdent?,
      masher: json['masher'] as UserIdent?,
      guideData: json['guideData'] as UserIdent?,
      engineer: json['engineer'] as UserIdent?,
      operator: json['operator'] as UserIdent?,
      deliverer: json['deliverer'] as UserIdent?,
      qwCustomerService: json['qwCustomerService'] as UserIdent?,
      recruitIdent: json['recruitIdent'] as UserIdent?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (cashier != null) 'cashier': cashier,
        if (inspector != null) 'inspector': inspector,
        if (masher != null) 'masher': masher,
        if (guideData != null) 'guideData': guideData,
        if (engineer != null) 'engineer': engineer,
        if (operator != null) 'operator': operator,
        if (deliverer != null) 'deliverer': deliverer,
        if (qwCustomerService != null) 'qwCustomerService': qwCustomerService,
        if (recruitIdent != null) 'recruitIdent': recruitIdent,
      };
}

// ============================================================
// 商城订单主类
// ============================================================

/// 商城订单（销售订单）
class MallOrder {
  /// 商城订单 ID（已废弃，建议使用 number）
  @Deprecated('避免使用商城订单 ID, 要使用销售订单编号 number')
  final MallOrderID mallID;

  /// 销售订单编号
  final MallOrderNumber number;

  /// 顾客标识符
  final UserIdent customerIdent;

  /// 销售部门 ID
  final DepartmentID departmentID;

  /// 商品 / 服务 / 非标 信息
  final List<MallOrderInfo> info;

  /// 订单状态
  final MallOrderStatus status;

  /// 订单原始应付金额
  final RMBFen orderAmount;

  /// 订单折扣后金额
  final RMBFen discountAmount;

  /// 成本金额
  final RMBFen costAmount;

  /// 使用积分（null 表示未使用）
  final int? coinsUsed;

  /// 积分抵现金额（null 表示未使用积分）
  final RMBFen? coinsUsedAmount;

  /// 邮费（null 表示无邮费）
  final RMBFen? postAmount;

  /// 实付金额（不含积分抵扣及代金券）
  final RMBFen payAmount;

  /// 运输方式
  final MallOrderTransportType transport;

  /// 邮寄信息
  final MallOrderPostInfo? postInfo;

  /// 代金券信息
  final List<MallOrderCoupon>? cashCoupons;

  /// 优惠券信息
  final List<MallOrderCoupon>? coupons;

  /// 运费券 ID
  final int? postCouponID;

  /// 支付信息 ID 列表
  final List<int>? paymentsID;

  /// 邮费规则 ID
  final int? postageID;

  /// 支付时间（Unix 时间戳）
  final UnixTimestamp? paymentAt;

  final UnixTimestamp createdAt;
  final UserIdent createdBy;
  final UnixTimestamp updatedAt;
  final UserIdent updatedBy;

  /// 备注
  final String? remarks;

  /// 附件（上限 5 张）
  final List<String>? images;

  /// 专属导购
  final UserIdent? shoppingGuide;

  /// 营业员
  final UserIdent? sellerIdent;

  /// 协销
  final AssistantIdent? assistantIdent;

  /// 回收单号
  final String? recycleOrderNumber;

  /// 分享人
  final UserIdent? sharer;

  /// 订单标签
  final List<LabelID>? labelIDs;

  /// 关联的连带商城单号
  final List<String>? jointOrderNumber;

  /// 关联的主营商城单号
  final String? mainOrderNumber;

  /// 销售渠道（NetSalePlatformType，待生成 net-sale-types.dart）
  final String? salesChannel;

  /// 关联折扣审批单据 ID
  final String? discountApprovalZID;

  /// 是否为用户展示
  final bool isDisplay;

  /// 配送信息
  final DeliveryInfo? deliveryInfo;

  const MallOrder({
    required this.mallID,
    required this.number,
    required this.customerIdent,
    required this.departmentID,
    required this.info,
    required this.status,
    required this.orderAmount,
    required this.discountAmount,
    required this.costAmount,
    required this.coinsUsed,
    required this.coinsUsedAmount,
    required this.postAmount,
    required this.payAmount,
    required this.transport,
    required this.postInfo,
    required this.cashCoupons,
    required this.coupons,
    required this.postCouponID,
    required this.paymentsID,
    required this.postageID,
    required this.paymentAt,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.remarks,
    required this.images,
    required this.shoppingGuide,
    required this.sellerIdent,
    required this.assistantIdent,
    required this.recycleOrderNumber,
    required this.sharer,
    required this.labelIDs,
    required this.jointOrderNumber,
    required this.mainOrderNumber,
    required this.salesChannel,
    this.discountApprovalZID,
    required this.isDisplay,
    required this.deliveryInfo,
  });

  factory MallOrder.fromJson(Map<String, dynamic> json) {
    return MallOrder(
      mallID: json['mallID'] as MallOrderID,
      number: json['number'] as MallOrderNumber,
      customerIdent: json['customerIdent'] as UserIdent,
      departmentID: json['departmentID'] as DepartmentID,
      info: (json['info'] as List<dynamic>)
          .map((e) => MallOrderInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: MallOrderStatus.fromValue(json['status'] as int),
      orderAmount: json['orderAmount'] as RMBFen,
      discountAmount: json['discountAmount'] as RMBFen,
      costAmount: json['costAmount'] as RMBFen,
      coinsUsed: json['coinsUsed'] as int?,
      coinsUsedAmount: json['coinsUsedAmount'] as RMBFen?,
      postAmount: json['postAmount'] as RMBFen?,
      payAmount: json['payAmount'] as RMBFen,
      transport:
          MallOrderTransportType.fromValue(json['transport'] as String),
      postInfo: json['postInfo'] == null
          ? null
          : MallOrderPostInfo.fromJson(json['postInfo'] as Map<String, dynamic>),
      cashCoupons: (json['cashCoupons'] as List<dynamic>?)
          ?.map((e) => MallOrderCoupon.fromJson(e as Map<String, dynamic>))
          .toList(),
      coupons: (json['coupons'] as List<dynamic>?)
          ?.map((e) => MallOrderCoupon.fromJson(e as Map<String, dynamic>))
          .toList(),
      postCouponID: json['postCouponID'] as int?,
      paymentsID: (json['paymentsID'] as List<dynamic>?)?.cast<int>(),
      postageID: json['postageID'] as int?,
      paymentAt: json['paymentAt'] as UnixTimestamp?,
      createdAt: json['createdAt'] as UnixTimestamp,
      createdBy: json['createdBy'] as UserIdent,
      updatedAt: json['updatedAt'] as UnixTimestamp,
      updatedBy: json['updatedBy'] as UserIdent,
      remarks: json['remarks'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      shoppingGuide: json['shoppingGuide'] as UserIdent?,
      sellerIdent: json['sellerIdent'] as UserIdent?,
      assistantIdent: json['assistantIdent'] == null
          ? null
          : AssistantIdent.fromJson(
              json['assistantIdent'] as Map<String, dynamic>),
      recycleOrderNumber: json['recycleOrderNumber'] as String?,
      sharer: json['sharer'] as UserIdent?,
      labelIDs: (json['labelIDs'] as List<dynamic>?)?.cast<LabelID>(),
      jointOrderNumber:
          (json['jointOrderNumber'] as List<dynamic>?)?.cast<String>(),
      mainOrderNumber: json['mainOrderNumber'] as String?,
      salesChannel: json['salesChannel'] as String?,
      discountApprovalZID: json['discountApprovalZID'] as String?,
      isDisplay: json['isDisplay'] as bool,
      deliveryInfo: json['deliveryInfo'] == null
          ? null
          : DeliveryInfo.fromJson(
              json['deliveryInfo'] as Map<String, dynamic>),
    );
  }
}

// ============================================================
// 商城订单 + 门店订单详情
// 与 order-types.dart 中的 Order/OrderProduct/OrderService 关联
// ============================================================

/// 商城订单与门店订单关联详情
///
/// 注意：`salesNet` 字段对应 SDK 中的 `NetSale` 类型，目前 Dart 端尚未生成
/// 对应类型文件，此处用 `dynamic` 兜底，待 `net-sale-types.dart` 生成后再补全。
class OrderMallOrderDetail {
  /// 商城订单
  final MallOrder mallOrder;

  /// 门店销售订单
  final Order order;

  /// 网销信息（NetSale，待生成 net-sale-types.dart）
  final dynamic salesNet;

  /// 订单商品
  final List<OrderProduct>? orderProduct;

  /// 订单服务（OrderService，待生成 order-service-types.dart）
  final List<dynamic>? orderService;

  const OrderMallOrderDetail({
    required this.mallOrder,
    required this.order,
    required this.salesNet,
    required this.orderProduct,
    required this.orderService,
  });

  factory OrderMallOrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderMallOrderDetail(
      mallOrder:
          MallOrder.fromJson(json['mallOrder'] as Map<String, dynamic>),
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      salesNet: json['salesNet'],
      orderProduct: (json['orderProduct'] as List<dynamic>?)
          ?.map((e) => OrderProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderService: json['orderService'] as List<dynamic>?,
    );
  }
}
