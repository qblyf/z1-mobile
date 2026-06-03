# 开单选择商品/服务页面 · 设计 PRD

> **模块**：零售开单 - 商品/服务选择
> **版本**：v1.0
> **日期**：2026-05-20
> **状态**：初稿
> **依据**：z1-pwa StoreRetail 组件分析

> **⚠️ 类型唯一真实源**：API 字段定义以 `lib/types/api/` 为准（相关：product-types.dart, service-types.dart）。本 PRD 不复制具体字段名/类型。

---

## 〇、页面路径

| 路径 | 名称 | Flutter 实现 |
|------|------|------------|
| `/home/retail/product` | 商品/服务选购（含商品 Tab、服务 Tab、购物车）| `lib/features/retail/presentation/pages/retail_product_page.dart` |

页面参数：通常通过 `extra` 传 `memberID`、`saleType`（零售/批发等）。

---

## 一、z1-pwa 组件清单整理

### 1.1 核心选择组件

| 组件 | 文件 | 功能 | 接口 |
|------|------|------|------|
| SelectProduct | `SelectProduct.tsx` | 商品选择（标品）| `getProductListByCondition`、`getSPUList`、`getStockBySPU` |
| SelectService | `SelectService.tsx` | 服务选择 | `serveList`、`serveCount` |
| SelectNonStandardGoods | `SelectNonStandardGoods.tsx` | 非标品选择 | `itemAll`、`customerGetCategory` |

### 1.2 优惠相关组件

| 组件 | 文件 | 功能 |
|------|------|------|
| SelectCoupons | `SelectCoupons.tsx` | 优惠券选择 |
| SelectCashCoupons | `SelectCashCoupons.tsx` | 代金券选择 |
| SelectRenewSubsidy | `SelectRenewSubsidy.tsx` | 换新补贴选择 |
| SelectAutoGiveaways | `SelectAutoGiveaways.tsx` | 赠品选择 |
| CashCouponsList | `CashCouponsList.tsx` | 代金券列表 |

### 1.3 辅助选择组件

| 组件 | 文件 | 功能 |
|------|------|------|
| SelectRecycleOrder | `SelectRecycleOrder.tsx` | 回收单选择（以旧换新）|
| SelectSerialFromHistoryOrder | `SelectSerialFromHistoryOrder.tsx` | 历史序列号选择 |
| SelectPayments | `SelectPayments.tsx` | 支付方式选择 |
| SelectMainProductOrderNumber | `SelectMainProductOrderNumber.tsx` | 关联主商品订单号 |
| AssociatedRecycleOrder | `AssociatedRecycleOrder.tsx` | 关联回收单 |
| AssociatedJointProductOrder | `AssociatedJointProductOrder.tsx` | 关联拼接商品订单 |
| AssociatedMainProductOrder | `AssociatedMainProductOrder.tsx` | 关联主商品订单 |

### 1.4 信息展示组件

| 组件 | 文件 | 功能 |
|------|------|------|
| ItemTypeTag | `ItemTypeTag.tsx` | 商品类型标签（标品/服务/非标）|
| NonStandardGoodInfo | `NonStandardGoodInfo.tsx` | 非标品信息展示 |
| SaleOrderEditPayInfo | `SaleOrderEditPayInfo.tsx` | 订单支付信息编辑 |
| ReturnOrderEditPayInfo | `ReturnOrderEditPayInfo.tsx` | 退货订单支付信息编辑 |
| CouponUsedLog | `CouponUsedLog.tsx` | 优惠券使用记录 |

### 1.5 数量/价格修改组件

| 组件 | 文件 | 功能 |
|------|------|------|
| ChangeQty | `ChangeQty.tsx` | 修改数量 |
| AmountInputModal | `AmountInputModal.tsx` | 金额输入弹窗 |
| InputModal | `InputModal.tsx` | 通用输入弹窗 |
| SimplePriceChange | `SimplePriceChange.tsx` | 简单改价 |

### 1.6 订单创建组件

| 组件 | 文件 | 功能 |
|------|------|------|
| CreateOrder | `CreateOrder.tsx` | 订单创建/提交（核心组件1792行）|

### 1.7 其他辅助组件

| 组件 | 文件 | 功能 |
|------|------|------|
| SelectReturnsItem | `SelectReturnsItem.tsx` | 退货商品选择 |
| SelectAssistantIdentType | `SelectAssistantIdentType.tsx` | 店员身份类型选择 |
| UploadImages | `UploadImages.tsx` | 图片上传 |
| CouponsConfirm | `CouponsConfirm.tsx` | 优惠券确认 |

---

## 二、业务流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                        零售开单流程                              │
└─────────────────────────────────────────────────────────────────┘

会员查询 → 商品/服务选择 → 优惠叠加 → 订单创建
    ↓           ↓              ↓           ↓
手机号/企微   标品/服务/非标品  优惠券/积分/补贴  序列号绑定 → 提交

┌─────────────────────────────────────────────────────────────────┐
│ 商品选择层级（SelectProduct）                                   │
├─────────────────────────────────────────────────────────────────┤
│ 分类（Cate） → SPU → SKU → 商品（Goods/序列号）                 │
│                                                                │
│ 入口：分类列表 / 搜索 / 扫码                                    │
│ 库存显示：分类/SPU/SKU/商品各级库存                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 服务选择（SelectService）                                       │
├─────────────────────────────────────────────────────────────────┤
│ 服务分类 → 服务列表                                              │
│                                                                │
│ 属性：isGoods（是否绑定序列号）                                  │
│ 过滤：filterOutServiceHasSerial（过滤有序列号的服务）            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 非标品选择（SelectNonStandardGoods）                            │
├─────────────────────────────────────────────────────────────────┤
│ SPU分类 → 唯一序列号                                            │
│                                                                │
│ 按件计价，无固定SKU                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 三、我们的开单选择页面设计

### 3.1 页面结构

```
┌──────────────────────────────────┐
│ ← 商品选购            [购物车]  │  ← 顶部导航栏
├──────────────────────────────────┤
│ [零售] [张三 金卡 ▼]             │  ← 销售类型标签 + 会员切换
├──────────────────────────────────┤
│ [商品] [服务]                    │  ← 商品/服务 Tab 切换
├──────────────────────────────────┤
│ [搜索商品名称/条码]    [扫码]    │  ← 搜索栏
├──────────────────────────────────┤
│  │                               │
│  分类    商品网格                 │  ← 主体区域
│  全部    ┌────┐ ┌────┐          │
│  黄金    │商品│ │商品│          │
│  钻石    ├────┤ ├────┤          │
│  银饰    │商品│ │商品│          │
│  ...     └────┘ └────┘          │
│  │                               │
├──────────────────────────────────┤
│ ┌────────────────────────────┐   │
│ │ 🛒 3件  ¥21,528   [去结算]  │   │  ← 购物车浮动栏
│ └────────────────────────────┘   │
└──────────────────────────────────┘
```

### 3.2 商品 Tab（SelectProduct 简化版）

#### 3.2.1 分类选择

- 左侧分类列表
- 点击分类 → 显示该分类下的 SPU 列表
- 默认显示"全部"分类

#### 3.2.2 商品网格

```
┌──────────────────────────────────┐
│ 分类选择                          │
│ ┌────┐ ┌────┐ ┌────┐            │
│ │黄金│ │钻石│ │银饰│            │
│ └────┘ └────┘ └────┘            │
│                                  │
│ 商品列表（按 SPU 分组）           │
│ ┌────────────────────────────┐  │
│ │ 🔵 黄金手镯                 │  │
│ │   库存：5  零售价：¥2800   │  │
│ │   [选择规格 ▼]              │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 🔵 钻戒 50分                │  │
│ │   库存：3  零售价：¥18500  │  │
│ │   [选择规格 ▼]              │  │
│ └────────────────────────────┘  │
└──────────────────────────────────┘
```

#### 3.2.3 SPU 选择 → SKU 弹窗

```
┌──────────────────────────────────┐
│ 选择规格                        │
├──────────────────────────────────┤
│ 足金凤尾纹手镯 30g              │
│                                  │
│ 规格：                          │
│ ┌────┐ ┌────┐ ┌────┐          │
│ │20g │ │25g │ │30g │ ← 当前    │
│ │¥2200│ │¥2700│ │¥3200│       │
│ └────┘ └────┘ └────┘          │
│                                  │
│ 库存：5                         │
│                                  │
│ [加入购物车]                     │
└──────────────────────────────────┘
```

### 3.3 服务 Tab（SelectService）

#### 3.3.1 服务分类

- 左侧服务分类列表
- 点击分类 → 显示该分类下的服务列表

#### 3.3.2 服务列表

```
┌──────────────────────────────────┐
│ 服务分类                          │
│ ┌────┐ ┌────┐ ┌────┐            │
│ │清洗│ │维修│ │定制│            │
│ └────┘ └────┘ └────┘            │
│                                  │
│ 服务列表                         │
│ ┌────────────────────────────┐  │
│ │ 🛁 珠宝清洗保养             │  │
│ │   ¥188/次                   │  │
│ │   [加入购物车]              │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 🔧 戒指改圈               │  │
│ │   ¥88/次                   │  │
│ │   [加入购物车]              │  │
│ └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 3.4 购物车弹窗

```
┌──────────────────────────────────┐
│ 购物车                    [清空]  │
├──────────────────────────────────┤
│ 商品（2件）                       │
│ ┌────────────────────────────┐  │
│ │ 📿 足金手镯 30g    ¥2800   │  │
│ │     [-] 1 [+]        [删除]│  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 💎 50分钻戒      ¥18500    │  │
│ │     [-] 1 [+]        [删除]│  │
│ └────────────────────────────┘  │
│                                  │
│ 服务（1件）                       │
│ ┌────────────────────────────┐  │
│ │ 🛁 珠宝清洗保养  ¥188      │  │
│ │     [-] 1 [+]        [删除]│  │
│ └────────────────────────────┘  │
│                                  │
├──────────────────────────────────┤
│ 合计：¥21,488      [去结算]      │
└──────────────────────────────────┘
```

---

## 四、接口清单

### 4.1 商品相关

| 接口 | 方法 | 说明 |
|------|------|------|
| `/product/select-base` | GET | 获取基础商品选择数据 ✅ |
| `/sku/select-base` | GET | 商品选择（标品）✅ 已找到 |
| `/product/select?ids=` | GET | 批量查询商品详情 ✅ |
| `/category/list` | GET | 商品分类列表 |
| `/spu/list` | GET | SPU 列表 |
| `/sku/list` | GET | SKU 列表 |

### 4.2 服务相关

| 接口 | 方法 | 说明 |
|------|------|------|
| `/serve/list` | GET | 服务列表 ✅ 已找到 |
| `/service/category-list` | GET | 服务分类列表（待确认）|

### 4.3 非标品（待确认）

| 接口 | 方法 | 说明 |
|------|------|------|
| `/item/all` | GET | 非标品列表（待确认）|
| `/category/spu-list` | GET | SPU 分类列表（待确认）|

---

## 五、字段说明

> 字段类型见 `product-types.dart` / `service-types.dart` / `sku-types.dart`。本 PRD 不维护字段表。

---

## 六、核心交互逻辑

> 本节描述 Flutter 端实际行为，并标注与 z1-pwa Web 的差异。

### 6.1 商品/服务 Tab 切换

- 顶部为商品/服务 Tab，切换时**保留对方类型的购物车数据**（`retail_product_page.dart:62-74, 105-115`）
- 商品 Tab：左侧分类列表 → 右侧 SPU 网格（`product_tab.dart:181-280`）
- 服务 Tab：左侧服务分类 → 右侧服务列表（`service_tab.dart`）

> 与 z1-pwa 的差异：Web 端是分步骤（步骤 2 选商品 → 步骤 3 选服务），通过 `editGeneralDraft` 持久化草稿；Flutter 是 Tab 切换 + 内存购物车。

### 6.2 商品三级导航：分类 → SPU → SKU

- 点击分类 → bloc 触发 `getSpuListByMallCate(categoryId)` 加载该分类下 SPU（`product_select_bloc.dart:322`）
- 点击 SPU → 打开 `SkuSelectModal`，加载该 SPU 的所有 SKU（`sku_select_modal.dart`）
- SKU 选择规则：
  - `(sku.stock ?? 0) <= 0` 时灰底 + "缺货"标签且禁点（`sku_select_modal.dart:270-275, 325-332`）
  - `hasSerial == 2` 序列号商品：跳过数量选择，按钮变为"选择具体商品"（`sku_select_modal.dart:211-252, 413-422`），目前跳转 goods 列表页是 TODO
  - 加购按钮启用条件：`selectedSku != null && stock > 0`（`sku_select_modal.dart:425`）

### 6.3 搜索

- 商品搜索：`onChanged` 实时触发 `ProductSelectSearchChanged` 事件（`product_tab.dart:132-134`）
- ⚠️ 当前 bloc 内只更新 `searchKeyword` 字段，**未在 `_onSearchChanged` 中执行过滤**（`product_select_bloc.dart:500-508`），过滤逻辑待实现
- z1-pwa Web 是手动触发（`onPressEnter`）+ `tiny-pinyin` 拼音模糊匹配（`SelectProductForMobile.tsx:69-100`）

### 6.4 扫码

- 商品 Tab 顶部相机图标按钮（`product_tab.dart:138-152`）
- ⚠️ `onTap` 标注 `// TODO: Camera scan functionality`，当前未接入扫码

### 6.5 购物车

- 底部固定栏显示总件数 + 总金额 + 去结算按钮
- 购物车明细抽屉支持改数量、删除项
- 结算前校验：购物车为空时弹 `CupertinoAlertDialog` 提示"请先添加商品或服务"（`retail_product_page.dart:128-148`）
- 并发保护：`_isUpdatingState` 锁防止商品/服务 Tab 切换时购物车更新冲突（`retail_product_page.dart:51-83`）

### 6.6 服务选择特殊规则

- 服务无 SKU 概念，直接列表点击加入购物车
- 服务**数量固定为 1**（参考 z1-pwa `SelectService.tsx:108-111`，"服务数量"列写死 `() => 1`）
- 服务的 `isGoods` 字段：`1=绑定序列号 / 2=不绑定`，由后端按 `isGoods` 参数过滤（详见 service-select-prd.md）

---

## 七、异常/边界情况

### 7.1 加载与空数据

| 场景 | 处理 | 来源 |
|------|------|------|
| 商品分类加载失败 | 显示错误提示 + 重试按钮 | `product_tab.dart:39-53` |
| 分类下无 SPU | 显示"暂无商品" | `product_tab.dart:227-241` |
| 未选分类 | 显示"请选择分类" | `product_tab.dart:227-241` |
| SKU 加载失败 | 降级使用 `widget.spu.skus`，`debugPrint` 异常 | `sku_select_modal.dart:84-94` |
| 库存接口 90000 错误 | `stockMap[spuId] = -1` 标记加载失败 | `product_select_bloc.dart:454-459` |

### 7.2 库存与数量校验

| 场景 | 处理 | 来源 |
|------|------|------|
| SKU 库存为 0 | 该 SKU 灰底 + "缺货"标签 + 禁点 | `sku_select_modal.dart:270-275` |
| 序列号商品（hasSerial=2）加购 | 不允许直接加，必须进 goods 列表选具体商品 | `sku_select_modal.dart:211-252` |
| 数量非整数或 ≤0（参考 Web 行为） | 应提示"请输入合法的数量"，待 Flutter 端实现 | z1-pwa `SelectProduct.tsx:325-328` |
| 仓库未绑定（参考 Web 行为） | 应提示"该职员部门未绑定仓库"，待 Flutter 端实现 | z1-pwa `SelectProduct.tsx:691-695` |

### 7.3 购物车并发与异常

| 场景 | 处理 | 来源 |
|------|------|------|
| 商品/服务 Tab 切换时数据冲突 | `_isUpdatingState` 锁防并发 | `retail_product_page.dart:51-83` |
| 购物车更新异常 | `debugPrint('商品购物车状态更新异常: $e')`，UI 不闪 | `retail_product_page.dart:51-83` |
| 结算时购物车为空 | `CupertinoAlertDialog`："请先添加商品或服务" | `retail_product_page.dart:128-148` |

### 7.4 已知 TODO

- 扫码入口未接入（`product_tab.dart:140`）
- 序列号商品 goods 列表页跳转未实现（`product_tab.dart:294-295`）
- 搜索关键词未应用过滤（`product_select_bloc.dart:500-508`）

---

## 八、状态流转

本页面是商品/服务选购页，**无业务状态机**。涉及到的状态过滤维度：

| 维度 | 字段 | 说明 |
|------|------|------|
| 商品上架状态 | SPU/SKU 的 `state`、`listingStatus` | 列表只显示已上架可售商品 |
| 库存状态 | SKU 的 `stock` | 库存为 0 时灰底禁选 |
| 序列号绑定 | SKU 的 `hasSerial` | `=2` 时跳过数量选择，进 goods 列表 |
| 服务启用状态 | Service 的 `state` | 列表只显示 `state=1`（启用） |
| 服务序列号绑定 | Service 的 `isGoods` | `1=绑定 / 2=不绑定`，按场景过滤 |

> 详细字段定义见 `product-types.dart` / `sku-types.dart` / `service-types.dart`。

---

## 九、模块关联

```
┌───────────────────────────────────────────────────────────────────┐
│                     商品/服务选择 模块关联                         │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   零售开单首页 (会员选择) ──→ 商品/服务选择 (本页)                 │
│                                  │                                │
│              ┌───────────────────┼───────────────────┐           │
│              ↓                   ↓                   ↓           │
│         商品 Tab              服务 Tab            扫码入口        │
│              │                   │                   │ TODO      │
│              ↓                   ↓                   │           │
│         分类选择            服务分类                  │           │
│              ↓                   ↓                   │           │
│         SPU 列表           服务列表                   │           │
│              ↓                   ↓                   │           │
│         SKU 弹窗 ←─ 序列号商品 ─→ goods 列表 (TODO)             │
│              ↓                   ↓                              │
│              └────────→ 购物车 ←─┘                              │
│                          │                                       │
│                          ↓                                       │
│                  订单确认页 (优惠券/积分/支付)                     │
│                          │                                       │
│                          ↓                                       │
│                  /home/retail/payment 收银                       │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### 9.1 模块跳转

| 来源 | 触发 | 目标 | 说明 |
|------|------|------|------|
| 会员选择页 | 选定会员后"开始选购" | 商品/服务选择 | 共享 `memberID` |
| 商品/服务选择 | 切 Tab | 同页面切换 | 购物车保留对方类型项 |
| 商品 Tab | 点击 SPU | SKU 选择弹窗 | `Modal/Drawer` 内嵌 |
| SKU 弹窗 | hasSerial=2 时点击"选择具体商品" | goods 列表页 | ⚠️ 当前未实现 |
| 商品/服务选择 | 点击"去结算" | 订单确认页 | 携带 `cartItems` |

### 9.2 数据共享

| 数据 | 来源 | 消费者 |
|------|------|--------|
| `cartItems`（含 goods/service 两类） | 本页购物车 | 订单确认 / 收银 |
| `memberID` | 会员选择页 | 本页（用于会员价/优惠券计算） |
| `selectedSku.hasSerial` | SKU 弹窗 | 订单提交时绑定 `pSN/sn/goodsID` |
| 系统设置 `serviceIdSalesProductDefaultAdded` | 后端配置 | hasSerial=yes 商品自动附加默认服务 |

### 9.3 与零售开单 PRD 关系

- 父级 PRD：`retail-detail-prd.md`（零售开单总流程）
- 子模块 PRD：
  - `category-select-prd.md`（商城分类 3 级选择）
  - `service-select-prd.md`（服务选择细节）

---

## 十、待确认事项

1. **服务分类接口**：`/service/category-list` 路径是否正确？
2. **非标品接口**：`/item/all` 和 `/category/spu-list` 路径待确认
3. **商品分类接口**：`/category/list` 和 `/spu/list` 路径？
4. **库存接口**：`/stock/query` 路径？

---

## 十一、组件实现计划

| 组件 | 优先级 | 说明 |
|------|--------|------|
| ProductTab | P0 | 商品 Tab（分类+商品网格）|
| ServiceTab | P0 | 服务 Tab（分类+服务列表）|
| SkuModal | P1 | SKU 规格选择弹窗 |
| CartDrawer | P1 | 购物车抽屉 |
| CartItem | P2 | 购物车项（支持修改数量）|

---

> 上次更新：2026-05-20（根据 z1-pwa StoreRetail 组件分析）