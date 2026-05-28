# Flutter Agent 类型定义指南

> **版本**: v2.0
> **更新日期**: 2026-05-28
> **重要**: 配合 [ai-doc-type-workflow.md](ai-doc-type-workflow.md) 使用

---

## ⚠️ 核心原则

**类型定义是唯一真实源，文档仅供参考。**

当你开发 Flutter 数据层代码时：

1. **先读类型文件** `lib/types/api/`
2. **参数名、字段类型以类型文件为准**
3. **不要参考 `docs/api-spec.md` 中的参数描述**
4. **类型文件和文档不一致时 → 以类型文件为准**

---

## 📁 类型文件结构

```
z1_mobile/lib/types/
├── common.dart          # 通用类型（ID 别名、Result、Failure 等）
└── api/
    ├── api.dart         # 导出入口（所有类型汇总）
    ├── product-types.dart     # 商品类型
    ├── sku-types.dart        # SKU 类型
    ├── spu-types.dart        # SPU 类型
    ├── service-types.dart    # 服务类型
    ├── category-types.dart   # 分类类型
    ├── mall-category-types.dart  # 商城分类类型
    ├── member-types.dart     # 会员类型
    ├── order-types.dart      # 订单类型
    ├── auth-types.dart       # 认证类型
    ├── transfer-types.dart   # 调拨类型
    ├── purchase-types.dart   # 采购类型
    ├── approval-types.dart   # 审批类型
    ├── stock-types.dart      # 库存类型
    ├── stocktaking-types.dart # 盘库类型
    ├── serial-types.dart     # 序列号类型
    ├── dashboard-types.dart  # 仪表盘类型
    └── task-types.dart       # 任务类型
```

---

## 🔍 开发前必读

### 开发流程

```
业务需求 → PRD 文档 → 类型文件（唯一真实源）→ Flutter 开发
     ↓           ↓              ↓
   做什么      引用类型路径    用什么字段
```

**重要**: 开发前必须阅读以下文档：

1. `docs/guides/ai-doc-type-workflow.md` - 完整开发流程
2. 类型文件 `lib/types/api/*.dart` - 字段定义

---

## 📖 如何使用类型

### 1. 导入类型

```dart
// ✅ 正确：从类型文件导入
import 'package:z1_mobile/types/api.dart';           // 所有类型
import 'package:z1_mobile/types/api/member-types.dart'; // 单个类型

// ❌ 错误：从文档复制参数名
// docs/api-spec.md 中的参数名可能已过时！
```

### 2. 读取类型定义

每个类型文件包含：

```dart
// lib/types/api/order-types.dart

// 枚举类型
enum OrderStatus {
  pending(0),      // 待支付
  paid(1),        // 已支付
  completed(2);  // 已完成

  final int value;
  const OrderStatus(this.value);

  static OrderStatus fromValue(int value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

// 数据模型
class Order {
  final OrderID id;           // 订单 ID（来自 common.dart）
  final RMBFen amount;         // 金额单位：分
  final OrderStatus status;    // 枚举类型

  Order({
    required this.id,
    required this.amount,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      amount: RMBFen(json['amount'] as int),
      status: OrderStatus.fromValue(json['status'] as int),
    );
  }
}

// 请求参数
class CreateOrderParams {
  final String customerIdent;
  final RMBFen amount;

  CreateOrderParams({
    required this.customerIdent,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'customerIdent': customerIdent,
    'amount': amount.value,
  };
}
```

### 3. 使用类型

```dart
// ✅ 正确：使用类型文件中的定义
import 'package:z1_mobile/types/api/order-types.dart';

final order = Order.fromJson(response.data);

// 金额转换（分 → 元）
Text('¥${(order.amount.centValue / 100).toStringAsFixed(2)}')

// 枚举转换
if (order.status == OrderStatus.paid) { ... }
```

---

## 🚫 禁止事项

| 禁止 | 原因 | 正确做法 |
|------|------|---------|
| ❌ 自己发明参数名 | 参数名必须从类型文件来 | 从类型文件 import |
| ❌ 参考 docs/api-spec.md 的参数名 | 文档可能过时 | 以类型文件为准 |
| ❌ 用猜测的参数名调接口 | 会导致 400 错误 | 先读类型文件 |
| ❌ 类型文件没有的类型就自己编 | 应该问后端或查 SDK | 参考 SDK 源码 |

---

## 🆘 遇到未知类型怎么办

### 情况 1：类型文件存在但不完整

```
检查步骤：
1. 确认类型文件 lib/types/api/ 中是否有相关类型
2. 如果有但字段不全 → 参考 z1-mid SDK 源码补充
3. 如果完全没有 → 去 z1-mid/src/types/ 找
```

### 情况 2：类型文件完全没有

```
处理步骤：
1. 去 z1-mid SDK 源码查找：/Users/fan/www/AI/z1/z1-mid/src/types/
2. 找到后通知文档助手添加类型
3. 等待类型添加完成后再开发
```

### 情况 3：后端接口和类型不匹配

```
处理步骤：
1. 确认是后端的问题还是类型的问题
2. 如果是类型问题 → 通知文档助手更新
3. 如果是后端问题 → 通知后端修复
4. **不要** 自己改类型去适配后端
```

---

## ⚠️ 重要：两套分类 ID 系统

**Flutter 开发时必须注意**，返回数据中有两套分类 ID：

| 字段 | 类型 | 来源 | 用途 |
|------|------|------|------|
| `spuCateID` | `int` | 旧分类系统 | **不要用这个匹配商城分类** |
| `mallThirdCate` | `List<int>` | 商城分类 | **用这个匹配商城分类** |

### 正确用法

```dart
// 从类型文件知道返回的是 mallThirdCate: number[]
final sku = GetSelectSKUBaseData.fromJson(response);

// ✅ 正确：用 mallThirdCate 匹配
if (sku.mallThirdCate.isNotEmpty) {
  final mallCateId = sku.mallThirdCate.last; // 取最后一个元素（第三级分类）
  // 用 mallCateId 去商城分类树里查找
}

// ❌ 错误：用 spuCateID 匹配（这是旧分类系统）
final cateId = sku.spuCateID; // 跟 MallCategory.id 是两套不同的系统！
```

---

## 🔗 相关文件

| 文件 | 说明 |
|------|------|
| `docs/guides/ai-doc-type-workflow.md` | 完整开发流程规范 |
| `lib/types/api.dart` | 类型导出入口 |
| `lib/types/common.dart` | 基础类型（ID、Result、Failure 等） |
| `scripts/generate-dart-types.js` | 类型生成脚本（不推荐使用） |
| SDK 类型源码 | `/Users/fan/www/AI/z1/z1-mid/src/types/` |
| 生成的 Dart 类型 | `z1_mobile/lib/types/api/` |
