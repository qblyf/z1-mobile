# 调拨模块 · 详细 PRD（列表页补充）

> **模块**：库存管理（调拨子模块）
> **版本**：v1.0
> **日期**：2026-05-17
> **状态**：初稿
> **依据**：feature-list.md + api-endpoints.dart

> **⚠️ 类型唯一真实源**：API 字段定义以 `lib/types/api/` 为准（相关：transfer-types.dart）。本 PRD 不复制具体字段名/类型。

---

## 一、页面路径总览

```
/inventory/transfer         → 调拨列表
        ↓
/inventory/transfer/add     → 新建调拨
        ↓
/inventory/transfer/:id      → 调拨详情
```

> **注意**：新建调拨和调拨详情的文档已有，本文档补充调拨列表页面。

---

## 二、页面 1：调拨列表

### 2.1 路由

```
路径：/inventory/transfer
名称：调拨列表
父级：库存管理（/inventory/home）
```

### 2.2 基本布局

```
┌──────────────────────────────────┐
│ ← 调拨                           │
├──────────────────────────────────┤
│                                  │
│  状态筛选：                      │
│  [全部] [待发货] [待入库] [已完成] │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 调拨单号：DB202605150001   │  │
│  │ 源仓库：广州天河店         │  │
│  │ 目标仓库：深圳南山店       │  │
│  │ 状态：[待发货]            │  │
│  │ 时间：2026-05-15 10:30    │  │
│  │ 品项：5  数量：12         │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 调拨单号：DB202605140002   │  │
│  │ 源仓库：深圳南山店         │  │
│  │ 目标仓库：广州天河店       │  │
│  │ 状态：[已完成] ✓          │  │
│  │ 时间：2026-05-14 09:00    │  │
│  │ 品项：3  数量：8          │  │
│  └────────────────────────────┘  │
│                                  │
│  [新建调拨]                      │
│                                  │
└──────────────────────────────────┘
```

### 2.3 核心交互逻辑

#### 状态筛选

- 四个 Tab：全部 / 待发货 / 待入库 / 已完成
- 点击切换筛选条件
- 调用 `/transfer/list` 接口，带 status 参数

#### 调拨单列表

- 每项显示：单号、源仓库、目标仓库、状态、时间、品项数/总数量
- 状态标签：待发货（橙）/ 待入库（蓝）/ 已完成（绿）
- 点击列表项 → 跳转调拨详情

#### 新建调拨

- 点击底部"新建调拨"按钮
- 跳转 `/inventory/transfer/add`

#### 下拉刷新

- 下拉刷新重新加载列表

### 2.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 列表为空 | 显示空状态"暂无调拨记录" + "新建调拨"引导 |
| 网络错误 | 显示错误页，点击重试 |
| 状态加载中 | 显示骨架屏 |

### 2.6 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /inventory/home | 点击"调拨" | /inventory/transfer |
| /inventory/transfer | 点击"新建调拨" | /inventory/transfer/add |
| /inventory/transfer | 点击列表项 | /inventory/transfer/:id |
| /inventory/transfer | 点击顶部返回 | /inventory/home |

---

## 三、调拨单状态详解

```
pending（待发货）
    ↓ 用户点击"确认发货"
shipping（待入库）
    ↓ 目标仓库确认收货
completed（已完成）
```

| 状态 | 说明 | 可执行操作 |
|------|------|-----------|
| pending | 调拨单创建，等待发货 | 发货 |
| shipping | 已发货，等待目标仓库入库 | 查看物流 |
| completed | 调拨完成 | 查看详情 |

---

## 四、模块数据流

```
调拨列表 → 新建调拨（选择仓库） → 扫码出库 → 填写调拨数量 → 提交 → 调拨详情

API 调用序列：
1. GET  /transfer/list            → 获取调拨列表（支持 status 筛选）
2. GET  /warehouse/list-base     → 获取仓库列表（新建调拨用）
3. POST /transfer/add             → 创建调拨单
4. GET  /transfer/:id              → 获取调拨详情
5. POST /transfer/:id/ship        → 确认发货
6. POST /transfer/:id/receive     → 确认入库
```

---

## 五、接口清单

> **注意**：金额字段单位为分（cent），非元。数量字段为整数。

| 页面 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 调拨列表 | `/transfer/list` | GET | 调拨列表（支持 status 筛选，参数：status, limit, offset）|
| 新建调拨 | `/warehouse/list-base` | GET | 仓库列表（选择仓库用，**过滤条件**：可通过 `state=1` 过滤禁用仓库，仅返回启用状态的仓库）|
| 新建调拨 | `/transfer/add` | POST | 创建调拨单 [urlKey: /transfer/add, POST, 参数：outWarehouseID, inWarehouseID, products[], type] **注意**：请求体中商品字段为 `products` 而非 `goodsInfo` |
| 新建调拨 | `/transfer-lock/shipping` | POST | 确认发货 [urlKey: /transfer-lock/shipping, POST, 参数：transferID, inWarehouseID] **注意**：`inWarehouseID` 为目标仓库 ID，发货时必传 |
| 调拨详情 | `/transfer/detail` | GET | 调拨单详情（参数：id） |
| 入库确认 | `/transfer-lock/received` | POST | 调入仓收到货后确认入库（参数：transferID）|

---

## 六、状态流转

### 6.1 TransferState 枚举

> 源码：`transfer-types.dart:35`。字段名 `status`。

| 值 | key | 中文 |
|----|-----|------|
| 1 | pending | 待审核 |
| 2 | draft | 草稿 |
| 5 | approved | 已审核 |
| 9 | terminated | 已终止 |
| 10 | pendingConfirm | 待确认 |
| 11 | confirmed | 已确认 |
| 12 | shipped | 已发货 |

### 6.2 状态流转图

```
[2 草稿] ──提交审核──→ [1 待审核]
                          │
                          ├─审核通过─→ [5 已审核] ──发货─→ [12 已发货]
                          │                                  │
                          │                              入库方确认
                          │                                  │
                          │                                  ↓
                          │                             [11 已确认]
                          │
                          └─审核拒绝─→ [9 已终止]

[10 待确认] —— 仓位调拨场景中目标仓库收货前的中间态
```

> ⚠️ 调拨状态触发接口在 z1-mid 源码中未集中定义，部分推断自字段值（如 `/transfer-lock/shipping` 触发状态 12）。完整流转需后端确认。

---

## 七、模块关联

```
┌────────────────────────────────────────────────────────┐
│                   调拨模块关联                          │
├────────────────────────────────────────────────────────┤
│                                                        │
│   库存首页 (inventory) ──→ 调拨单列表                   │
│                              │                          │
│                              ├──"新增调拨"按钮──→ 新建调拨页
│                              │                          │
│                              └──点击列表项───────→ 调拨详情
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 7.1 模块跳转

| 来源 | 触发 | 目标 | 来源代码 |
|------|------|------|---------|
| `/inventory` | 点击"调拨管理"卡片 | `/inventory/transfer` | `inventory_home_page.dart:32` |
| `/inventory/transfer` | 点击"新增调拨"按钮 | `/inventory/transfer/add` | `transfer_list_page.dart:65` |
| `/inventory/transfer` | 点击调拨单列表项 | `/inventory/transfer/:id` | `transfer_list_page.dart:201` |

### 7.2 数据共享

| 数据 | 来源 | 消费者 |
|------|------|--------|
| `outWarehouseID` / `inWarehouseID` | 新建调拨页 | `/transfer/add` 接口 |
| `transferID` | 调拨详情 | 发货确认 / 入库确认 |
| `state` | 调拨单 | 决定当前可执行的操作（提交/发货/确认） |

---

## 八、待确认事项

1. 调拨单的审核流程（是否需要审批）
2. 调拨出库的扫码流程细节
3. 部分调拨（部分发货/部分入库）的处理逻辑