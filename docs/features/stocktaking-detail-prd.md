# 盘库模块 · 详细 PRD

> **模块**：盘库（库存管理子模块）
> **版本**：v1.0
> **日期**：2026-05-16
> **状态**：初稿
> **依据**：feature-list.md + prd.md + api-spec.md

---

## 一、页面路径总览

```
/inventory/stocktaking          → 盘库列表
        ↓
/inventory/stocktaking/add     → 新建盘库
        ↓
/inventory/stocktaking/:id     → 盘库详情/操作
```

---

## 二、页面 1：盘库列表

### 2.1 路由

```
路径：/inventory/stocktaking
名称：盘库列表
父级：库存管理（/inventory/home）
```

### 2.2 基本布局

```
┌──────────────────────────────────┐
│ ← 盘库                          │
├──────────────────────────────────┤
│                                  │
│  状态筛选：                      │
│  [全部] [待盘] [进行中] [已完成]  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 盘库单号：PK202605150001   │  │
│  │ 门店：广州天河店            │  │
│  │ 状态：[待盘]               │  │
│  │ 时间：2026-05-15 10:30    │  │
│  │ 品项：12  盘盈：2  盘亏：0  │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 盘库单号：PK202605140002   │  │
│  │ 门店：深圳南山店            │  │
│  │ 状态：[已完成] ✓           │  │
│  │ 时间：2026-05-14 09:00    │  │
│  │ 品项：8   盘盈：0  盘亏：1  │  │
│  └────────────────────────────┘  │
│                                  │
│  [新建盘库]                      │
│                                  │
└──────────────────────────────────┘
```

### 2.3 核心交互逻辑

#### 状态筛选

- 四个 Tab：全部 / 待盘 / 进行中 / 已完成
- 点击切换筛选条件
- 调用 `/stock-taking/list` 接口，带 status 参数

#### 盘库单列表

- 每项显示：单号、门店、状态、时间、品项统计
- 状态标签：待盘（橙）/ 进行中（蓝）/ 已完成（绿）
- 点击列表项 → 跳转盘库详情

#### 新建盘库

- 点击底部"新建盘库"按钮
- 跳转 `/inventory/stocktaking/add`

#### 下拉刷新

- 下拉刷新重新加载列表

### 2.4 字段说明

#### 盘库单列表项（StockTakingSummary）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 盘库单 ID |
| code | string | 盘库单号 |
| warehouseId | string | 仓库 ID |
| warehouseName | string | 仓库名称 |
| status | enum | 状态：`pending`/`in_progress`/`submitted`/`approved` |
| totalItems | int | 总品项数 |
| profitItems | int | 盘盈品项数 |
| lossItems | int | 盘亏品项数 |
| operatorId | string | 操作员 ID |
| startedAt | datetime | 开始时间 |
| submittedAt | datetime | 提交时间（可选）|
| approvedAt | datetime | 审核时间（可选）|

### 2.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 列表为空 | 显示空状态"暂无盘库记录" + "新建盘库"引导 |
| 网络错误 | 显示错误页，点击重试 |
| 状态加载中 | 显示骨架屏 |

### 2.6 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /inventory/home | 点击"盘库" | /inventory/stocktaking |
| /inventory/stocktaking | 点击"新建盘库" | /inventory/stocktaking/add |
| /inventory/stocktaking | 点击列表项 | /inventory/stocktaking/:id |
| /inventory/stocktaking | 点击顶部返回 | /inventory/home |

---

## 三、页面 2：新建盘库

### 3.1 路由

```
路径：/inventory/stocktaking/add
名称：新建盘库
```

### 3.2 基本布局

```
┌──────────────────────────────────┐
│ ← 新建盘库                       │
├──────────────────────────────────┤
│                                  │
│  仓库选择 *                      │
│  ┌────────────────────────────┐  │
│  │ [请选择仓库 ▼]            │  │
│  └────────────────────────────┘  │
│                                  │
│  扫描商品                        │
│  ┌────────────────────────────┐  │
│  │ [🔍 点击扫描商品条码]      │  │
│  └────────────────────────────┘  │
│                                  │
│  盘点清单                        │
│  ┌────────────────────────────┐  │
│  │ 📿 足金凤尾纹手镯 30g      │  │
│  │ 系统：50  实际：[___]      │  │
│  │ ├─ 盘点  🔄 删除            │  │
│  ├────────────────────────────┤  │
│  │ 💎 50分钻戒 D色 VS1         │  │
│  │ 系统：20  实际：[___]      │  │
│  │ ├─ 盘点  🔄 删除            │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │       [提交盘库]           │  │
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

### 3.3 核心交互逻辑

#### 选择仓库

- 点击下拉选择仓库
- 调用 `/warehouse/list-base` 获取仓库列表
- 必选，不选无法开始盘点

#### 扫码添加商品

- 点击"扫描商品条码"按钮
- 调起相机扫描商品条码
- 调用 `/product-stock-by-code` 查找商品
- 找到商品 → 添加到盘点清单，初始实际数量为空
- 未找到 → Toast "商品不存在"

#### 填写实际数量

- 每个盘点项显示系统库存数量
- 点击"实际"输入框，弹出数字键盘
- 输入实际盘点数量
- 自动计算差异：差异 = 实际数量 - 系统数量
- 盘盈（差 > 0）/ 盘亏（差 < 0）/ 持平（差 = 0）

#### 编辑/删除盘点项

- 点击"盘点"按钮 → 展开编辑实际数量
- 点击"删除"按钮 → 移除该盘点项

#### 提交盘库

- 调用 `POST /stock-taking/add` 创建盘库单
- 携带：warehouseId、items[{productId, barcode, systemQty, actualQty}]
- 成功 → 跳转盘库详情 `/inventory/stocktaking/:id`
- 失败 → 显示错误提示

### 3.4 字段说明

#### 盘库项（StockTakingItem）

| 字段 | 类型 | 说明 |
|------|------|------|
| productId | string | 商品 ID |
| productName | string | 商品名称 |
| barcode | string | 条码 |
| skuId | string | SKU ID（可选）|
| systemQty | int | 系统库存数量 |
| actualQty | int | 实际盘点数量 |
| diff | int | 差异 = actualQty - systemQty |

#### 新建盘库请求（AddStockTakingRequest）

| 字段 | 类型 | 说明 |
|------|------|------|
| warehouseId | string | 仓库 ID |
| items | List<StockTakingItem> | 盘点明细 |

### 3.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 未选择仓库 | "提交盘库"按钮禁用 |
| 扫码商品不存在 | Toast "商品不存在，请检查条码" |
| 商品已存在盘点清单 | Toast "该商品已在清单中" |
| 实际数量未填 | 提交时提示"请填写所有商品的盘点数量" |
| 盘点清单为空 | 提交按钮禁用 |
| 网络错误 | 显示错误提示，可重试 |

### 3.6 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /inventory/stocktaking | 点击"新建盘库" | /inventory/stocktaking/add |
| /inventory/stocktaking/add | 扫码成功 | 添加商品到清单（当前页）|
| /inventory/stocktaking/add | 提交成功 | /inventory/stocktaking/:id |
| /inventory/stocktaking/add | 点击顶部返回 | /inventory/stocktaking |

---

## 四、页面 3：盘库详情/操作

### 4.1 路由

```
路径：/inventory/stocktaking/:id
名称：盘库详情
参数：stockTakingId
```

### 4.2 基本布局

```
┌──────────────────────────────────┐
│ ← 盘库详情          [⋯]          │
├──────────────────────────────────┤
│                                  │
│  状态：[进行中]                  │  ← 盘库单状态
│                                  │
│  仓库：广州天河店                │
│  开始时间：2026-05-15 10:30     │
│  操作员：张三                    │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 盘点进度                   │  │
│  │ ████████░░ 8/12 品项      │  │
│  │ 盘盈：2  盘亏：0  持平：6  │  │
│  └────────────────────────────┘  │
│                                  │
│  商品清单                        │
│  ┌────────────────────────────┐  │
│  │ 📿 足金凤尾纹手镯          │  │
│  │ 系统：50  实际：52  [+2]   │  │  ← 绿色=盘盈
│  │ █ 盘盈                    │  │
│  ├────────────────────────────┤  │
│  │ 💎 50分钻戒 D色 VS1        │  │
│  │ 系统：20  实际：18  [-2]   │  │  ← 红色=盘亏
│  │ █ 盘亏                    │  │
│  ├────────────────────────────┤  │
│  │ 📿 S925 满天星项链          │  │
│  │ 系统：15  实际：15  [0]    │  │
│  │ █ 持平                    │  │
│  └────────────────────────────┘  │
│                                  │
│  [继续盘点]    [提交审核]        │
│                                  │
└──────────────────────────────────┘
```

### 4.3 核心交互逻辑

#### 盘库单状态

- `pending`（待盘）：刚创建，未开始
- `in_progress`（进行中）：正在盘点
- `submitted`（已提交）：已提交，等待审核
- `approved`（已完成）：审核通过

#### 进度展示

- 显示：总品项数、已盘品项数、盘盈/盘亏/持平 统计
- 进度条可视化

#### 商品清单

- 列出所有盘点商品
- 每项显示：系统数量、实际数量、差异
- 差异着色：绿色（盘盈）/ 红色（盘亏）/ 灰色（持平）

#### 继续盘点

- 点击"继续盘点"
- 跳转到扫码页面，继续添加商品
- 已盘点项可编辑实际数量

#### 提交审核

- 点击"提交审核"
- 调用 `POST /stock-taking/:id/submit`
- 状态变为 `submitted`
- 等待审核（审核不在移动端操作，由后台或店长完成）

### 4.4 字段说明

#### 盘库单详情（StockTaking）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 盘库单 ID |
| code | string | 盘库单号 |
| warehouseId | string | 仓库 ID |
| warehouseName | string | 仓库名称 |
| status | enum | 状态 |
| totalItems | int | 总品项数 |
| checkedItems | int | 已盘点品项数 |
| profitItems | int | 盘盈品项数 |
| lossItems | int | 盘亏品项数 |
| equalItems | int | 持平品项数 |
| operatorId | string | 操作员 ID |
| operatorName | string | 操作员姓名 |
| startedAt | datetime | 开始时间 |
| submittedAt | datetime | 提交时间 |
| approvedAt | datetime | 审核时间 |
| approvedBy | string | 审核人 |

#### 盘库明细项（StockTakingItem）

| 字段 | 类型 | 说明 |
|------|------|------|
| productId | string | 商品 ID |
| productName | string | 商品名称 |
| barcode | string | 条码 |
| systemQty | int | 系统库存数量 |
| actualQty | int | 实际盘点数量 |
| diff | int | 差异（actual - system）|
| status | enum | 状态：`pending`/`checked` |

### 4.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 商品未全部盘点 | 提交时提示"还有 X 个商品未盘点" |
| 网络错误 | 显示错误提示，可重试 |
| 已提交状态 | "继续盘点"和"提交审核"按钮隐藏 |
| 已审核状态 | 整个页面只读，不可编辑 |

### 4.6 跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| /inventory/stocktaking | 点击列表项 | /inventory/stocktaking/:id |
| /inventory/stocktaking/add | 提交成功（自动）| /inventory/stocktaking/:id |
| /inventory/stocktaking/:id | 点击"继续盘点" | 扫码页面（当前页刷新）|
| /inventory/stocktaking/:id | 点击顶部返回 | /inventory/stocktaking |

---

## 五、扫码流程详解

### 5.1 扫码触发

1. 点击"扫描商品条码"按钮
2. 调起相机（mobile_scanner）
3. 识别到条码后自动查询

### 5.2 条码查询

- 调用 `GET /product/barcode/:code` 或 `POST /goods/serial-search`
- 有结果 → 显示商品信息，确认添加到清单
- 无结果 → 显示"商品不存在"

### 5.3 扫码场景

| 场景 | 条码类型 | 处理 |
|------|----------|------|
| 商品选择 | EAN-13/UPC-A | 添加商品到清单 |
| 序列号查询 | 自定义 | 查询商品及进出库记录 |
| 继续盘点 | 重复扫码 | 已有项高亮+Toast"已在清单中" |

---

## 六、模块数据流

```
盘库列表 → 新建盘库（选择仓库） → 扫码添加商品 → 填写实际数量 → 提交审核 → 盘库详情

API 调用序列：
1. GET  /warehouse/list-base        → 获取仓库列表
2. GET  /stock-taking/list         → 获取盘库列表
3. POST /stock-taking/add          → 新建盘库单
4. GET  /stock-taking/:id          → 获取盘库详情
5. POST /stock-taking/:id/submit   → 提交盘库审核
6. GET  /product-stock-by-code    → 条码查商品
```

---

## 七、接口清单

> **注意**：金额字段单位为分（cent），非元。数量字段为整数。

| 页面 | 接口 | 方法 | 说明 |
|------|------|------|------|
| 盘库列表 | `/stock-taking/list` | GET | 盘库单列表（支持 status 筛选）⚠️ 注意：有性能问题，后端需优化 |
| 新建盘库 | `/warehouse/list-base` | GET | 仓库列表（选择仓库用）|
| 新建盘库 | `/product-stock-by-code` | GET | 条码查商品 |
| 新建盘库 | `POST /stock-taking/add` | POST | 创建盘库单 |
| 盘库详情 | `GET /stock-taking/:id` | GET | 盘库单详情 |
| 盘库详情 | `POST /stock-taking/:id/submit` | POST | 提交盘库审核 |

---

## 八、待确认事项

1. 盘库提交后的审核流程是在移动端还是后台完成
2. 盘盈/盘亏的阈值设置（多少以内算正常差异）
3. 离线模式下扫码盘库的处理策略