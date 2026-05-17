# 库存管理首页 · 详细 PRD

> **模块**：库存管理（首页）
> **版本**：v1.0
> **日期**：2026-05-17
> **状态**：初稿
> **依据**：feature-list.md

---

## 一、页面路径总览

```
/inventory/home         → 库存管理首页
         ↓
         ├── 盘库 → /inventory/stocktaking
         ├── 调拨 → /inventory/transfer
         ├── 采购 → /inventory/purchase-list
         └── 查询 → /inventory/serial-search
```

---

## 二、页面：库存管理首页

### 2.1 路由

```
路径：/inventory/home
名称：库存管理
父级：首页（/home）→ 点击"库存管理"卡片进入
```

### 2.2 基本布局

```
┌──────────────────────────────────┐
│ ← 库存管理                       │
├──────────────────────────────────┤
│                                  │
│  ┌────────────┐  ┌────────────┐  │
│  │  📦        │  │  🔄        │  │
│  │  盘库      │  │  调拨      │  │
│  │            │  │            │  │
│  │  扫码盘点  │  │  调拨出库  │  │
│  └────────────┘  └────────────┘  │
│                                  │
│  ┌────────────┐  ┌────────────┐  │
│  │  🛒        │  │  🔍        │  │
│  │  采购      │  │  序列号查询│  │
│  │            │  │            │  │
│  │  采购入库  │  │  扫码查询  │  │
│  └────────────┘  └────────────┘  │
│                                  │
└──────────────────────────────────┘
```

### 2.3 核心交互逻辑

#### 功能卡片

- 2x2 网格布局，4个功能入口
- 每个卡片包含：图标、名称、描述
- 点击跳转到对应模块列表页

#### 功能说明

| 功能 | 图标 | 颜色 | 说明 | 跳转路径 |
|------|------|------|------|----------|
| 盘库 | cube_box | activeBlue | 扫码盘点商品 | /inventory/stocktaking |
| 调拨 | arrow_right_arrow_left | activeGreen | 门店间调拨 | /inventory/transfer |
| 采购 | cart | activeOrange | 采购单入库 | /inventory/purchase-list |
| 序列号查询 | barcode | 紫色(#AF52DE) | 扫码查库存 | /inventory/serial-search |

#### 卡片样式

- 白色背景，圆角 16px
- 轻微阴影
- 卡片内图标用浅色背景圆形包裹

### 2.4 异常/边界情况

| 场景 | 处理 |
|------|------|
| 网络错误 | 显示错误提示，可重试 |
| 模块暂不可用 | 显示"功能开发中"提示（占位符）|

### 2.5 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /home | 点击"库存管理"卡片 | /inventory/home |
| /inventory/home | 点击"盘库"卡片 | /inventory/stocktaking |
| /inventory/home | 点击"调拨"卡片 | /inventory/transfer |
| /inventory/home | 点击"采购"卡片 | /inventory/purchase-list |
| /inventory/home | 点击"序列号查询"卡片 | /inventory/serial-search |
| /inventory/home | 点击顶部返回 | /home |

---

## 三、子模块入口

```
库存管理首页
├── 盘库
│     ├── 盘库列表 → /inventory/stocktaking
│     ├── 新建盘库 → /inventory/stocktaking/add
│     └── 盘库详情 → /inventory/stocktaking/:id
│
├── 调拨
│     ├── 调拨列表 → /inventory/transfer
│     ├── 新建调拨 → /inventory/transfer/add
│     └── 调拨详情 → /inventory/transfer/:id
│
├── 采购
│     ├── 采购列表 → /inventory/purchase-list
│     ├── 采购详情 → /inventory/purchase/:id
│     └── 采购入库 → /inventory/purchase-inbound/:id
│
└── 查询
      └── 序列号查询 → /inventory/serial-search
```

---

## 四、接口清单

> 本页为纯展示页，无直接 API 调用
> 子模块各自的接口见对应 PRD 文档

| 页面 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 盘库列表 | `/stock-taking/list` | GET | 盘库单列表 |
| 调拨列表 | `/transfer/list` | GET | 调拨单列表 |
| 采购列表 | `/purchase/list` | GET | 采购单列表 |
| 仓库列表 | `/warehouse/list-base` | GET | 仓库列表（各子模块用）|

---

## 五、待确认事项

1. 是否需要显示各模块的快捷统计（如待盘数量、待发货数量）
2. 是否需要显示红点/数字角标表示待处理数量