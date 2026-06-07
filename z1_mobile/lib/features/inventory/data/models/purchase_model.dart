import 'package:equatable/equatable.dart';

enum PurchaseState {
  pending(0, '待入库'),
  partial(1, '部分入库'),
  completed(2, '已完成');

  final int value;
  final String label;
  const PurchaseState(this.value, this.label);

  static PurchaseState fromInt(int? value) {
    switch (value) {
      case 1:
        return PurchaseState.partial;
      case 2:
        return PurchaseState.completed;
      default:
        return PurchaseState.pending;
    }
  }
}

class PurchaseModel extends Equatable {
  final int id;
  final String? code;
  final String? supplierName;
  final PurchaseState state;
  final int createdAt;
  final int productCount;
  final int totalAmount;

  const PurchaseModel({
    required this.id,
    this.code,
    this.supplierName,
    required this.state,
    required this.createdAt,
    this.productCount = 0,
    this.totalAmount = 0,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      supplierName: json['supplierName'] as String?,
      state: PurchaseState.fromInt(json['state'] as int?),
      createdAt: json['createdAt'] as int? ?? 0,
      productCount: json['productCount'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }

  String get stateLabel => state.label;

  String get formattedAmount {
    return '¥${(totalAmount / 100).toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [id, code, supplierName, state, createdAt];
}

class PurchaseDetailModel extends Equatable {
  final int id;
  final String? code;
  final String? supplierName;
  final PurchaseState state;
  final int createdAt;
  final String? remarks;
  final List<PurchaseProductModel> products;

  const PurchaseDetailModel({
    required this.id,
    this.code,
    this.supplierName,
    required this.state,
    required this.createdAt,
    this.remarks,
    this.products = const [],
  });

  factory PurchaseDetailModel.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List<dynamic>? ?? [];
    return PurchaseDetailModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      supplierName: json['supplierName'] as String?,
      state: PurchaseState.fromInt(json['state'] as int?),
      createdAt: json['createdAt'] as int? ?? 0,
      remarks: json['remarks'] as String?,
      products: productsList
          .map((p) => PurchaseProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  String get stateLabel => state.label;

  int get totalAmount {
    return products.fold(0, (sum, p) => sum + (p.price * p.count));
  }

  String get formattedAmount {
    return '¥${(totalAmount / 100).toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [id, code, supplierName, state, createdAt, products];
}

class PurchaseProductModel extends Equatable {
  final int productId;
  final String productName;
  final String? spec;
  final String? barcode;
  final int price;
  final int count;
  final int inboundCount;

  const PurchaseProductModel({
    required this.productId,
    required this.productName,
    this.spec,
    this.barcode,
    required this.price,
    required this.count,
    this.inboundCount = 0,
  });

  factory PurchaseProductModel.fromJson(Map<String, dynamic> json) {
    return PurchaseProductModel(
      productId: json['productID'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      spec: json['spec'] as String?,
      barcode: json['barcode'] as String?,
      price: json['price'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      inboundCount: json['inboundCount'] as int? ?? 0,
    );
  }

  String get formattedPrice {
    return '¥${(price / 100).toStringAsFixed(2)}';
  }

  int get remainCount => count - inboundCount;

  @override
  List<Object?> get props => [productId, productName, price, count, inboundCount];
}

class WarehouseModel extends Equatable {
  final int id;
  final String name;
  final String? number;

  const WarehouseModel({
    required this.id,
    required this.name,
    this.number,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      number: json['number'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}