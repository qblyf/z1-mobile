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