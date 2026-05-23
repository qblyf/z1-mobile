/// 回收单模型（以旧换新）
/// 用于零售开单中关联回收单
class RecycleOrderModel {
  /// 回收单ID
  final int id;

  /// 回收单号
  final String orderNumber;

  /// 客户姓名
  final String? customerName;

  /// 客户手机号
  final String? customerPhone;

  /// 回收类型（如：手机、电脑等）
  final String? recycleType;

  /// 回收商品名称
  final String? productName;

  /// 回收评估金额（单位：分）
  final int evaluateAmount;

  /// 回收实际金额（单位：分）
  final int? actualAmount;

  /// 补贴金额（单位：分）
  final int subsidyAmount;

  /// 回收单状态：pending-待处理，completed-已完成，cancelled-已取消
  final String status;

  /// 创建时间
  final DateTime createTime;

  /// 过期时间（用于判断是否在有效期内）
  final DateTime? expireTime;

  const RecycleOrderModel({
    required this.id,
    required this.orderNumber,
    this.customerName,
    this.customerPhone,
    this.recycleType,
    this.productName,
    required this.evaluateAmount,
    this.actualAmount,
    required this.subsidyAmount,
    required this.status,
    required this.createTime,
    this.expireTime,
  });

  /// 从 JSON 解析
  factory RecycleOrderModel.fromJson(Map<String, dynamic> json) {
    return RecycleOrderModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? json['orderNumber'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? json['customerName'] as String?,
      customerPhone: json['customer_phone'] as String? ?? json['customerPhone'] as String?,
      recycleType: json['recycle_type'] as String? ?? json['recycleType'] as String?,
      productName: json['product_name'] as String? ?? json['productName'] as String?,
      evaluateAmount: json['evaluate_amount'] as int? ?? json['evaluateAmount'] as int? ?? 0,
      actualAmount: json['actual_amount'] as int? ?? json['actualAmount'] as int?,
      subsidyAmount: json['subsidy_amount'] as int? ?? json['subsidyAmount'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      createTime: json['create_time'] != null || json['createTime'] != null
          ? DateTime.tryParse(json['create_time'] as String? ?? json['createTime'] as String? ?? '') ?? DateTime.now()
          : DateTime.now(),
      expireTime: json['expire_time'] != null || json['expireTime'] != null
          ? DateTime.tryParse(json['expire_time'] as String? ?? json['expireTime'] as String? ?? '')
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'recycle_type': recycleType,
      'product_name': productName,
      'evaluate_amount': evaluateAmount,
      'actual_amount': actualAmount,
      'subsidy_amount': subsidyAmount,
      'status': status,
      'create_time': createTime.toIso8601String(),
      'expire_time': expireTime?.toIso8601String(),
    };
  }

  /// 评估金额显示（除以100转为元）
  String get evaluateAmountDisplay => '¥${(evaluateAmount / 100).toStringAsFixed(2)}';

  /// 补贴金额显示（除以100转为元）
  String get subsidyAmountDisplay => '¥${(subsidyAmount / 100).toStringAsFixed(2)}';

  /// 实际金额显示（除以100转为元）
  String? get actualAmountDisplay =>
      actualAmount != null ? '¥${(actualAmount! / 100).toStringAsFixed(2)}' : null;

  /// 是否已过期
  bool get isExpired =>
      expireTime != null && expireTime!.isBefore(DateTime.now());

  /// 是否可绑定
  bool get canBind =>
      status == 'pending' && !isExpired;

  @override
  String toString() {
    return 'RecycleOrderModel(id: $id, orderNumber: $orderNumber, subsidyAmount: $subsidyAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecycleOrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
