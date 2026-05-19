# 库存管理首页 · 详细 PRD

> **模块**：库存管理
> **版本**：v1.0
> **日期**：2026-05-17
> **状态**：初稿
> **依据**：feature-list.md + api-endpoints.dart + stocktaking-detail-prd.md

---

## 一、页面路径总览

```
/inventory/home           → 库存管理首页
        │
        ├── 盘库 (/inventory/stocktaking)
        │       ├── 新建盘库 (/inventory/stocktaking/add)
        │       └── 盘库详情 (/inventory/stocktaking/:id)
        │
        ├── 调拨 (/inventory/transfer)
        │       ├── 新建调拨 (/inventory/transfer/add)
        │       └── 调拨详情 (/inventory/transfer/:id)
        │
        ├── 采购 (/inventory/purchase-list)
        │       ├── 采购详情 (/inventory/purchase/:id)
        │       └── 采购入库 (/inventory/purchase-inbound/:id)
        │
        └── 序列号查询 (/inventory/serial-search)
```

---

## 二、页面 1：库存管理首页

### 2.1 路由

```
路径：/inventory/home
名称：库存管理
父级：首页（/home）
```

### 2.2 基本布局

```
┌──────────────────────────────────┐
│ ← 库存管理                        │
├──────────────────────────────────┤
│                                  │
│  库存概览                        │
│  ┌────────────────────────────┐  │
│  │  总品项：1,234             │  │
│  │  在库：1,200  出库：34     │  │
│  │  ⚠️ 预警：5                 │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌──────────┐  ┌──────────┐  │
│  │ 📦      │  │ 🔄      │  │
│  │ 盘库    │  │ 调拨    │  │
│  │ 待盘：3 │  │ 待发货：2│  │
│  └──────────┘  └──────────┘  │
│                                  │
│  ┌──────────┐  ┌──────────┐  │
│  │ 🛒      │  │ 🔍      │  │
│  │ 采购    │  │ 序列号  │  │
│  │ 待入库：1│  │ 查询    │  │
│  └──────────┘  └──────────┘  │
│                                  │
│  最近操作                        │
│  ┌────────────────────────────┐  │
│  │ 2026-05-15 盘库 PK2026... │  │
│  │ 2026-05-14 调拨 DB2026... │  │
│  │ 2026-05-13 采购 CG2026... │  │
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

### 2.3 核心交互逻辑

#### 库存概览

- 显示当前门店/仓库的整体库存状态
- 总品项数、在库数量、出库数量
- 库存预警数量（点击可跳转预警列表）

#### 功能卡片

四个功能入口，各卡片显示：

| 入口 | 图标 | 描述 | 快捷数据 |
|------|------|------|----------|
| 盘库 | 📦 | 库存盘点 | 待盘数量 |
| 调拨 | 🔄 | 库存调拨 | 待发货数量 |
| 采购 | 🛒 | 采购入库 | 待入库数量 |
| 序列号查询 | 🔍 | 序列号/条码查询 | — |

#### 最近操作

- 显示最近的 3 条库存操作记录
- 点击可跳转到对应详情页

### 2.4 字段说明

#### 库存概览（InventorySummary）

| 字段 | 类型 | 说明 |
|------|------|------|
| totalItems | int | 总品项数 |
| inStock | int | 在库数量 |
| outStock | int | 出库数量（含销售、调拨等）|
| warningCount | int | 库存预警数量 |

#### 功能入口统计（ModuleStats）

| 字段 | 类型 | 说明 |
|------|------|------|
| stocktakingPending | int | 待盘库数量 |
| transferPending | int | 待发货调拨数量 |
| purchasePending | int | 待入库采购数量 |

#### 最近操作记录（RecentOperation）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 操作记录 ID |
| type | enum | 类型：`stocktaking`/`transfer`/`purchase` |
| code | string | 单号 |
| time | int | 操作时间戳（秒）|
| status | string | 状态描述 |

### 2.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 库存概览加载失败 | 显示错误页，点击重试 |
| 功能入口统计加载失败 | 统计显示"-"，不影响功能入口 |
| 最近操作记录为空 | 隐藏"最近操作"区块 |
| 网络错误 | 显示错误提示，可重试 |

### 2.6 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /home | 点击"库存管理" | /inventory/home |
| /inventory/home | 点击"盘库"卡片 | /inventory/stocktaking |
| /inventory/home | 点击"调拨"卡片 | /inventory/transfer |
| /inventory/home | 点击"采购"卡片 | /inventory/purchase-list |
| /inventory/home | 点击"序列号查询"卡片 | /inventory/serial-search |
| /inventory/home | 点击"最近操作"项 | 对应单据详情页 |
| /inventory/home | 点击预警数量 | /inventory/warning（预留）|
| /inventory/home | 点击顶部返回 | /home |

---

## 三、模块入口详解

### 3.1 盘库入口

```
点击"盘库"卡片
    ↓
跳转 /inventory/stocktaking（盘库列表）
    ↓
    ├── 点击"新建盘库" → /inventory/stocktaking/add
    └── 点击列表项 → /inventory/stocktaking/:id
```

### 3.2 调拨入口

```
点击"调拨"卡片
    ↓
跳转 /inventory/transfer（调拨列表）
    ↓
    ├── 点击"新建调拨" → /inventory/transfer/add
    └── 点击列表项 → /inventory/transfer/:id
```

### 3.3 采购入口

```
点击"采购"卡片
    ↓
跳转 /inventory/purchase-list（采购列表）
    ↓
    ├── 点击列表项 → /inventory/purchase/:id
    │       ↓
    │   点击"入库" → /inventory/purchase-inbound/:id
    └── 点击列表项 → /inventory/purchase/:id
```

### 3.4 序列号查询入口

```
点击"序列号查询"卡片
    ↓
跳转 /inventory/serial-search（序列号查询）
    ↓
    ├── 扫码 → 查询商品信息 + 进出库记录
    └── 输入序列号 → 查询商品信息 + 进出库记录
```

---

## 四、模块数据流

```
库存管理首页 → 各功能入口 → 对应功能模块

API 调用序列：
1. GET  /inventory/summary         → 库存概览（预留，需确认接口）
2. GET  /stock-taking/list         → 盘库统计（待盘数量）
3. GET  /transfer/list             → 调拨统计（待发货数量）
4. GET  /purchase/list             → 采购统计（待入库数量）
5. GET  /inventory/recent          → 最近操作记录（预留，需确认接口）
```

---

## 五、接口清单

> **注意**：金额字段单位为分（cent），非元。数量字段为整数。

| 页面 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 库存管理首页 | `/stock-taking/list` | GET | 盘库列表（获取待盘数量，**支持分页**：参数 `limit`/`offset`）|
| 库存管理首页 | `/transfer/list` | GET | 调拨列表（获取待发货数量，参数：status, limit, offset）|
| 库存管理首页 | `/purchase/list` | GET | 采购列表（获取待入库数量，参数：states[], orderBy, offset, limit）|
| 库存管理首页 | `/warehouse/list-base` | GET | 仓库列表（确认当前仓库，**过滤条件**：可通过 `state=1` 过滤禁用仓库，仅返回启用状态的仓库）|
| 库存概览 | `/inventory/summary` | — | [缺失，后端未实现] |
| 最近操作 | `/inventory/recent` | — | [缺失，后端未实现] |

---

## 六、待确认事项

1. 库存概览接口（`/inventory/summary`）是否存在
2. 最近操作记录接口（`/inventory/recent`）是否存在
3. 各功能入口的快捷统计数据如何获取（聚合接口 or 各模块列表接口）
4. 库存预警功能和接口是否已实现