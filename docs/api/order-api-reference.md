# 订单模块 API 文档

> **版本**：v1.0
> **日期**：2026-05-28
> **依据**：`order-list-detail-prd.md` + 后端路由

---

## 一、销售订单

### 1.1 创建零售单

```
POST /order/sale-shop-add
```

> ✅ **已确认**：后端接口路径为 `/order/sale-shop-add`

**请求体**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| warehouseID | number | 是 | 仓库 ID |
| customerIdent | string | 否 | 顾客标识符 |
| sellerIdent | number | 否 | 销售员 ID |
| productInfos | array | 是 | 商品列表 |
| payMode | array | 是 | 支付方式 |
| remarks | string | 否 | 备注 |

**productInfos 子对象**：

| 参数 | 类型 | 说明 |
|------|------|------|
| productID | number | 商品 ID |
| price | number | 单价（分）|
| quantity | number | 数量 |
| type | number | 类型 |
| isGift | boolean | 是否赠品 |

**payMode 子对象**：

| 参数 | 类型 | 说明 |
|------|------|------|
| method | string | 支付方式：`cash`/`wechat`/`alipay`/`card` |
| amount | number | 金额（分）|

**返回**：

```json
{
  "code": 10000,
  "orderNumber": "XS202605170001"
}
```

---

### 1.2 订单列表

```
GET /order/shop-sale-list
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| number | string | 否 | 订单号（精确查询）|
| types | string | 否 | 销售类型（1=卖,2=退,3=换），逗号分隔多个 |
| status | string | 否 | 订单状态，逗号分隔多个 |
| minCreatedAt | number | 否 | 创建时间起点（Unix 秒）|
| maxCreatedAt | number | 否 | 创建时间终点（Unix 秒）|
| sellerIdents | string | 否 | 营业员 ID，逗号分隔 |
| handlerIdents | string | 否 | 收银员 ID，逗号分隔 |
| departmentIDs | string | 否 | 部门 ID，逗号分隔 |
| page | number | 否 | 页码（默认 1）|
| pageSize | number | 否 | 每页条数（默认 20）|

**返回**：`Order[]`（包含 `Order & ShopSale`）

```dart
class Order {
  final int orderID;           // 订单 ID
  final String orderNumber;     // 订单号
  final int orderAmount;       // 订单总价（分）
  final int discountAmount;    // 折扣后总价（分）
  final int? revenueAmount;  // 收入金额（分）
  final int? paymodeAmount;  // 商家实收（分）
  final int type;             // 销售类型：1=卖, 2=退, 3=换
  final int status;           // 订单状态：1=已发货已付款, 2=已发货未付款, 3=未发货未付款, 4=未发货已付款, 5=取消
  final String customerIdent;  // 顾客标识符
  final int createdAt;        // 创建时间
}

class ShopSale {
  final int shopSaleID;
  final int shopSaleOrderID;   // 关联 OrderID
  final int? incCoins;       // 增加积分
  final int? decCoins;       // 消耗积分
}
```

**Flutter 调用**：

```dart
// 订单列表
final response = await apiClient.get('/order/shop-sale-list', params: {
  'minCreatedAt': startDate,
  'maxCreatedAt': endDate,
  'page': 1,
  'pageSize': 20,
});

// 换货筛选（types=3）
final response = await apiClient.get('/order/shop-sale-list', params: {
  'types': '3',
});

// 按订单号查询详情
final response = await apiClient.get('/order/shop-sale-list', params: {
  'number': 'XS202605170001',
});
```

---

### 1.2 订单数量统计

```
GET /order/shop-sale-count
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| types | string | 否 | 销售类型筛选 |
| status | string | 否 | 订单状态筛选 |
| minCreatedAt | number | 否 | 创建时间起点 |
| maxCreatedAt | number | 否 | 创建时间终点 |

**返回**：

```dart
{
  total: number,      // 总数
  amount: number,     // 总金额（分）
}
```

---

### 1.3 订单商品列表

```
GET /order-product/details-by-order-id
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| orderID | number | 是 | 订单 ID |

**返回**：`OrderProduct[]`

```dart
class OrderProduct {
  final int id;              // 订单商品 ID
  final int skuID;           // SKU ID
  final int spuID;          // SPU ID
  final int productPrice;    // 单价（分）
  final int discountPrice;   // 折扣后单价（分）
  final int quantity;       // 数量
  final int? goodsID;       // 货品 ID（强制序列号商品）
  final bool isGift;         // 是否赠品
}
```

---

## 二、退货退款

### 2.1 退货退款列表

```
GET /return-refund-application/list
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | number | 否 | 退货退款申请 ID |
| orderNumber | string | 否 | 销售订单号 |
| status | string | 否 | 状态筛选：`applied`, `audited`, `canceled`, `consulting`, `finished` |
| page | number | 否 | 页码 |
| pageSize | number | 否 | 每页条数 |

**返回**：`ReturnRefundApplication[]`

```dart
class ReturnRefundApplication {
  final int id;                       // 退货退款申请 ID
  final String number;                // 退货退款申请单号
  final String orderNumber;            // 销售订单号
  final List<MallOrderInfo> info;    // 退货商品/服务详情
  final String reason;                 // 退货原因
  final List<Description> description; // 退货描述
  final List<String> images;           // 退货图片
  final String? remarks;              // 备注
  final String createdBy;              // 创建人
  final int createdAt;                 // 创建时间
  final String? updatedBy;            // 更新人
  final int? updatedAt;               // 更新时间
  final ReturnRefundApplicationStatus status; // 状态
  final int expectedCent;             // 预计退款金额（分）
  final bool isRefundOnly;            // 是否仅退款
}

enum ReturnRefundApplicationStatus {
  applied,     // 已申请
  audited,     // 已审核
  canceled,   // 已取消
  consulting,  // 协商中
  finished,   // 已完成
}

class Description {
  final String createdBy;  // 发起人
  final int createdAt;      // 创建时间
  final String content;     // 描述内容
  final bool isCustomer;    // 是否是顾客
}
```

---

### 2.2 退货退款数量

```
GET /return-refund-application/count
```

**返回**：

```dart
{
  total: number,           // 总数
  applied: number,         // 待审核数
  audited: number,         // 已审核数
  finished: number,        // 已完成数
}
```

---

### 2.3 创建退货退款

```
POST /return-refund-application/add
```

**请求体**：

```dart
{
  orderNumber: string,           // 销售订单号
  reason: string,                // 退货原因
  description: string,            // 退货描述
  images: string[],               // 退货图片
  info: MallOrderInfo[],          // 退货商品/服务
  isRefundOnly: boolean,          // 是否仅退款
  remarks: string?,              // 备注
}
```

**返回**：

```dart
{
  id: number,                    // 退货退款申请 ID
  number: string,                // 退货退款申请单号
}
```

---

### 2.4 审核退货退款

```
POST /return-refund-application/audit
```

**请求体**：

```dart
{
  id: number,                     // 退货退款申请 ID
  agree: boolean,                 // 是否同意
  remarks: string?,               // 审核意见
}
```

---

### 2.5 完成退款

```
POST /return-refund-application/complete
```

**请求体**：

```dart
{
  id: number,                     // 退货退款申请 ID
}
```

---

### 2.6 驳回退货退款

```
POST /return-refund-application/reject-audit
```

**请求体**：

```dart
{
  id: number,                     // 退货退款申请 ID
  reason: string,                 // 驳回原因
}
```

---

## 三、商城订单

### 3.1 商城订单列表

```
GET /mall-order/list
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 否 | 状态筛选，多个逗号分隔 |
| page | number | 否 | 页码 |
| pageSize | number | 否 | 每页条数 |

**MallOrderStatus 状态值**：

| 值 | 名称 | Tab 筛选 |
|---|------|---------|
| 1 | 待支付 | 待支付 |
| 21 | 部分支付 | 已支付 |
| 22 | 已支付 | 已支付 |
| 23 | 已支付未完成 | 已支付 |
| 31 | 未支付撤销 | 已退款 |
| 32 | 已支付撤销 | 已退款 |
| 41 | 未发货已退款 | 已退款 |
| 42 | 已发货已退款 | 已退款 |
| 6 | 已出库 | 已发货 |
| 61 | 已送达 | 已发货 |
| 7 | 已完成 | 已完成 |

**返回**：`MallOrder[]`

```dart
class MallOrder {
  final int mallID;                    // 商城订单 ID
  final String number;                  // 商城订单号
  final String customerIdent;            // 顾客标识符
  final int departmentID;                // 销售部门 ID
  final List<MallOrderInfo> info;       // 商品/服务信息
  final MallOrderStatus status;          // 状态
  final int orderAmount;                 // 订单原始应付金额（分）
  final int discountAmount;              // 订单折扣后金额（分）
  final int? coinsUsed;                 // 使用积分
  final int? coinsUsedAmount;           // 积分抵现金额（分）
  final int? postAmount;                // 邮费（分）
  final int payAmount;                   // 实付金额（分）
  final MallOrderTransportType transport; // 运输方式
  final MallOrderPostInfo? postInfo;    // 邮寄信息
  final int createdAt;                  // 创建时间
  final int? payAt;                    // 支付时间
  final String? logisticsCompany;        // 物流公司
  final String? logisticsNumber;         // 物流单号
}

enum MallOrderTransportType {
  post,  // 邮寄
  store, // 自提
}

class MallOrderPostInfo {
  final String name;
  final String mobilePhone;
  final String address;
}
```

---

### 3.2 商城订单详情

```
GET /mall-order/detail
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | number | 是 | 商城订单 ID |

**返回**：`MallOrder`

---

### 3.3 门店订单详情

```
GET /mall-order/order-mall-order-detail
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| number | string | 是 | 商城订单号 |

**返回**：

```dart
class OrderMallOrderDetail {
  final MallOrder mallOrder;            // 商城订单
  final Order order;                    // 门店销售订单
  final NetSale salesNet;               // 网销信息
  final List<OrderProduct>? orderProduct; // 订单商品
  final List<OrderService>? orderService; // 订单服务
}
```

---

### 3.4 确认发货

```
POST /mall-order/outed-of-warehouse
```

**请求体**：

```dart
{
  id: number,                          // 商城订单 ID
  logisticsCompany: string,             // 物流公司
  logisticsNumber: string,              // 物流单号
}
```

---

### 3.5 完成订单

```
POST /mall-order/finish
```

**请求体**：

```dart
{
  id: number,                          // 商城订单 ID
}
```

---

### 3.6 取消订单

```
// 待支付取消
POST /mall-order/unpaid-cancel

// 已支付取消（需审核）
POST /mall-order/paid-cancel
```

**请求体**：

```dart
{
  id: number,                          // 商城订单 ID
  reason: string,                      // 取消原因
}
```

---

## 四、预订单

### 4.1 预订单列表

```
GET /pre-sale-order/list
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 否 | 状态筛选：`unpaid`, `paid`, `apply-refund`, `refunded`, `completed`, `canceled` |
| page | number | 否 | 页码 |
| pageSize | number | 否 | 每页条数 |

**PreSaleOrderStatus 状态值**：

| 值 | 名称 | 说明 |
|---|------|------|
| unpaid | 待支付 | 未支付定金 |
| paid | 已支付 | 已支付定金 |
| completed | 已完成 | 已转正式订单 |
| apply-refund | 申请退款 | 申请退款中 |
| refunded | 已退款 | 已退款 |
| canceled | 已取消 | 已取消 |

**返回**：`PreSaleOrder[]`

```dart
class PreSaleOrder {
  final int id;                        // 预订单 ID
  final String number;                 // 预订单号
  final String customer;                // 预订人标识符
  final int? department;               // 预订部门
  final int activity;                   // 预售活动 ID
  final int activityProduct;            // 预售活动商品 ID
  final int amount;                    // 预定金额（分）
  final int expandAmount;              // 膨胀金额（分）
  final int? preSaleProduct;           // 预订的商品 SKU ID
  final List<int> products;             // 捆绑商品 SKU ID 列表
  final List<int> services;            // 捆绑服务 ID 列表
  final String? mallOrderNumber;       // 关联的商城订单号
  final PreSaleOrderStatus status;      // 状态
  final PreSaleOrderPayment? payment;  // 支付信息
  final String? remarks;               // 备注
  final int? payAt;                   // 支付时间
  final int? toOrderAt;               // 转订单时间
  final int createdAt;                 // 创建时间
  final String? refundReason;          // 退款原因
  final bool? isLockSku;              // 是否锁货
}

class PreSaleOrderPayment {
  final String platform;               // 'wx'
  final String content;                // 支付凭证内容
}
```

---

### 4.2 预订单详情

```
GET /pre-sale-order/mall-detail
```

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | number | 是 | 预订单 ID |

**返回**：`PreSaleOrder`

---

### 4.3 创建预订单

```
POST /pre-sale-order/add
```

**请求体**：

```dart
{
  customer: string,                   // 预订人标识符
  department: number?,                 // 预订部门
  activity: number,                   // 预售活动 ID
  activityProduct: number,              // 预售活动商品 ID
  preSaleProduct: number?,             // 预订的商品 SKU ID
  products: number[],                  // 捆绑商品 SKU ID 列表
  services: number[],                 // 捆绑服务 ID 列表
  remarks: string?,                   // 备注
}
```

---

### 4.4 支付定金

```
POST /pre-sale-order/pay
```

**请求体**：

```dart
{
  id: number,                         // 预订单 ID
  platform: string,                    // 支付平台：'wx'
  content: string,                     // 支付凭证
}
```

---

### 4.5 转正式订单

> ⚠️ 需先调用 `/mall-order/add` 创建商城订单，再调用此接口

```
POST /pre-sale-order/edit
```

**请求体**：

```dart
{
  id: number,                         // 预订单 ID
  mallOrderNumber: string,            // 商城订单号
  toOrderAt: number,                  // 转订单时间
  preSaleProduct: number?,             // 预订的商品 SKU ID
  remarks: string?,                   // 备注
}
```

**返回**：更新后的 `PreSaleOrder`

---

### 4.6 申请退款

```
POST /pre-sale-order/return-refund
```

**请求体**：

```dart
{
  id: number,                         // 预订单 ID
  reason: string,                      // 退款原因
}
```

---

### 4.7 审核退款

```
POST /pre-sale-order/audit-return-refund
```

**请求体**：

```dart
{
  id: number,                         // 预订单 ID
  agree: boolean,                      // 是否同意
  remarks: string?,                   // 审核意见
}
```

---

## 五、换货

### 5.1 创建门店换货

```
POST /order-change/add/shop-sale
```

**请求体**：

```dart
{
  sourceOrderNumber: string,           // 原订单号
  reason: string,                      // 换货原因
  outProducts: ChangeProduct[],         // 换出商品
  inProducts: ChangeProduct[],          // 换入商品
  priceDifference: number,             // 补差价（分）
  remarks: string?,                    // 备注
}

class ChangeProduct {
  final int productID;                 // SKU ID
  final int quantity;                 // 数量
  final int price;                    // 单价（分）
}
```

---

### 5.2 创建网销换货

```
POST /order-change/add/net-sale
```

> 请求体同 `/order-change/add/shop-sale`

---

### 5.3 创建批发换货

```
POST /order-change/add/out-sale
```

> 请求体同 `/order-change/add/shop-sale`

---

## 六、金额计算

> ⚠️ **重要**：所有金额字段单位为**分（cent）**，显示时需除以 100

### 金额字段说明

| 字段 | 说明 | 计算公式 |
|------|------|---------|
| `orderAmount` | 订单原价 | — |
| `discountAmount` | 折扣后金额 | — |
| `revenueAmount` | 收入金额 | `discountAmount - 积分抵扣` |
| `payAmount` / `paymodeAmount` | 商家实收 | `revenueAmount - 代金券抵扣` |
| `expectedCent` | 预计退款金额 | — |

### 预订单金额计算

| 字段 | 说明 |
|------|------|
| `amount` | 预订总价 |
| `expandAmount` | 膨胀金额 |
| `payment.amount` | 已付定金 |
| 待付尾款 | `amount - expandAmount - 已付定金` |

---

## 七、状态流转图

### 7.1 销售订单

```
[待支付] ──→ [已支付] ──→ [已发货] ──→ [已完成]
   │           │           │
   │           │           │
   ↓           ↓           ↓
[已取消]  [退款中]   [已退款]
```

### 7.2 退货退款

```
[已申请] ──→ [已审核] ──→ [已完成]
   │           │
   │           ↓
   ↓      [协商中]
[已取消]      │
              ↓
         [已申请]
```

### 7.3 预订单

```
[待支付] ──→ [已支付] ──→ [已完成]
   │           │
   ↓           ↓
[已取消]  [申请退款] ──→ [已退款]
              │
              ↓
         [已拒绝]
```

### 7.4 商城订单

```
[待支付] ──→ [已支付] ──→ [已出库] ──→ [已完成]
   │           │           │
   ↓           ↓           ↓
[已取消]  [退款中]   [已退款]
```
