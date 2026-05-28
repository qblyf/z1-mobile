// ============================================================
// 订单相关类型
// 从 z1-mid SDK order-types.ts 翻译而来
// ============================================================

import 'package:z1_mobile/types/common.dart';

// re-export common types (OrderID is already in common.dart)
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 是否赠品
// ============================================================

enum OrderOfIsGift {
  no(0),
  yes(1);

  final int value;
  const OrderOfIsGift(this.value);

  static OrderOfIsGift fromValue(int value) {
    return OrderOfIsGift.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderOfIsGift.no,
    );
  }
}

// ============================================================
// 新增订单时区分类型
// ============================================================

enum AddOrderInfoType {
  addProduct(1),  // 订单标准商品
  addService(2),  // 订单服务
  addItem(3);     // 订单非标商品

  final int value;
  const AddOrderInfoType(this.value);

  static AddOrderInfoType fromValue(int value) {
    return AddOrderInfoType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AddOrderInfoType.addProduct,
    );
  }
}

// ============================================================
// 订单状态
// ============================================================

enum OrderStatus {
  shippedPaid(1),      // 已发货已付款
  shippedUnpaid(2),    // 已发货未付款
  unshippedUnpaid(3), // 未发货未付款
  unshippedPaid(4),   // 未发货已付款
  cancelled(5);       // 取消

  final int value;
  const OrderStatus(this.value);

  static OrderStatus fromValue(int value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.unshippedUnpaid,
    );
  }
}

// ============================================================
// 通用订单商品
// ============================================================

class CommonOrderProduct {
  final SkuID productID;
  final RMBFen price;
  final RMBFen discountPrice;

  CommonOrderProduct({
    required this.productID,
    required this.price,
    required this.discountPrice,
  });

  factory CommonOrderProduct.fromJson(Map<String, dynamic> json) {
    return CommonOrderProduct(
      productID: json['productID'] as SkuID,
      price: json['price'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'price': price,
      'discountPrice': discountPrice,
    };
  }
}

// ============================================================
// 非强制序列号订单商品
// ============================================================

class OrderProductWithoutSN extends CommonOrderProduct {
  final int quantity;
  final bool? isGift;

  OrderProductWithoutSN({
    required super.productID,
    required super.price,
    required super.discountPrice,
    required this.quantity,
    this.isGift,
  });

  factory OrderProductWithoutSN.fromJson(Map<String, dynamic> json) {
    return OrderProductWithoutSN(
      productID: json['productID'] as SkuID,
      price: json['price'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
      quantity: json['quantity'] as int,
      isGift: json['isGift'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'quantity': quantity,
      'isGift': isGift,
    };
  }
}

// ============================================================
// 强制序列号订单商品
// ============================================================

class OrderGoods extends CommonOrderProduct {
  final int goodsID;  // NumberID

  OrderGoods({
    required super.productID,
    required super.price,
    required super.discountPrice,
    required this.goodsID,
  });

  factory OrderGoods.fromJson(Map<String, dynamic> json) {
    return OrderGoods(
      productID: json['productID'] as SkuID,
      price: json['price'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
      goodsID: json['goodsID'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'goodsID': goodsID,
    };
  }
}

// ============================================================
// Z1 订单服务
// ============================================================

class OrderZ1ReqService {
  final ServiceID serviceID;
  final RMBFen price;
  final RMBFen discountPrice;
  final int? goodsID;  // GoodsID
  final int? couponID;

  OrderZ1ReqService({
    required this.serviceID,
    required this.price,
    required this.discountPrice,
    this.goodsID,
    this.couponID,
  });

  factory OrderZ1ReqService.fromJson(Map<String, dynamic> json) {
    return OrderZ1ReqService(
      serviceID: json['serviceID'] as ServiceID,
      price: json['price'] as RMBFen,
      discountPrice: json['discountPrice'] as RMBFen,
      goodsID: json['goodsID'] as int?,
      couponID: json['couponID'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceID': serviceID,
      'price': price,
      'discountPrice': discountPrice,
      'goodsID': goodsID,
      'couponID': couponID,
    };
  }
}

// ============================================================
// 抵扣金额
// ============================================================

class Deduction {
  final RMBFen? coinAmount;      // 积分抵扣金额
  final RMBFen? cashCouponAmount; // 代金券抵扣金额

  Deduction({
    this.coinAmount,
    this.cashCouponAmount,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
      coinAmount: json['coinAmount'] as RMBFen?,
      cashCouponAmount: json['cashCouponAmount'] as RMBFen?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coinAmount': coinAmount,
      'cashCouponAmount': cashCouponAmount,
    };
  }
}

// ============================================================
// 订单返利信息
// ============================================================

class RebateInfo {
  final int rebatePolicyID;
  final RMBFen rebateCent;
  final SkuID skuID;
  final int qty;
  final int vendorID;  // VendorID

  RebateInfo({
    required this.rebatePolicyID,
    required this.rebateCent,
    required this.skuID,
    required this.qty,
    required this.vendorID,
  });

  factory RebateInfo.fromJson(Map<String, dynamic> json) {
    return RebateInfo(
      rebatePolicyID: json['rebatePolicyID'] as int,
      rebateCent: json['rebateCent'] as RMBFen,
      skuID: json['skuID'] as SkuID,
      qty: json['qty'] as int? ?? 1,
      vendorID: json['vendorID'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rebatePolicyID': rebatePolicyID,
      'rebateCent': rebateCent,
      'skuID': skuID,
      'qty': qty,
      'vendorID': vendorID,
    };
  }
}

// ============================================================
// 新增订单时要使用的卡券
// ============================================================

class AddOrderCoupon {
  final int couponID;  // CouponID
  final RMBFen amount;

  AddOrderCoupon({
    required this.couponID,
    required this.amount,
  });

  factory AddOrderCoupon.fromJson(Map<String, dynamic> json) {
    return AddOrderCoupon(
      couponID: json['couponID'] as int,
      amount: json['amount'] as RMBFen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'couponID': couponID,
      'amount': amount,
    };
  }
}

// ============================================================
// 新增订单时要使用的支付方式
// ============================================================

class AddOrderPayMode {
  final int paymentTypeID;  // PaymentTypeID
  final RMBFen amount;
  final List<String>? images;
  final String? remarks;
  final int? deptID;  // DepartmentID

  AddOrderPayMode({
    required this.paymentTypeID,
    required this.amount,
    this.images,
    this.remarks,
    this.deptID,
  });

  factory AddOrderPayMode.fromJson(Map<String, dynamic> json) {
    return AddOrderPayMode(
      paymentTypeID: json['paymentTypeID'] as int,
      amount: json['amount'] as RMBFen,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      remarks: json['remarks'] as String?,
      deptID: json['deptID'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentTypeID': paymentTypeID,
      'amount': amount,
      'images': images,
      'remarks': remarks,
      'deptID': deptID,
    };
  }
}

// ============================================================
// 订单商品/服务预计提成
// ============================================================

class ExpectedCommissionOfOrder {
  final RMBFen commissionCent;
  final RMBFen floatCent;

  ExpectedCommissionOfOrder({
    required this.commissionCent,
    required this.floatCent,
  });

  factory ExpectedCommissionOfOrder.fromJson(Map<String, dynamic> json) {
    return ExpectedCommissionOfOrder(
      commissionCent: json['commissionCent'] as RMBFen,
      floatCent: json['floatCent'] as RMBFen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commissionCent': commissionCent,
      'floatCent': floatCent,
    };
  }
}

// ============================================================
// 订单折扣信息
// ============================================================

class OrderDiscountInfo {
  final List<Map<String, dynamic>>? serveGifts;
  final List<Map<String, dynamic>>? productGifts;
  final List<Map<String, dynamic>>? coupons;
  final RMBFen? giftsSaveAmount;
  final RMBFen? couponsSaveAmount;
  final RMBFen? adjustPriceSaveAmount;
  final RMBFen? buyMoreDiscountSaveAmount;
  final RMBFen? discountPackageSaveAmount;

  OrderDiscountInfo({
    this.serveGifts,
    this.productGifts,
    this.coupons,
    this.giftsSaveAmount,
    this.couponsSaveAmount,
    this.adjustPriceSaveAmount,
    this.buyMoreDiscountSaveAmount,
    this.discountPackageSaveAmount,
  });

  factory OrderDiscountInfo.fromJson(Map<String, dynamic> json) {
    return OrderDiscountInfo(
      serveGifts: (json['serveGifts'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      productGifts: (json['productGifts'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      coupons: (json['coupons'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      giftsSaveAmount: json['giftsSaveAmount'] as RMBFen?,
      couponsSaveAmount: json['couponsSaveAmount'] as RMBFen?,
      adjustPriceSaveAmount: json['adjustPriceSaveAmount'] as RMBFen?,
      buyMoreDiscountSaveAmount: json['buyMoreDiscountSaveAmount'] as RMBFen?,
      discountPackageSaveAmount: json['discountPackageSaveAmount'] as RMBFen?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serveGifts': serveGifts,
      'productGifts': productGifts,
      'coupons': coupons,
      'giftsSaveAmount': giftsSaveAmount,
      'couponsSaveAmount': couponsSaveAmount,
      'adjustPriceSaveAmount': adjustPriceSaveAmount,
      'buyMoreDiscountSaveAmount': buyMoreDiscountSaveAmount,
      'discountPackageSaveAmount': discountPackageSaveAmount,
    };
  }
}

// ============================================================
// 新增店内零售单商品信息
// ============================================================

class ProductInfo {
  final SkuID? productID;
  final RMBFen discountPrice;
  final RMBFen totalDiscountPrice;
  final int? goodsID;  // GoodsID
  final int? serviceItemID;  // ItemID
  final int? quantity;
  final ServiceID? serviceID;
  final List<int>? couponIDs;  // CouponID[]
  final AddOrderInfoType type;
  final OrderOfIsGift isGift;
  final int? itemID;  // ItemID
  final OrderDiscountInfo? discountInfo;

  ProductInfo({
    this.productID,
    required this.discountPrice,
    required this.totalDiscountPrice,
    this.goodsID,
    this.serviceItemID,
    this.quantity,
    this.serviceID,
    this.couponIDs,
    required this.type,
    required this.isGift,
    this.itemID,
    this.discountInfo,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productID: json['productID'] as SkuID?,
      discountPrice: json['discountPrice'] as RMBFen,
      totalDiscountPrice: json['totalDiscountPrice'] as RMBFen,
      goodsID: json['goodsID'] as int?,
      serviceItemID: json['serviceItemID'] as int?,
      quantity: json['quantity'] as int?,
      serviceID: json['serviceID'] as ServiceID?,
      couponIDs: (json['couponIDs'] as List<dynamic>?)?.cast<int>(),
      type: AddOrderInfoType.fromValue(json['type'] as int? ?? 1),
      isGift: OrderOfIsGift.fromValue(json['isGift'] as int? ?? 0),
      itemID: json['itemID'] as int?,
      discountInfo: json['discountInfo'] != null
          ? OrderDiscountInfo.fromJson(json['discountInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'discountPrice': discountPrice,
      'totalDiscountPrice': totalDiscountPrice,
      'goodsID': goodsID,
      'serviceItemID': serviceItemID,
      'quantity': quantity,
      'serviceID': serviceID,
      'couponIDs': couponIDs,
      'type': type.value,
      'isGift': isGift.value,
      'itemID': itemID,
      'discountInfo': discountInfo?.toJson(),
    };
  }
}

// ============================================================
// 订单商品状态
// ============================================================

enum OrderProductState {
  normal(1),  // 正常
  refunded(2);  // 已退

  final int value;
  const OrderProductState(this.value);

  static OrderProductState fromValue(int value) {
    return OrderProductState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderProductState.normal,
    );
  }
}

// ============================================================
// 订单商品
// ============================================================

class OrderProduct {
  final int id;  // OrderProductID
  final String orderNumber;  // OrderNumZ1
  final int? warehouseID;  // WarehouseID | null
  final SkuID productID;
  final RMBFen productPrice;
  final RMBFen discountAmount;
  final RMBFen revenueAmount;
  final RMBFen costPrice;
  final RMBFen costTotalAmount;
  final int quantity;
  final int? goodsID;  // GoodsID | null
  final OrderProductState state;
  final String? coupons;
  final List<int>? labelIDs;  // LabelID[]
  final OrderOfIsGift isGift;
  final RMBFen? actualCommissionCent;
  final RMBFen? expectedCommissionCent;
  final RMBFen rebateCent;

  OrderProduct({
    required this.id,
    required this.orderNumber,
    this.warehouseID,
    required this.productID,
    required this.productPrice,
    required this.discountAmount,
    required this.revenueAmount,
    required this.costPrice,
    required this.costTotalAmount,
    required this.quantity,
    this.goodsID,
    required this.state,
    this.coupons,
    this.labelIDs,
    required this.isGift,
    this.actualCommissionCent,
    this.expectedCommissionCent,
    required this.rebateCent,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      warehouseID: json['warehouseID'] as int?,
      productID: json['productID'] as SkuID,
      productPrice: json['productPrice'] as RMBFen,
      discountAmount: json['discountAmount'] as RMBFen,
      revenueAmount: json['revenueAmount'] as RMBFen,
      costPrice: json['costPrice'] as RMBFen,
      costTotalAmount: json['costTotalAmount'] as RMBFen,
      quantity: json['quantity'] as int,
      goodsID: json['goodsID'] as int?,
      state: OrderProductState.fromValue(json['state'] as int? ?? 1),
      coupons: json['coupons'] as String?,
      labelIDs: (json['labelIDs'] as List<dynamic>?)?.cast<int>(),
      isGift: OrderOfIsGift.fromValue(json['isGift'] as int? ?? 0),
      actualCommissionCent: json['actualCommissionCent'] as RMBFen?,
      expectedCommissionCent: json['expectedCommissionCent'] as RMBFen?,
      rebateCent: json['rebateCent'] as RMBFen? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'warehouseID': warehouseID,
      'productID': productID,
      'productPrice': productPrice,
      'discountAmount': discountAmount,
      'revenueAmount': revenueAmount,
      'costPrice': costPrice,
      'costTotalAmount': costTotalAmount,
      'quantity': quantity,
      'goodsID': goodsID,
      'state': state.value,
      'coupons': coupons,
      'labelIDs': labelIDs,
      'isGift': isGift.value,
      'actualCommissionCent': actualCommissionCent,
      'expectedCommissionCent': expectedCommissionCent,
      'rebateCent': rebateCent,
    };
  }
}

// ============================================================
// 订单非标商品
// ============================================================

class OrderItem {
  final int id;  // OrderItemID
  final String orderNumber;  // OrderNumZ1
  final int warehouseID;  // WarehouseID
  final SkuID productID;
  final RMBFen discountAmount;
  final RMBFen revenueAmount;
  final RMBFen costPrice;
  final RMBFen costTotalAmount;
  final int quantity;
  final int itemID;  // ItemID
  final OrderProductState state;

  OrderItem({
    required this.id,
    required this.orderNumber,
    required this.warehouseID,
    required this.productID,
    required this.discountAmount,
    required this.revenueAmount,
    required this.costPrice,
    required this.costTotalAmount,
    required this.quantity,
    required this.itemID,
    required this.state,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      warehouseID: json['warehouseID'] as int,
      productID: json['productID'] as SkuID,
      discountAmount: json['discountAmount'] as RMBFen,
      revenueAmount: json['revenueAmount'] as RMBFen,
      costPrice: json['costPrice'] as RMBFen,
      costTotalAmount: json['costTotalAmount'] as RMBFen,
      quantity: json['quantity'] as int,
      itemID: json['itemID'] as int,
      state: OrderProductState.fromValue(json['state'] as int? ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'warehouseID': warehouseID,
      'productID': productID,
      'discountAmount': discountAmount,
      'revenueAmount': revenueAmount,
      'costPrice': costPrice,
      'costTotalAmount': costTotalAmount,
      'quantity': quantity,
      'itemID': itemID,
      'state': state.value,
    };
  }
}

// ============================================================
// 店内零售单扩展表
// ============================================================

class ShopSale {
  final int shopSaleID;
  final int shopSaleOrderID;  // OrderID
  final RMBFen? incCoins;
  final RMBFen? decCoins;
  final bool? isNew;
  final UserIdent? shoppingGuideIdent;
  final String? platformNumber;

  ShopSale({
    required this.shopSaleID,
    required this.shopSaleOrderID,
    this.incCoins,
    this.decCoins,
    this.isNew,
    this.shoppingGuideIdent,
    this.platformNumber,
  });

  factory ShopSale.fromJson(Map<String, dynamic> json) {
    return ShopSale(
      shopSaleID: json['shopSaleID'] as int? ?? 0,
      shopSaleOrderID: json['shopSaleOrderID'] as int? ?? 0,
      incCoins: json['incCoins'] as RMBFen?,
      decCoins: json['decCoins'] as RMBFen?,
      isNew: json['isNew'] as bool?,
      shoppingGuideIdent: json['shoppingGuideIdent'] as UserIdent?,
      platformNumber: json['platformNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopSaleID': shopSaleID,
      'shopSaleOrderID': shopSaleOrderID,
      'incCoins': incCoins,
      'decCoins': decCoins,
      'isNew': isNew,
      'shoppingGuideIdent': shoppingGuideIdent,
      'platformNumber': platformNumber,
    };
  }
}

// ============================================================
// 支付详情
// ============================================================

enum PaymentDetailStatus {
  normal(1),    // 正常
  failed(2),    // 失败
  refund(3),    // 已退款
  paying(4),    // 支付中
  paid(5);      // 已支付

  final int value;
  const PaymentDetailStatus(this.value);

  static PaymentDetailStatus fromValue(int value) {
    return PaymentDetailStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentDetailStatus.normal,
    );
  }
}

class PaymentDetail {
  final int paymentDetailID;
  final String paymentDetailNumber;
  final String orderNumber;
  final int paymentTypeID;  // PaymentTypeID
  final RMBFen amount;
  final PaymentDetailStatus status;
  final String? platformNumber;
  final String? remarks;
  final RMBFen fees;
  final UserIdent? createdBy;
  final UnixTimestamp? createdAt;
  final UserIdent? updatedBy;
  final UnixTimestamp? updatedAt;
  final List<String>? images;

  PaymentDetail({
    required this.paymentDetailID,
    required this.paymentDetailNumber,
    required this.orderNumber,
    required this.paymentTypeID,
    required this.amount,
    required this.status,
    this.platformNumber,
    this.remarks,
    required this.fees,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.images,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      paymentDetailID: json['paymentDetailID'] as int,
      paymentDetailNumber: json['paymentDetailNumber'] as String,
      orderNumber: json['orderNumber'] as String,
      paymentTypeID: json['paymentTypeID'] as int,
      amount: json['amount'] as RMBFen,
      status: PaymentDetailStatus.fromValue(json['status'] as int? ?? 1),
      platformNumber: json['platformNumber'] as String?,
      remarks: json['remarks'] as String?,
      fees: json['fees'] as RMBFen? ?? 0,
      createdBy: json['createdBy'] as UserIdent?,
      createdAt: json['createdAt'] as UnixTimestamp?,
      updatedBy: json['updatedBy'] as UserIdent?,
      updatedAt: json['updatedAt'] as UnixTimestamp?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentDetailID': paymentDetailID,
      'paymentDetailNumber': paymentDetailNumber,
      'orderNumber': orderNumber,
      'paymentTypeID': paymentTypeID,
      'amount': amount,
      'status': status.value,
      'platformNumber': platformNumber,
      'remarks': remarks,
      'fees': fees,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
      'images': images,
    };
  }
}

// ============================================================
// 店内零售单（Order & ShopSale 组合）
// 用于 /order/shop-sale-list 返回
// ============================================================

class ShopSaleOrder {
  final Order order;
  final ShopSale? shopSale;

  ShopSaleOrder({
    required this.order,
    this.shopSale,
  });

  factory ShopSaleOrder.fromJson(Map<String, dynamic> json) {
    return ShopSaleOrder(
      order: Order.fromJson(json),
      shopSale: json['shopSaleID'] != null
          ? ShopSale.fromJson(json)
          : null,
    );
  }

  /// 获取显示用的状态文本
  String get statusText {
    switch (order.status) {
      case OrderStatus.shippedPaid:
        return '已完成';
      case OrderStatus.unshippedPaid:
        return '进行中';
      case OrderStatus.cancelled:
        return '已取消';
      default:
        return '进行中';
    }
  }

  /// 获取会员名称（散客显示"散客"）
  String get displayCustomerName {
    // 需要配合会员信息接口获取
    return '会员';
  }
}

// ============================================================
// 订单详情（包含商品和支付信息）
// ============================================================

class OrderDetail {
  final Order order;
  final ShopSale? shopSale;
  final List<OrderProduct> products;
  final List<OrderItem> items;
  final List<PaymentDetail> payments;

  OrderDetail({
    required this.order,
    this.shopSale,
    this.products = const [],
    this.items = const [],
    this.payments = const [],
  });

  /// 获取所有商品（标准商品 + 非标商品）
  List<Map<String, dynamic>> get allProducts {
    final List<Map<String, dynamic>> result = [];
    
    for (final p in products) {
      result.add({
        'id': p.id,
        'name': '商品',  // 需要通过 product 接口获取名称
        'productID': p.productID,
        'price': p.productPrice,
        'discountAmount': p.discountAmount,
        'quantity': p.quantity,
        'subtotal': p.discountAmount,
        'isGift': p.isGift == OrderOfIsGift.yes,
      });
    }
    
    return result;
  }

  /// 获取总品项数
  int get itemCount => products.length + items.length;

  /// 获取优惠金额
  RMBFen get discountAmount {
    final total = order.orderAmount;
    final paid = order.revenueAmount ?? order.discountAmount;
    return total - paid;
  }
}

// ============================================================
// 订单主表
// ============================================================

class Order {
  final OrderID orderID;
  final String orderNumber;
  final RMBFen orderAmount;
  final RMBFen discountAmount;
  final RMBFen? revenueAmount;
  final RMBFen? paymodeAmount;
  final RMBFen? costAmount;
  final UserIdent? sellerIdent;
  final UserIdent handlerIdent;
  final int departmentID;  // DepartmentID
  final OrderStatus status;
  final int type;  // SalesType
  final String? genre;  // SalesModeText
  final List<int>? couponIDs;  // CouponID[]
  final List<int>? paymentIDs;  // PaymentTypeID[]
  final UnixTimestamp createdAt;
  final UnixTimestamp? updatedAt;
  final UserIdent? updatedByIdent;
  final String? remarks;
  final UserIdent? customerIdent;
  final List<String>? images;
  final String? recycleOrderNumber;
  final String? invoiceNumber;
  final Deduction? deductionAmount;
  final List<int>? labelIDs;  // LabelID[]
  final List<String>? jointOrderNumber;
  final String? mainOrderNumber;

  Order({
    required this.orderID,
    required this.orderNumber,
    required this.orderAmount,
    required this.discountAmount,
    this.revenueAmount,
    this.paymodeAmount,
    this.costAmount,
    this.sellerIdent,
    required this.handlerIdent,
    required this.departmentID,
    required this.status,
    required this.type,
    this.genre,
    this.couponIDs,
    this.paymentIDs,
    required this.createdAt,
    this.updatedAt,
    this.updatedByIdent,
    this.remarks,
    this.customerIdent,
    this.images,
    this.recycleOrderNumber,
    this.invoiceNumber,
    this.deductionAmount,
    this.labelIDs,
    this.jointOrderNumber,
    this.mainOrderNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderID: json['orderID'] as OrderID,
      orderNumber: json['orderNumber'] as String,
      orderAmount: json['orderAmount'] as RMBFen,
      discountAmount: json['discountAmount'] as RMBFen,
      revenueAmount: json['revenueAmount'] as RMBFen?,
      paymodeAmount: json['paymodeAmount'] as RMBFen?,
      costAmount: json['costAmount'] as RMBFen?,
      sellerIdent: json['sellerIdent'] as UserIdent?,
      handlerIdent: json['handlerIdent'] as UserIdent,
      departmentID: json['departmentID'] as int,
      status: OrderStatus.fromValue(json['status'] as int? ?? 3),
      type: json['type'] as int? ?? 1,
      genre: json['genre'] as String?,
      couponIDs: (json['couponIDs'] as List<dynamic>?)?.cast<int>(),
      paymentIDs: (json['paymentIDs'] as List<dynamic>?)?.cast<int>(),
      createdAt: json['createdAt'] as UnixTimestamp,
      updatedAt: json['updatedAt'] as UnixTimestamp?,
      updatedByIdent: json['updatedByIdent'] as UserIdent?,
      remarks: json['remarks'] as String?,
      customerIdent: json['customerIdent'] as UserIdent?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      recycleOrderNumber: json['recycleOrderNumber'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      deductionAmount: json['deductionAmount'] != null
          ? Deduction.fromJson(json['deductionAmount'] as Map<String, dynamic>)
          : null,
      labelIDs: (json['labelIDs'] as List<dynamic>?)?.cast<int>(),
      jointOrderNumber: (json['jointOrderNumber'] as List<dynamic>?)?.cast<String>(),
      mainOrderNumber: json['mainOrderNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'orderNumber': orderNumber,
      'orderAmount': orderAmount,
      'discountAmount': discountAmount,
      'revenueAmount': revenueAmount,
      'paymodeAmount': paymodeAmount,
      'costAmount': costAmount,
      'sellerIdent': sellerIdent,
      'handlerIdent': handlerIdent,
      'departmentID': departmentID,
      'status': status.value,
      'type': type,
      'genre': genre,
      'couponIDs': couponIDs,
      'paymentIDs': paymentIDs,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'updatedByIdent': updatedByIdent,
      'remarks': remarks,
      'customerIdent': customerIdent,
      'images': images,
      'recycleOrderNumber': recycleOrderNumber,
      'invoiceNumber': invoiceNumber,
      'deductionAmount': deductionAmount?.toJson(),
      'labelIDs': labelIDs,
      'jointOrderNumber': jointOrderNumber,
      'mainOrderNumber': mainOrderNumber,
    };
  }
}
