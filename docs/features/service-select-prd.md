# 服务选择 · 产品文档

> **模块**：零售开单 - 服务选择
> **版本**：v1.0
> **日期**：2026-05-24
> **状态**：待开发
> **依据**：z1-pwa SelectService 组件分析

> **⚠️ 类型唯一真实源**：API 字段定义以 `lib/types/api/` 为准（相关：service-types.dart）。本 PRD 不复制具体字段名/类型。

---

## 〇、嵌入路径

本模块**无独立路由**，作为子组件嵌入以下父级页面：

| 父级路径 | 嵌入位置 | 触发方式 |
|---------|---------|---------|
| `/home/retail/product` | 服务 Tab | 切换 Tab 后默认显示 |

详见 `product-service-select-prd.md`（父级开单页设计）与 `retail-detail-prd.md` 第十一节模块关联。

---

## 一、产品概述

### 1.1 业务背景

门店零售开单时，除了销售商品，还可能涉及服务项目（如：刻字、清洗、保养、维修等）。服务选择模块提供服务的快速查找和选择。

### 1.2 核心价值

| 价值 | 说明 |
|------|------|
| **快速定位** | 通过分类快速找到目标服务 |
| **支持搜索** | 支持服务名称关键词搜索 |
| **灵活选择** | 支持单选和多选模式 |

---

## 二、用户场景

### 场景1：按分类选择服务

**用户**：门店店员
**场景**：顾客需要刻字服务
**流程**：
1. 点击「服务」Tab
2. 选择「刻字」分类
3. 查看该分类下的服务列表
4. 选择具体服务

### 场景2：搜索服务

**用户**：门店店员
**场景**：知道服务名称
**流程**：
1. 在搜索框输入服务名称
2. 系统返回匹配的服务列表
3. 选择服务

### 场景3：多选服务

**用户**：门店店员
**场景**：顾客需要多个服务（刻字+清洗）
**流程**：
1. 开启多选模式
2. 依次选择多个服务
3. 确认提交

---

## 三、页面结构

### 3.1 布局

```
┌──────────────────────────────────┐
│ ← 选择服务              [确定]   │
├──────────────────────────────────┤
│ [商品] [服务] [非标品]           │ ← Tab 切换
├──────────────────────────────────┤
│ [🔍 搜索服务名称]     [📷]      │ ← 搜索栏
├──────────────────────────────────┤
│ ┌──────┬─────────────────────┐  │
│ │ 分类  │                     │  │
│ │      │     服务列表          │  │
│ │ 刻字  │                     │  │
│ │ 清洗  │  ┌────────────────┐ │  │
│ │ 保养  │  │ 黄金刻字       │ │  │
│ │ 维修  │  │ ¥88           │ │  │
│ │      │  └────────────────┘ │  │
│ │      │  ┌────────────────┐ │  │
│ │      │  │ 银饰刻字       │ │  │
│ │      │  │ ¥58           │ │  │
│ │      │  └────────────────┘ │  │
│ └──────┴─────────────────────┘  │
└──────────────────────────────────┘
```

---

## 四、接口实现

### 4.1 获取服务分类

> ⚠️ 服务使用**进销存分类**（不是商城分类），接口 `GET /category/list?type=7`。

### 4.2 获取服务列表

接口 `GET /serve/list`，关键参数：

- `cateID`：分类 ID
- `states: [1]`：仅启用状态（z1-pwa `mobile/SelectService.tsx:120,135,162,172`）
- `isGoods`：`1=绑定序列号 / 2=不绑定`，用于按服务是否绑定具体货品过滤
- `listingStatuses: [1]`、`mallThirdCate`：商城上架场景额外限制（`SelectService.tsx:96-99`）
- `keyword`：搜索关键词

数量统计接口 `GET /serve/count`，参数同上但不带 limit/offset。

> 参数与响应字段类型见 `service-types.dart`。

---

## 五、组件设计

### 5.1 组件清单

| 组件 | 说明 |
|------|------|
| `ServiceSelectPanel` | 服务选择面板 |
| `ServiceCategorySidebar` | 服务分类侧边栏 |
| `ServiceList` | 服务列表 |
| `ServiceSearchBar` | 服务搜索栏 |

### 5.2 关键状态

参考 z1-pwa `mobile/SelectService.tsx`：

- `selectedCateId`：当前选中的分类 ID
- `serviceList` / `serviceCount`：当前分类下的服务和总数
- `selectedServices`：已选服务集合（多选模式）
- `keyword`：搜索关键词
- `maxSelection`：最大选择数（多选模式，由调用方传入）
- `filterOutServiceHasSerial`：是否过滤绑定序列号的服务（默认 `true`）

---

## 六、核心交互逻辑

### 6.1 分类与列表加载

- 进入页面 → 默认选中首个分类 → 加载该分类下的服务列表与数量
- 切换分类 → 重新加载列表（`/serve/list` + `/serve/count`）
- 搜索：z1-pwa Web 端使用回车手动触发，Flutter 端建议沿用按需触发以避免频繁请求

### 6.2 选择行为

- **单选模式**：点击服务 → 立即返回结果给上游
- **多选模式**：
  - 点击服务 → 加入 `selectedServices`
  - 已选服务再次点击 → **取消选择**（filter 移除），不是数量+1（`mobile/SelectService.tsx:264-273`）
  - 达到 `maxSelection` 上限：未选项加 `serviceItemDisabled` 样式且禁用点击（`mobile/SelectService.tsx:441-454`）

### 6.3 服务数量

- 服务**数量固定为 1**：z1-pwa 表格列写死 `render: () => 1`（`Sales/CreateOrder/SelectService.tsx:108-111`）
- 同一服务多次添加：通过 `key` 加随机数支持作为多条记录添加（`Sales/CreateOrder/SelectService.tsx:149`）

### 6.4 序列号过滤

- `filterOutServiceHasSerial=true`（默认）：强制传 `isGoods=2`（不绑定），过滤掉需要绑定具体序列号的服务（`mobile/SelectService.tsx:122-123,135-136,162,173`）
- 这类服务通常用于以旧换新等需要单独绑定流程的场景

---

## 七、状态流转

服务选择本身无状态机（不像订单/审批）。涉及到的服务**自身状态**：

| 字段 | 含义 | 取值 |
|------|------|------|
| `state` | 启用/停用 | `1=启用 / 0=停用`（列表只取启用） |
| `listingStatus` | 上架状态 | `1=上架 / 0=下架`（商城场景过滤） |
| `isGoods` | 是否绑定序列号 | `1=绑定 / 2=不绑定` |

---

## 八、异常/边界情况

| 场景 | 处理 | 来源 |
|------|------|------|
| 接口失败 | z1-pwa 仅 `console.error` 后 return，无 retry UI | `SelectService.tsx:215-220` |
| 草稿详情接口失败 | 走全局 `errHandler` | `Sales/CreateOrder/SelectService.tsx:87` |
| `serveCount < 0` | 直接置空列表，无错误提示 | `mobile/SelectService.tsx:127-130` |
| 分类与服务均空（加载完成） | 显示空状态图（`no-data.png`） | `mobile/SelectService.tsx:410-411` |
| 搜索无结果 | 显示空状态图 | `mobile/SelectService.tsx:490-494` |
| 加载中 | 显示 `loading` 占位 | `SelectService.tsx:175` |
| 价格 null/undefined | 兜底为 0（`item.cent || 0`），负数无拦截 | `mobile/SelectService.tsx:252,482` |
| 赠品模式价格异常 | 过滤 `costCent` 必须 `>= 0` | `mobile/SelectService.tsx:145-146,179-181` |
| 无 token（未登录） | `useEffect` 直接 return；展示 `<Empty description="可能需要重新登录" />` | `SelectService.tsx:74-77,229-233` |
| 服务的 `cateID` 在分类列表找不到 | `console.warn` + `throw new Error('数据错误')` | `SelectService.tsx:229-233` |
| 多选超限 | `handleSelectService` 直接 return；UI 禁用未选项 | `mobile/SelectService.tsx:73,270-272,441-454` |

---

## 九、模块关联

```
开单页（retail_product_page） → 服务 Tab → 服务分类侧栏 → 服务列表
                                                              ↓
                                                          加入购物车
                                                              ↓
                                                       订单确认页
```

| 来源模块 | 触发 | 目标 | 说明 |
|---------|------|------|------|
| 零售开单 | 切到服务 Tab | 服务选择 | 共享购物车，与商品 Tab 数据隔离 |
| 商品 SKU（hasSerial=yes） | 自动附加默认服务 | 服务选择（隐式） | 系统设置 `serviceIdSalesProductDefaultAdded` 自动加入 `serviceGifts`（`SelectProduct.tsx:492-533`）|
| 服务选择 | 加入购物车 | 订单确认 | 序列号绑定的服务在订单提交时需补 `pSN/sn/goodsID` |

---

## 十、待验证接口

| 接口 | 说明 | 状态 |
|------|------|------|
| `GET /serve/list` | 服务列表 | ✅ 已验证 |
| `GET /serve/count` | 服务数量 | ✅ 已验证 |
| `GET /category/list?type=7` | 服务分类 | ✅ 已验证 |

---

## 十一、注意事项

1. **分类体系**：服务使用进销存分类（`type=7`），不是商城分类
2. **过滤有序列号的服务**：通过 `isGoods` 参数过滤，移动端默认 `filterOutServiceHasSerial=true`
3. **搜索支持关键词匹配**，建议手动触发（参考 z1-pwa）
4. **多选模式**：需设置 `maxSelection` 限制最大选择数
5. **服务数量固定为 1**：同一服务需多次添加时按多条记录处理

---

> 上次更新：2026-05-28（补充交互/异常边界/模块关联，依据 z1-pwa 源码）