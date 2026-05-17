import 'package:equatable/equatable.dart';

/// 零售订单状态
enum RetailOrderStatus {
  draft,      // 草稿（刚创建）
  pending,    // 待支付
  paid,       // 已支付
  completed,  // 已完成
  cancelled,  // 已取消
}

/// 销售类型
enum SalesType {
  retail,   // 零售
  wholesale, // 批发
  project,  // 工程
}

/// 支付方式
enum PayMethod {
  cash(1, '现金'),
  wechat(2, '微信'),
  alipay(3, '支付宝'),
  bankCard(4, '银行卡');

  final int id;
  final String label;
  const PayMethod(this.id, this.label);
}

/// 商品项
class ProductItem extends Equatable {
  final int productID;
  final String productName;
  final int price; // 单位：分
  final int quantity;
  final int discountPrice; // 单品折扣后价格（分）
  final int totalDiscountPrice; // 该商品总价（分）
  final int type; // 1=普通商品
  final bool isGift; // 是否赠品

  const ProductItem({
    required this.productID,
    required this.productName,
    required this.price,
    required this.quantity,
    this.discountPrice = 0,
    this.totalDiscountPrice = 0,
    this.type = 1,
    this.isGift = false,
  });

  /// 单价（元）
  double get priceYuan => price / 100;

  /// 总价（元）
  double get totalPriceYuan => totalDiscountPrice / 100;

  ProductItem copyWith({
    int? quantity,
    int? discountPrice,
    int? totalDiscountPrice,
    bool? isGift,
  }) {
    return ProductItem(
      productID: productID,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      discountPrice: discountPrice ?? this.discountPrice,
      totalDiscountPrice: totalDiscountPrice ?? this.totalDiscountPrice,
      type: type,
      isGift: isGift ?? this.isGift,
    );
  }

  @override
  List<Object?> get props => [productID, quantity, discountPrice, isGift];
}

/// 支付项
class PayItem extends Equatable {
  final int method; // 支付方式ID
  final int amount; // 金额（分）

  const PayItem({
    required this.method,
    required this.amount,
  });

  double get amountYuan => amount / 100;

  @override
  List<Object?> get props => [method, amount];
}

/// 零售订单（开单流程状态）
class RetailOrder extends Equatable {
  final String? orderNumber;
  final SalesType salesType;
  final int? customerIdent; // 会员ID
  final String? customerName; // 会员名
  final int? sellerIdent; // 销售员ID
  final int warehouseID; // 仓库ID
  final List<ProductItem> products;
  final List<PayItem> payments;
  final int decreaseCoins; // 积分抵扣金额（分）
  final String? remarks;
  final RetailOrderStatus status;

  const RetailOrder({
    this.orderNumber,
    this.salesType = SalesType.retail,
    this.customerIdent,
    this.customerName,
    this.sellerIdent,
    this.warehouseID = 0,
    this.products = const [],
    this.payments = const [],
    this.decreaseCoins = 0,
    this.remarks,
    this.status = RetailOrderStatus.draft,
  });

  /// 商品总价（元）
  double get productsTotalYuan {
    return products.fold<int>(0, (sum, p) => sum + p.totalDiscountPrice) / 100;
  }

  /// 支付总额（元）
  double get paymentsTotalYuan {
    return payments.fold<int>(0, (sum, p) => sum + p.amount) / 100;
  }

  /// 实付金额（元）
  double get actualPayYuan {
    return productsTotalYuan - (decreaseCoins / 100);
  }

  /// 找零金额（元）
  double get changeYuan {
    final diff = paymentsTotalYuan - actualPayYuan;
    return diff > 0 ? diff : 0;
  }

  RetailOrder copyWith({
    String? orderNumber,
    SalesType? salesType,
    int? customerIdent,
    String? customerName,
    int? sellerIdent,
    int? warehouseID,
    List<ProductItem>? products,
    List<PayItem>? payments,
    int? decreaseCoins,
    String? remarks,
    RetailOrderStatus? status,
  }) {
    return RetailOrder(
      orderNumber: orderNumber ?? this.orderNumber,
      salesType: salesType ?? this.salesType,
      customerIdent: customerIdent ?? this.customerIdent,
      customerName: customerName ?? this.customerName,
      sellerIdent: sellerIdent ?? this.sellerIdent,
      warehouseID: warehouseID ?? this.warehouseID,
      products: products ?? this.products,
      payments: payments ?? this.payments,
      decreaseCoins: decreaseCoins ?? this.decreaseCoins,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [orderNumber, customerIdent, products, payments, status];
}

/// 会员信息（简化）
class MemberInfo extends Equatable {
  final int ident;
  final String realName;
  final String mobilePhone;
  final int experience; // 积分
  final int coin; // 金币

  const MemberInfo({
    required this.ident,
    required this.realName,
    required this.mobilePhone,
    this.experience = 0,
    this.coin = 0,
  });

  @override
  List<Object?> get props => [ident, realName, mobilePhone];
}