# 订单详情页面修改任务

## 任务来源

docs/features/order-list-detail-prd.md 第六章

## 需要修改的内容

### 1. api_endpoints.dart

```dart
// 修改 shopSaleInfoByNumber 方法
// 改用 shopSaleList + number 参数
static String shopSaleInfoByNumber(String orderNumber) =>
    '/order/shop-sale-list?number=$orderNumber';
```

### 2. order_detail_remote_datasource.dart

```dart
// 修改前
final response = await apiClient.get<Map<String, dynamic>>(
  ApiEndpoints.shopSaleInfoByNumber(orderNumber),  // /order/shop-sale-info/XXX
  ...
);

// 修改后 - 后端接口是 GET
final response = await apiClient.get<Map<String, dynamic>>(
  ApiEndpoints.shopSaleInfoByNumber(orderNumber),  // /order/shop-sale-list?number=XXX
  ...
);
```

### 3. order_model.dart

```dart
// 修改字段映射
factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
  id: json['orderID'] as int? ?? 0,  // 不是 json['id']
  orderNumber: json['orderNumber'] as String? ?? '',
  createdAt: json['createdAt'] as int? ?? 0,
  customerName: '',  // 需要单独调用 /members/specified 获取
  orderAmount: json['orderAmount'] as int? ?? 0,
  discountAmount: json['discountAmount'] as int? ?? 0,
  revenueAmount: json['revenueAmount'] as int?,
  status: json['status'] as int? ?? 3,  // 是 int 不是 String
  incCoins: json['incCoins'] as int?,
  decCoins: json['decCoins'] as int?,
);

// 修改状态转换
enum OrderStatus {
  pending('pending', '待处理'),
  completed('completed', '已完成'),
  refunded('refunded', '已退款');

  final String value;
  final String label;
  const OrderStatus(this.value, this.label);

  static OrderStatus fromValue(int value) {
    switch (value) {
      case 1: return OrderStatus.completed;  // 已发货已付款
      case 2: return OrderStatus.pending;    // 已发货未付款
      case 3: return OrderStatus.pending;    // 未发货未付款
      case 4: return OrderStatus.pending;    // 未发货已付款
      case 5: return OrderStatus.refunded;  // 取消
      default: return OrderStatus.pending;
    }
  }
}
```

### 4. 会员信息获取

当 order.customerIdent 不为空时，调用 `/members/specified?userIdents={customerIdent}` 获取会员信息填充 customerName。

## 详细说明

见 docs/features/order-list-detail-prd.md 第六章
