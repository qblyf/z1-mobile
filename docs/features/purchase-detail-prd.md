# 采购模块 · 详细 PRD（列表页补充）

> **模块**：库存管理（采购子模块）
> **版本**：v1.0
> **日期**：2026-05-17
> **状态**：初稿
> **依据**：feature-list.md + api-endpoints.dart

> **⚠️ 类型唯一真实源**：API 字段定义以 `lib/types/api/` 为准（相关：purchase-types.dart）。本 PRD 不复制具体字段名/类型。

---

## 一、页面路径总览

```
/inventory/purchase-list      → 采购列表
        ↓
/inventory/purchase/:id       → 采购详情
        ↓
/inventory/purchase-inbound/:id  → 采购入库
```

> **注意**：采购详情和入库的文档已有，本文档补充采购列表页面。

---

## 二、页面 1：采购列表

### 2.1 路由

```
路径：/inventory/purchase-list
名称：采购列表
父级：库存管理（/inventory/home）
```

### 2.2 基本布局

```
┌──────────────────────────────────┐
│ ← 采购                           │
├──────────────────────────────────┤
│                                  │
│  状态筛选：                      │
│  [全部] [待入库] [部分入库] [已完成] │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 采购单号：CG202605150001   │  │
│  │ 供应商：深圳黄金珠宝公司    │  │
│  │ 仓库：广州天河店            │  │
│  │ 状态：[待入库]             │  │
│  │ 时间：2026-05-15 10:30    │  │
│  │ 品项：10  已入库：0/10     │  │
│  │ 金额：¥128,000.00         │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 采购单号：CG202605140002   │  │
│  │ 供应商：广州白银批发公司    │  │
│  │ 仓库：深圳南山店           │  │
│  │ 状态：[部分入库]  5/10     │  │
│  │ 时间：2026-05-14 09:00    │  │
│  │ 品项：8   已入库：5       │  │
│  │ 金额：¥86,000.00          │  │
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

### 2.3 核心交互逻辑

#### 状态筛选

- 四个 Tab：全部 / 待入库 / 部分入库 / 已完成
- 点击切换筛选条件
- 调用 `/purchase/list` 接口，带 status 参数

#### 采购单列表

- 每项显示：单号、供应商、仓库、状态、时间、品项数/入库进度、金额
- 状态标签：待入库（橙）/ 部分入库（蓝）/ 已完成（绿）
- 点击列表项 → 跳转采购详情

#### 下拉刷新

- 下拉刷新重新加载列表

### 2.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 列表为空 | 显示空状态"暂无采购记录" |
| 网络错误 | 显示错误页，点击重试 |
| 状态加载中 | 显示骨架屏 |

### 2.6 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /inventory/home | 点击"采购" | /inventory/purchase-list |
| /inventory/purchase-list | 点击列表项 | /inventory/purchase/:id |
| /inventory/purchase-list | 点击顶部返回 | /inventory/home |
| /inventory/purchase/:id | 点击"入库" | /inventory/purchase-inbound/:id |

---

## 三、采购单状态详解

```
pending（待入库）
    ↓ 部分商品入库
partial（部分入库）
    ↓ 所有商品入库完成
completed（已完成）
```

| 状态 | 说明 | 可执行操作 |
|------|------|-----------|
| pending | 等待入库 | 入库 |
| partial | 部分入库（分批）| 继续入库 |
| completed | 全部入库完成 | 查看详情 |

---

## 四、模块数据流

```
采购列表 → 采购详情 → 采购入库（扫码） → 入库确认 → 更新库存

API 调用序列：
1. GET  /purchase/list             → 获取采购列表（支持 status 筛选）
2. GET  /purchase/:id             → 获取采购详情
3. POST /purchase/:id/inbound      → 采购入库
```

---

## 五、接口清单

> **注意**：金额字段单位为分（cent），非元。数量字段为整数。

| 页面 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 采购列表 | `/purchase/list` | GET | 采购列表（**筛选参数**：支持 `states[]` 状态筛选、**`creatorIDs`** 创建人筛选、排序 `orderBy`、分页 `offset`/`limit`）|
| 采购详情 | `/purchase/detail` | GET | 采购单详情 [urlKey: /purchase/detail?id={id}, GET] |
| 采购入库 | `/purchase/into-warehouse` | POST | 采购入库 [urlKey: /purchase/into-warehouse, POST, 参数：purchaseID, warehouseID, products[], remarks] **注意**：仅限 `state=1`（待入库）的采购单可入库 |
| 采购新增 | `/purchase/add` | POST | 根据采购订单新增采购入库单 [urlKey: /purchase/add, POST, 参数：purchaseOrderID, warehouseID, products[], isChangeCostPrice] |

---

## 六、状态流转

### 6.1 采购入库单状态（PurchaseState）

> 源码：`purchase-types.dart:15`，对照 `z1-mid/src/types/purchase-types.ts:28`。字段名 `state`。

| 值 | key | 中文 |
|----|-----|------|
| 1 | normal | 正常（待入库） |
| 2 | draft | 草稿 |
| 3 | pending | 待审核 |

### 6.2 采购订单状态（PurchaseOrderStatus）

> 源码：`z1-mid/src/types/purchase-order-types.ts:12`。字段名 `status`。

| 值 | 中文 |
|----|------|
| 1 | 草稿 |
| 2 | 待审核 |
| 3 | 已拒绝 |
| 4 | 已审核 |
| 5 | 已结束 |
| 6 | 已关闭 |
| 7 | 已取消 |

### 6.3 状态流转图

```
采购订单流程：
[1 草稿] ─DraftToUnaudit─→ [2 待审核]
                                │
                                ├─AuditPurchaseOrder──→ [4 已审核]
                                │                          │
                                │                          ├─ClosePurchaseOrder→ [6 已关闭]
                                │                          │
                                │                          ↓
                                │                     [5 已结束]
                                │
                                └─RejectPurchaseOrder─→ [3 已拒绝]

任意状态 ─CancelPurchaseOrder─→ [7 已取消]

采购入库单流程：
[2 草稿] → [3 待审核] ─审核通过─→ [1 正常（可入库）]
                                       │
                              POST /purchase/into-warehouse
                                       │
                                       ↓
                                  库存增加
```

> ⚠️ 仅 `state=1`（正常/待入库）的采购单可执行 `/purchase/into-warehouse` 入库。

---

## 七、模块关联

```
┌────────────────────────────────────────────────────────────┐
│                  采购模块关联                              │
├────────────────────────────────────────────────────────────┤
│                                                            │
│   库存首页 (inventory) ──→ 采购单列表                       │
│                              │                              │
│                       点击列表项                            │
│                              ↓                              │
│                         采购单详情 ──"入库"──→ 入库操作页    │
│                              │                              │
│                              │                              │
│                              ↓                              │
│                         审批中心（采购审批走                │
│                         /purchase-order/unaudit-to-audit）│
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 7.1 模块跳转

| 来源 | 触发 | 目标 | 来源代码 |
|------|------|------|---------|
| `/inventory` | 点击"采购管理"卡片 | `/inventory/purchase-list` | `inventory_home_page.dart:38` |
| `/inventory/purchase-list` | 点击采购单列表项 | `/inventory/purchase/:id` | `purchase_list_page.dart:342` |
| `/inventory/purchase/:id` | 点击"入库"按钮 | `/inventory/purchase-inbound/:id` | `purchase_detail_page.dart:252` |
| 审批中心 | 采购审批通过 | （后端处理）| 调 `/purchase-order/unaudit-to-audit` |

### 7.2 数据共享

| 数据 | 来源 | 消费者 |
|------|------|--------|
| `purchaseID` | 采购列表 | 采购详情 / 入库操作 |
| `warehouseID` | 当前职员所属仓库 | 入库接口 |
| `state` | 采购单 | 决定是否可入库 |

---

## 八、待确认事项

1. 采购入库的扫码流程细节
2. 部分入库的精确数量控制
3. 采购单与供应商结算的流程