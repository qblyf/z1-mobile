# 商城订单模块 · PRD

> **模块**：商城订单
> **版本**：v1.2
> **日期**：2026-05-28
> **状态**：待开发
> **依据**：`z1-mid/src/types/mall-order-types.ts` + 后端接口分析
> **⚠️ 类型文件**：`lib/types/api/mall-order-types.dart` **待生成**（需从后端 TS 翻译）

---

## 一、页面路径总览

```
商城订单
├── /mall/order                → 商城订单列表
│         ↓
│   /mall/order/:id           → 商城订单详情
│         ↓
│   /mall/order/:id/logistics → 物流信息
```

---

## 二、商城订单列表

### 2.1 路由

```
路径：/mall/order
名称：商城订单
父级：订单 Tab 或首页
```

### 2.2 基本布局

```
┌──────────────────────────────────┐
│ ← 商城订单                       │
├──────────────────────────────────┤
│                                  │
│  状态筛选：                      │
│  [全部] [待支付] [已支付] [已发货]│
│  [已完成] [已退款]              │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 单号：SC202605170001      │  │
│  │ 会员：李四  手机：138****88│  │
│  │ 商品：足金手镯 x1          │  │
│  │ 金额：¥12,800.00         │  │
│  │ 状态：[已发货]             │  │
│  │ 时间：2026-05-17 14:30   │  │
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

### 2.3 核心交互逻辑

#### 状态筛选

| Tab | 说明 | 后端 MallOrderStatus |
|-----|------|---------------------|
| 全部 | 所有商城订单 | - |
| 待支付 | 待支付定金 | `1` |
| 已支付 | 已支付 | `21`, `22`, `23` |
| 已发货 | 已发货 | `6`, `61` |
| 已完成 | 订单完成 | `7` |
| 已退款 | 已退款 | `31`, `32`, `41`, `42` |

#### 列表项

- 点击列表项 → 跳转商城订单详情
- 支持下拉刷新、上拉加载更多

---

## 三、商城订单详情

### 3.1 路由

```
路径：/mall/order/:id
名称：商城订单详情
参数：id（商城订单号）
```

### 3.2 基本布局

```
┌──────────────────────────────────┐
│ ← 商城订单详情        [联系顾客]  │
├──────────────────────────────────┤
│                                  │
│  状态：[已发货]                  │
│                                  │
│  单号：SC202605170001            │
│  时间：2026-05-17 10:30         │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 收货人信息                 │  │
│  │ 姓名：张三                 │  │
│  │ 手机：139****6666          │  │
│  │ 地址：北京市朝阳区xxx        │  │
│  └────────────────────────────┘  │
│                                  │
│  商品明细                        │
│  ┌────────────────────────────┐  │
│  │ 📿 足金凤尾纹手镯  1件    │  │
│  │ 单价：¥12,800  数量：1    │  │
│  └────────────────────────────┘  │
│                                  │
│  ─────────────────────────────── │
│  商品总价：¥12,800.00           │
│  优惠：-¥200.00（优惠券）       │
│  实付：¥12,600.00              │
│  ─────────────────────────────── │
│                                  │
│  物流信息                        │
│  快递：顺丰速运 SF1234567890   │
│                                  │
│        [查看物流]                │
│                                  │
└──────────────────────────────────┘
```

### 3.3 核心交互逻辑

#### 状态操作

| 状态 | 可操作 |
|------|--------|
| 待支付 | 取消订单 |
| 已支付 | 取消订单（需审核）、申请退款 |
| 部分支付 | 申请退款 |
| 已发货 | 查看物流、申请退款 |
| 已完成 | — |
| 已退款 | — |
| 已支付未完成 | 申请退款 |

---

## 四、类型定义

### 4.1 商城订单状态

```dart
enum MallOrderStatus {
  待支付(1),              // 待支付
  部分支付(21),            // 部分支付
  已支付(22),              // 已支付
  已支付未完成(23),        // 锁货流程未完成
  未支付撤销(31),          // 未支付撤销
  已支付撤销(32),          // 已支付撤销
  未发货已退款(41),        // 未发货已退款
  已发货已退款(42),        // 已发货已退款
  已出库(6),              // 已出库
  已送达(61),             // 已送达
  已完成(7),              // 已完成
  已评价(8);              // 已评价

  final int value;
  const MallOrderStatus(this.value);

  static MallOrderStatus fromValue(int value) {
    return MallOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MallOrderStatus.待支付,
    );
  }

  String get label {
    switch (this) {
      case MallOrderStatus.待支付: return '待支付';
      case MallOrderStatus.部分支付: return '部分支付';
      case MallOrderStatus.已支付: return '已支付';
      case MallOrderStatus.已支付未完成: return '待确认';
      case MallOrderStatus.未支付撤销: return '已取消';
      case MallOrderStatus.已支付撤销: return '已取消';
      case MallOrderStatus.未发货已退款: return '已退款';
      case MallOrderStatus.已发货已退款: return '已退款';
      case MallOrderStatus.已出库: return '已发货';
      case MallOrderStatus.已送达: return '已送达';
      case MallOrderStatus.已完成: return '已完成';
      case MallOrderStatus.已评价: return '已评价';
    }
  }
}
```

### 4.2 商城订单

> **⚠️ 重要**：以下类型定义参考 `lib/types/api/mall-order-types.ts`（唯一真实源）

```dart
// 类型文件：z1-mid/src/types/mall-order-types.ts

class MallOrder {
  final int mallID;                    // 商城订单 ID
  final String number;                  // 商城订单号
  final String customerIdent;           // 顾客（UserIdent）
  final int departmentID;               // 销售部门 ID
  final List<MallOrderInfo> info;       // 商品/服务信息
  final MallOrderStatus status;         // 状态
  final int orderAmount;                // 订单原始应付金额（分）
  final int discountAmount;             // 订单折扣后金额（分）
  final int costAmount;                 // 成本金额（分）
  final int? coinsUsed;                // 使用积分
  final int? coinsUsedAmount;          // 积分抵现金额（分）
  final int? postAmount;               // 邮费（分）
  final int payAmount;                  // 实付金额（分）
  final MallOrderTransportType transport; // 运输方式
  final MallOrderPostInfo? postInfo;   // 邮寄信息
  final List<MallOrderCoupon>? cashCoupons; // 代金券信息
  final List<MallOrderCoupon>? coupons;    // 优惠券信息
  final String? remarks;              // 备注
  final int createdAt;                 // 创建时间
  final int? payAt;                   // 支付时间
  final List<String>? images;         // 附件
  final String? logisticsCompany;      // 物流公司
  final String? logisticsNumber;       // 物流单号
}

enum MallOrderTransportType {
  邮寄('post'),
  自提('store');

  final String value;
  const MallOrderTransportType(this.value);
}

class MallOrderPostInfo {
  final String name;
  final String mobilePhone;
  final String address;
}

// 订单详情（包含门店订单）
class OrderMallOrderDetail {
  final MallOrder mallOrder;           // 商城订单
  final Order order;                   // 门店销售订单
  final NetSale salesNet;              // 网销信息
  final List<OrderProduct>? orderProduct; // 订单商品
  final List<OrderService>? orderService; // 订单服务
}
```

---

## 五、接口清单

| 页面 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 商城订单列表 | `/mall-order/list` | GET | 商城订单列表 |
| 商城订单数量 | `/mall-order/count` | GET | 商城订单数量统计 |
| 商城订单详情 | `/mall-order/detail` | GET | 商城订单详情 |
| 待支付取消 | `/mall-order/unpaid-cancel` | POST | 待支付取消订单 |
| 已支付取消 | `/mall-order/paid-cancel` | POST | 已支付取消订单（需审核）|
| 确认发货 | `/mall-order/outed-of-warehouse` | POST | 确认发货出库 |
| 完成订单 | `/mall-order/finish` | POST | 完成订单 |
| 门店订单详情 | `/mall-order/order-mall-order-detail` | GET | 通过商城订单号获取门店订单详情 |

---

## 六、状态流转

> ⚠️ 注意：根据后端 `MallOrderStatus` 枚举，完整状态如下

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  [待支付] ──→ [部分支付] ──→ [已支付] ──→ [已支付未完成] ──→ [已出库]    │
│     ↓              ↓              ↓                    ↓           ↓    │
│  [未支付撤销]  [未支付撤销]  [已支付撤销]              │    [已发货已退款]│
│                                                         ↓                    │
│                                                    [已送达]                  │
│                                                         ↓                    │
│                                                    [已完成]                  │
│                                                         ↓                    │
│                                                    [已评价]                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

状态说明：
- 待支付(1)：未支付
- 部分支付(21)：部分支付定金
- 已支付(22)：已支付全款
- 已支付未完成(23)：锁货流程未完成
- 已出库(6)：已发货出库
- 已送达(61)：已送达
- 已完成(7)：订单完成
- 已评价(8)：已评价

退款流程：
  部分支付/已支付 → 未发货已退款(41)
  已出库 → 已发货已退款(42)

撤销流程：
  待支付/部分支付 → 未支付撤销(31)
  已支付/已支付未完成 → 已支付撤销(32)
```

---

## 七、异常/边界情况

| 场景 | 处理 |
|------|------|
| 列表为空 | 显示空状态"暂无商城订单" |
| 订单不存在 | 显示错误页"订单不存在" |
| 物流信息无 | 显示"暂无物流信息" |
| 网络错误 | 显示错误提示，可重试 |

---

## 八、待确认事项

1. 商城订单是否需要支持退款申请入口？
2. 物流信息是否需要实时查询第三方 API？
3. 商城订单与门店订单的关系？（是否关联？）

---

## 九、模块关联图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            商城订单模块关联                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌──────────┐     ┌──────────┐     ┌──────────┐                        │
│    │ 预订单   │────→│ 商城订单 │────→│ 物流详情 │                        │
│    │ 转正式   │     │ 列表     │     └──────────┘                        │
│    └──────────┘     └────┬─────┘                                         │
│                          │                                                │
│                          │ 关联                                           │
│                          ↓                                                │
│                    ┌──────────┐                                          │
│                    │ 退货退款 │                                          │
│                    │ 申请     │                                          │
│                    └──────────┘                                          │
│                                                                             │
│    ┌──────────┐                                                           │
│    │ 门店订单 │ ◀─── 通过 order-mall-order-detail 关联                   │
│    └──────────┘                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.1 模块跳转关系

| 来源模块 | 触发条件 | 目标模块 | 说明 |
|---------|---------|---------|------|
| 预订单 | 转正式订单 | 商城订单 | mallOrderNumber 关联 |
| 商城订单列表 | 点击列表项 | 商城订单详情 | — |
| 商城订单详情 | 点击查看物流 | 物流详情页 | — |
| 商城订单详情 | 申请退款 | 退货退款申请 | — |
| 商城订单详情 | 点击门店订单 | 门店订单详情 | order-mall-order-detail |

### 9.2 数据共享

| 数据 | 来源 | 消费者 |
|------|------|--------|
| `mallOrderNumber` | 商城订单 | 预订单转正式 |
| `number` | 商城订单 | 门店订单详情 |
| `orderNumber` | 商城订单 | 退货退款申请 |
