import 'package:equatable/equatable.dart';

class OrderProductModel extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final String skuCode;
  final int quantity;
  final int unitPrice;
  final int discountAmount;
  final int finalPrice;

  const OrderProductModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.skuCode,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.finalPrice,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: json['id'] as int? ?? 0,
      orderId: json['orderID'] as int? ?? 0,
      productId: json['productID'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      skuCode: json['skuCode'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: json['unitPrice'] as int? ?? 0,
      discountAmount: json['discountAmount'] as int? ?? 0,
      finalPrice: json['finalPrice'] as int? ?? 0,
    );
  }

  double get unitPriceYuan => unitPrice / 100;
  double get discountAmountYuan => discountAmount / 100;
  double get finalPriceYuan => finalPrice / 100;

  @override
  List<Object?> get props => [id, orderId, productId, skuCode];
}