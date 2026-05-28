# 订单模块 API 使用示例

> **版本**：v1.0
> **日期**：2026-05-28

---

## 一、销售订单

### 1.1 订单列表

```dart
import 'package:z1_mobile/core/api/api_client.dart';
import 'package:z1_mobile/core/api/api_endpoints.dart';

// 今日订单列表
final today = DateTime.now();
final startOfDay = DateTime(today.year, today.month, today.day);

final response = await apiClient.get(
  ApiEndpoints.shopSaleList(),
  params: {
    'minCreatedAt': startOfDay.millisecondsSinceEpoch ~/ 1000,
    'page': 1,
    'pageSize': 20,
  },
);

// 换货订单列表（type=3）
final changeOrders = await apiClient.get(
  ApiEndpoints.shopSaleList(),
  params: {
    'types': '3',
  },
);
```

### 1.2 订单详情

```dart
// 获取订单详情（组合调用）
final orderNumber = 'XS202605170001';

// 1. 获取订单基本信息
final orderResponse = await apiClient.get(
  ApiEndpoints.shopSaleList(params: {'number': orderNumber}),
);
final orderData = orderResponse['data'][0];

// 2. 获取订单商品列表
final productsResponse = await apiClient.get(
  ApiEndpoints.shopSaleInfo(orderData['orderID']),
);
final products = productsResponse['data'];

// 3. 获取会员信息
final memberResponse = await apiClient.get(
  ApiEndpoints.memberSpecified(orderData['customerIdent']),
);
final member = memberResponse['data'];

// 组合数据
final orderDetail = {
  'order': orderData,
  'products': products,
  'member': member,
};
```

---

## 二、退货退款

### 2.1 退货退款列表

```dart
// 全部退货退款
final allReturns = await apiClient.get(
  ApiEndpoints.returnRefundList(),
);

// 待审核
final pendingReturns = await apiClient.get(
  ApiEndpoints.returnRefundList(params: {'status': 'applied'}),
);

// 已完成
final completedReturns = await apiClient.get(
  ApiEndpoints.returnRefundList(params: {'status': 'finished'}),
);

// 查询某订单的退款信息
final orderRefunds = await apiClient.get(
  ApiEndpoints.returnRefundList(params: {'orderNumber': 'XS202605170001'}),
);
```

### 2.2 创建退货退款

```dart
await apiClient.post(
  ApiEndpoints.returnRefundAdd,
  data: {
    'orderNumber': 'XS202605170001',
    'reason': '商品有瑕疵',
    'description': '佩戴一周后发现表面有明显划痕',
    'images': ['https://example.com/image1.jpg'],
    'info': [
      {
        'skuID': 12345,
        'qty': 1,
        'skuPrice': 1280000,
        'discountPrice': 1280000,
      }
    ],
    'isRefundOnly': false,
  },
);
```

### 2.3 审核退货退款

```dart
// 同意
await apiClient.post(
  ApiEndpoints.returnRefundAudit,
  data: {
    'id': 1,
    'agree': true,
    'remarks': '审核通过',
  },
);

// 拒绝
await apiClient.post(
  ApiEndpoints.returnRefundReject,
  data: {
    'id': 1,
    'reason': '不符合退货条件',
  },
);
```

### 2.4 完成退款

```dart
await apiClient.post(
  ApiEndpoints.returnRefundComplete,
  data: {
    'id': 1,
  },
);
```

---

## 三、预订单

### 3.1 预订单列表

```dart
// 全部
final allPreOrders = await apiClient.get(
  ApiEndpoints.preSaleOrderList(),
);

// 待支付
final unpaidOrders = await apiClient.get(
  ApiEndpoints.preSaleOrderList(params: {'status': 'unpaid'}),
);

// 已支付
final paidOrders = await apiClient.get(
  ApiEndpoints.preSaleOrderList(params: {'status': 'paid'}),
);
```

### 3.2 预订单详情

```dart
final preOrder = await apiClient.get(
  ApiEndpoints.preSaleOrderDetail(123),
);
```

### 3.3 转正式订单

```dart
// 1. 先创建商城订单
final mallOrderResponse = await apiClient.post(
  ApiEndpoints.mallOrderAdd,
  data: {
    'customerIdent': 'xxx',
    'info': [...],
  },
);
final mallOrderNumber = mallOrderResponse['number'];

// 2. 更新预订单
await apiClient.post(
  ApiEndpoints.preSaleOrderEdit,
  data: {
    'id': 123,
    'mallOrderNumber': mallOrderNumber,
    'toOrderAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
  },
);
```

### 3.4 申请退款

```dart
await apiClient.post(
  ApiEndpoints.preSaleOrderReturnRefund,
  data: {
    'id': 123,
    'reason': '不想要了',
  },
);
```

---

## 四、商城订单

### 4.1 商城订单列表

```dart
// 全部
final allMallOrders = await apiClient.get(
  ApiEndpoints.mallOrderList(),
);

// 待支付
final unpaidMallOrders = await apiClient.get(
  ApiEndpoints.mallOrderList(params: {'status': '1'}),
);

// 已发货（6, 61）
final shippedMallOrders = await apiClient.get(
  ApiEndpoints.mallOrderList(params: {'status': '6,61'}),
);

// 已退款（31, 32, 41, 42）
final refundedMallOrders = await apiClient.get(
  ApiEndpoints.mallOrderList(params: {'status': '31,32,41,42'}),
);
```

### 4.2 确认发货

```dart
await apiClient.post(
  ApiEndpoints.mallOrderOutWarehouse,
  data: {
    'id': 123,
    'logisticsCompany': '顺丰速运',
    'logisticsNumber': 'SF1234567890',
  },
);
```

### 4.3 获取门店订单

```dart
final orderDetail = await apiClient.get(
  ApiEndpoints.mallOrderToOrder('SC202605170001'),
);
// 返回 OrderMallOrderDetail 包含 mallOrder, order, salesNet 等
```

---

## 五、换货

### 5.1 创建门店换货

```dart
await apiClient.post(
  ApiEndpoints.orderChangeShopSale,
  data: {
    'sourceOrderNumber': 'XS202605170001',
    'reason': '款式不喜欢',
    'outProducts': [
      {
        'productID': 12345,
        'quantity': 1,
        'price': 1200000,
      }
    ],
    'inProducts': [
      {
        'productID': 67890,
        'quantity': 1,
        'price': 1250000,
      }
    ],
    'priceDifference': 50000, // 补差价 500 元
  },
);
```

---

## 六、金额处理

### 6.1 分转元显示

```dart
// 金额字段都是分（cent），显示时需除以 100
String formatMoney(int cent) {
  return '¥${(cent / 100).toStringAsFixed(2)}';
}

// 示例
print(formatMoney(1280000)); // ¥12800.00
```

### 6.2 订单金额计算

```dart
class OrderAmount {
  final int orderAmount;     // 订单原价（分）
  final int discountAmount;  // 折扣后金额（分）
  final int? revenueAmount; // 收入金额（分）
  final int? paymodeAmount; // 商家实收（分）

  int get actualPay => paymodeAmount ?? revenueAmount ?? discountAmount;
  String get displayPay => '¥${(actualPay / 100).toStringAsFixed(2)}';
}
```

### 6.3 预订单金额计算

```dart
class PreSaleAmount {
  final int amount;         // 预订总价（分）
  final int expandAmount;  // 膨胀金额（分）
  final int paidAmount;   // 已付定金（分）

  int get remainAmount => amount - expandAmount - paidAmount;
  String get displayRemain => '¥${(remainAmount / 100).toStringAsFixed(2)}';
}
```

---

## 七、状态转换

### 7.1 OrderStatus

```dart
enum OrderStatus {
  shippedPaid(1, '已完成'),
  shippedUnpaid(2, '进行中'),
  unshippedUnpaid(3, '进行中'),
  unshippedPaid(4, '进行中'),
  cancelled(5, '已取消');

  final int value;
  final String label;
  const OrderStatus(this.value, this.label);

  static OrderStatus fromValue(int value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.unshippedUnpaid,
    );
  }
}
```

### 7.2 ReturnRefundStatus

```dart
enum ReturnRefundStatus {
  applied('applied', '待审核'),
  audited('audited', '已审核'),
  canceled('canceled', '已拒绝'),
  consulting('consulting', '协商中'),
  finished('finished', '已完成');

  final String value;
  final String label;
  const ReturnRefundStatus(this.value, this.label);

  static ReturnRefundStatus fromValue(String value) {
    return ReturnRefundStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReturnRefundStatus.applied,
    );
  }
}
```

### 7.3 PreSaleOrderStatus

```dart
enum PreSaleOrderStatus {
  unpaid('unpaid', '待支付'),
  paid('paid', '已支付'),
  completed('completed', '已完成'),
  applyRefund('apply-refund', '申请退款'),
  refunded('refunded', '已退款'),
  canceled('canceled', '已取消');

  final String value;
  final String label;
  const PreSaleOrderStatus(this.value, this.label);

  static PreSaleOrderStatus fromValue(String value) {
    return PreSaleOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PreSaleOrderStatus.unpaid,
    );
  }
}
```

### 7.4 MallOrderStatus

```dart
enum MallOrderStatus {
  待支付(1, '待支付'),
  部分支付(21, '已支付'),
  已支付(22, '已支付'),
  已支付未完成(23, '待确认'),
  未支付撤销(31, '已取消'),
  已支付撤销(32, '已取消'),
  未发货已退款(41, '已退款'),
  已发货已退款(42, '已退款'),
  已出库(6, '已发货'),
  已送达(61, '已发货'),
  已完成(7, '已完成'),
  已评价(8, '已评价');

  final int value;
  final String label;
  const MallOrderStatus(this.value, this.label);

  static MallOrderStatus fromValue(int value) {
    return MallOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MallOrderStatus.待支付,
    );
  }
}
```
