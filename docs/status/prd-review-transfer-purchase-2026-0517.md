# PRD 验证报告：调拨模块 & 采购模块

> **日期**：2026-05-17
> **验证人**：测试 Agent
> **状态**：部分通过（需修复）

---

## 一、整体评估

| 模块 | PRD 状态 | 代码实现 | 问题数 |
|------|----------|----------|--------|
| 调拨列表 | ✅ 完整 | ✅ 已实现 | 1 |
| 新建调拨 | ⚠️ 占位符 | ⚠️ 占位符 | 0 |
| 调拨详情 | ⚠️ 占位符 | ⚠️ 占位符 | 0 |
| 采购列表 | ✅ 完整 | ✅ 已实现 | 2 |
| 采购详情 | ⚠️ 占位符 | ⚠️ 占位符 | 0 |
| 采购入库 | ⚠️ 占位符 | ⚠️ 占位符 | 0 |

---

## 二、问题详情

### 问题 1：调拨列表 - 跳转路径不一致

**严重程度**：中

**问题描述**：
- PRD 定义：`/inventory/transfer/:id`
- 代码实现：`/inventory/transfer/${item.id}`（第201行）

**结论**：路径一致 ✅

---

### 问题 2：调拨列表 - 状态字段名不匹配

**严重程度**：低

**问题描述**：
- PRD 字段名：`status`（pending/shipped/received/completed）
- 代码字段名：`state`（TransferState 枚举：pending/shipping/completed）

**分析**：
- PRD 定义了4个状态：pending / shipped / received / completed
- 代码实现了3个状态：pending(0) / shipping(1) / completed(2)
- 代码缺少 `received` 状态

**建议修正**：
1. 调拨状态枚举缺少 `received`（已入库）状态，需补充
2. 可接受字段名用 `state` 而非 `status`，但需在 PRD 中同步更新术语

**代码位置**：`transfer_model.dart:3-22`

---

### 问题 3：采购列表 - 缺少仓库字段

**严重程度**：中

**问题描述**：
- PRD 字段：`warehouseId`, `warehouseName`
- 代码字段：仅有 `supplierName`，无仓库信息

**建议修正**：
在 `PurchaseModel` 中补充 `warehouseId` 和 `warehouseName` 字段

**代码位置**：`purchase_model.dart:24-63`

---

### 问题 4：采购列表 - 缺少入库进度字段

**严重程度**：中

**问题描述**：
- PRD 字段：`receivedItems`（已入库品项数）
- 代码字段：无 `receivedItems` 字段，无法显示入库进度

**建议修正**：
在 `PurchaseModel` 中补充 `receivedItems` 字段，用于显示入库进度

**代码位置**：`purchase_model.dart:24-63`

---

### 问题 5：采购列表 - 跳转路径不一致

**严重程度**：高

**问题描述**：
- PRD 跳转：`/inventory/purchase/:id`
- 代码跳转：`/inventory/purchase-list/${item.id}`（第342行）

**分析**：
代码使用了 `/inventory/purchase-list/` 前缀，与 PRD 不符。PRD 定义为 `/inventory/purchase/:id`。

**建议修正**：
修改跳转路径为 `/inventory/purchase/${item.id}`

**代码位置**：`purchase_list_page.dart:342`

---

## 三、字段对照表

### 调拨列表（TransferSummary）

| PRD 字段 | 类型 | 代码字段 | 类型 | 一致 |
|----------|------|----------|------|------|
| id | int | id | int | ✅ |
| code | string | code | String? | ✅ |
| fromWarehouseId | int | fromWarehouseID | int | ✅ |
| fromWarehouseName | string | fromWarehouseName | String? | ✅ |
| toWarehouseId | int | toWarehouseID | int | ✅ |
| toWarehouseName | string | toWarehouseName | String? | ✅ |
| status | enum | state | enum | ⚠️ 字段名不同 |
| totalItems | int | productCount | int | ⚠️ 语义相同，名称不同 |
| totalQuantity | int | - | - | ❌ 缺失 |
| createdAt | datetime | createdAt | int | ✅ |
| shippedAt | datetime | - | - | ❌ 缺失 |
| receivedAt | datetime | - | - | ❌ 缺失 |

### 采购列表（PurchaseSummary）

| PRD 字段 | 类型 | 代码字段 | 类型 | 一致 |
|----------|------|----------|------|------|
| id | int | id | int | ✅ |
| code | string | code | String? | ✅ |
| supplierId | int | - | - | ❌ 缺失 |
| supplierName | string | supplierName | String? | ✅ |
| warehouseId | int | - | - | ❌ 缺失 |
| warehouseName | string | - | - | ❌ 缺失 |
| status | enum | state | enum | ⚠️ 字段名不同 |
| totalItems | int | productCount | int | ✅ |
| receivedItems | int | - | - | ❌ 缺失 |
| totalAmount | int | totalAmount | int | ✅ |
| createdAt | datetime | createdAt | int | ✅ |
| expectedAt | datetime | - | - | ❌ 缺失 |

---

## 四、接口对照

### api_endpoints.dart

| 接口路径 | PRD 定义 | 代码实现 | 一致 |
|----------|----------|----------|------|
| /transfer/list | ✅ | ✅ ApiEndpoints.transferList | ✅ |
| /warehouse/list-base | ✅ | ✅ ApiEndpoints.warehouseList | ✅ |
| /purchase/list | ✅ | ✅ ApiEndpoints.purchaseList | ✅ |

---

## 五、建议修正方案

### 高优先级

1. **修正采购列表跳转路径**
   - 文件：`purchase_list_page.dart:342`
   - 修改：`/inventory/purchase-list/${item.id}` → `/inventory/purchase/${item.id}`

2. **修正采购入库跳转路径**
   - 文件：`purchase_list_page.dart:349`
   - 修改：`/inventory/purchase-inbound/${item.id}` → `/inventory/purchase-inbound/${item.id}`（已正确）

### 中优先级

3. **补充采购模型缺失字段**
   - 文件：`purchase_model.dart`
   - 补充：`warehouseId`, `warehouseName`, `receivedItems`

4. **补充调拨模型缺失字段**
   - 文件：`transfer_model.dart`
   - 补充：`received` 状态枚举值

### 低优先级

5. **PRD 文档更新**
   - 将 `status` 字段统一改为 `state`（与代码一致）
   - 将 `totalItems` 改为 `productCount`
   - 将 `totalQuantity` 补充到调拨列表字段说明

---

## 六、结论

| 项目 | 状态 |
|------|------|
| PRD 文档质量 | ✅ 清晰完整 |
| 接口路径 | ✅ 正确 |
| 调拨列表实现 | ⚠️ 需补充字段和状态 |
| 采购列表实现 | ⚠️ 需修正跳转路径和补充字段 |
| 详情/入库页 | ⚠️ 占位符，待开发 |

**总体结论**：PRD 与代码基本一致，但存在跳转路径错误和字段缺失问题，需修正后合并。