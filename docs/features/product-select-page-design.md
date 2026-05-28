# 商品/服务选购页面 · 设计规格

> **模块**：零售开单 - 商品/服务选购
> **版本**：v1.0
> **日期**：2026-05-23
> **状态**：设计稿
> **依据**：z1-pwa StoreRetail 模块分析

---

## 一、页面结构

### 1.1 路由与布局

```
路由：/home/retail/product-select
参数：
  - memberId?: number     // 会员ID（可选）
  - warehouseId: number   // 仓库ID（必填）
```

```
┌──────────────────────────────────┐
│ ← 商品选购            [购物车 3] │  ← AppBar + 购物车入口
├──────────────────────────────────┤
│ [零售] [张三 金卡 ▼]             │  ← 销售类型 + 会员切换
├──────────────────────────────────┤
│ [商品] [服务] [非标品]           │  ← Tab 切换
├──────────────────────────────────┤
│                                  │
│         Tab 内容区域             │
│                                  │
├──────────────────────────────────┤
│ ┌────────────────────────────┐   │
│ │ 🛒 3件  ¥21,528   [去结算]  │   │  ← 购物车浮动栏
│ └────────────────────────────┘   │
└──────────────────────────────────┘
```

---

## 二、商品 Tab

### 2.1 布局结构

```
┌──────────────────────────────────┐
│ [搜索商品名称/条码]    [扫码]     │
├──────────────────────────────────┤
│  │                               │
│  分类    商品网格                 │
│  全部    ┌────┐ ┌────┐           │
│  黄金    │商品│ │商品│            │
│  钻石    ├────┤ ├────┤            │
│  银饰    │商品│ │商品│            │
│  配件    └────┘ └────┘            │
│  │                               │
└──────────────────────────────────┘
```

### 2.2 左侧分类列表

**数据来源**：
```typescript
// 进销存分类
GET /category/list?type=spu
Response: { id, name, pid, order }

// 或商城分类
GET /mall-category/list
Response: { id, title, pids, weight }
```

**交互**：
- 点击分类 → 显示该分类下的 SPU 列表
- 默认显示"全部"
- 支持二级分类展开

### 2.3 商品网格（SPU 卡片）

**数据来源**：
```typescript
// SPU 列表
GET /product/spu-list?cateId={id}&limit=100
Response: { id, name, weight }

// 库存
GET /product/stock-by-spu?spuIds=[id]&warehouseId={warehouseId}
Response: { spuId, saleStock, lockStock }
```

**卡片布局**：
```
┌────────────────────────────┐
│ 🖼️ 商品图片                 │
│                            │
│ 商品名称                    │
│ 库存：5  零售价：¥2800     │
│                            │
│ [选择规格]                  │
└────────────────────────────┘
```

**字段**：
```typescript
type SPUCard = {
  id: number;
  name: string;
  image?: string;          // 商品主图
  stock: number;           // 库存（可售）
  retailPrice: RMBFen;     // 零售价
  memberPrice?: RMBFen;    // 会员价
};
```

### 2.4 SPU → SKU 弹窗

点击商品卡片 → 弹出规格选择：

```
┌──────────────────────────────────┐
│ 选择规格                    [×]  │
├──────────────────────────────────┤
│ 足金凤尾纹手镯                   │
│                                  │
│ 规格：                          │
│ ┌─────┐ ┌─────┐ ┌─────┐         │
│ │20g  │ │25g  │ │30g  │ ← 当前   │
│ │¥2200│ │¥2700│ │¥3200│         │
│ └─────┘ └─────┘ └─────┘         │
│                                  │
│ 库存：5                         │
│ 会员价：¥2650                   │
│                                  │
│ 数量：[ - ] [ 1 ] [ + ]         │
│                                  │
│ [加入购物车]                     │
└──────────────────────────────────┘
```

**数据来源**：
```typescript
// SKU 列表
GET /product/list?spuId={id}
Response: {
  id, name, hasSerial,
  price, costPrice
}

// SKU 库存
GET /product/stock-by-sku?skuIds=[id]&warehouseId={warehouseId}
Response: { skuId, saleStock, lockStock }
```

**字段**：
```typescript
type SkuSpec = {
  id: number;
  name: string;           // 规格名称（如"20g"）
  price: RMBFen;          // 零售价
  memberPrice?: RMBFen;   // 会员价
  stock: number;          // 可售库存
  hasSerial: boolean;     // 是否有序列号
};
```

---

## 三、服务 Tab

### 3.1 布局结构

```
┌──────────────────────────────────┐
│ [搜索服务名称/编号]              │
├──────────────────────────────────┤
│  │                               │
│  分类    服务列表                 │
│  全部    ┌──────────────────┐    │
│  清洗    │ 🛁 珠宝清洗保养   │    │
│  维修    │ ¥188/次          │    │
│  定制    ├──────────────────┤    │
│  鉴定    │ 🔧 戒指改圈       │    │
│         │ ¥88/次            │    │
│         └──────────────────┘    │
│  │                               │
└──────────────────────────────────┘
```

### 3.2 服务列表项

**数据来源**：
```typescript
// 服务分类
GET /category/list?type=service
Response: { id, name, pid, order }

// 服务列表
GET /serve/list?cateId={id}&limit=100
Response: {
  id, name, shortName, cent,
  costCent, isGoods, cateId
}

// 服务数量
GET /serve/count?cateId={id}
Response: number
```

**列表项布局**：
```
┌──────────────────────────────────┐
│ 🛁 珠宝清洗保养                   │
│         ¥188/次            [+]   │
└──────────────────────────────────┘
```

**字段**：
```typescript
type ServiceItem = {
  id: number;
  name: string;
  shortName: string;
  price: RMBFen;         // 服务价格
  isGoods: number;       // 1=需绑定序列号 2=不需绑定
  categoryName?: string; // 分类名称
};
```

**交互**：
- 点击 [+] → 加入购物车
- `filterOutServiceHasSerial = true`（默认过滤有序列号的服务）

---

## 四、非标品 Tab

### 4.1 布局结构

```
┌──────────────────────────────────┐
│ [搜索序列号/关键词]               │
├──────────────────────────────────┤
│  │                               │
│  分类    货品列表                  │
│  全部    ┌──────────────────┐    │
│  黄金    │ 🔹 XSD2023050001 │    │
│  钻石    │ 足金手镯 30g     │    │
│  银饰    │ ¥2800           │    │
│         ├──────────────────┤    │
│         │ 🔹 XSD2023050002 │    │
│         │ 钻戒 50分        │    │
│         │ ¥18500          │    │
│         └──────────────────┘    │
│  │                               │
└──────────────────────────────────┘
```

### 4.2 非标品列表项

**数据来源**：
```typescript
// SPU 分类
GET /category/list?type=spu
// 再根据系统设置 nonStandardCateSetting 过滤

// 非标品列表
GET /item/all?cateIds=[id]&saleState=true&status=普通
Response: { id, uniqueSN, ... }
```

**列表项布局**：
```
┌──────────────────────────────────┐
│ 🔹 XSD2023050001                 │
│ 足金凤尾纹手镯 30g               │
│ 库存：1  售价：¥2800             │
│                            [选择]│
└──────────────────────────────────┘
```

**字段**：
```typescript
type NonStandardItem = {
  id: number;
  uniqueSN: string;       // 唯一序列号
  spuName: string;       // SPU名称
  weight?: string;        // 重量
  price: RMBFen;          // 售价
  stock: number;          // 库存（通常为1）
};
```

---

## 五、购物车

### 5.1 浮动栏

```
┌──────────────────────────────────┐
│ 🛒 购物车               [清空]   │
│                                  │
│ 商品（2件）                       │
│ ┌────────────────────────────┐   │
│ │ 📿 足金手镯 30g    ¥2800   │   │
│ │     [-] 1 [+]        [删除]│   │
│ └────────────────────────────┘   │
│ ┌────────────────────────────┐   │
│ │ 💎 50分钻戒      ¥18500    │   │
│ │     [-] 1 [+]        [删除]│   │
│ └────────────────────────────┘   │
│                                  │
│ 服务（1件）                       │
│ ┌────────────────────────────┐   │
│ │ 🛁 珠宝清洗保养  ¥188      │   │
│ │     [-] 1 [+]        [删除]│   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│ 合计：¥21,488      [去结算]      │
└──────────────────────────────────┘
```

### 5.2 购物车数据结构

```typescript
type CartItem = {
  key: string;              // 唯一标识（随机生成）
  type: 'goods' | 'service' | 'nonstandard';

  // 商品
  id?: number;
  skuId?: number;
  spuId?: number;
  name?: string;
  image?: string;
  specName?: string;       // 规格名称

  // 服务
  serviceId?: number;

  // 非标品
  itemId?: number;
  uniqueSN?: string;

  // 共用
  price: RMBFen;           // 单价
  memberPrice?: RMBFen;    // 会员价
  quantity: number;        // 数量
  hasSerial: boolean;      // 是否有序列号
  stock?: number;          // 库存
};

type Cart = {
  items: CartItem[];
  totalAmount: RMBFen;     // 合计金额
  totalQuantity: number;    // 合计数量
};
```

---

## 六、交互流程

### 6.1 商品选购流程

```
1. 进入页面 → 获取仓库ID → 获取分类列表
2. 点击分类 → 显示 SPU 列表 + 库存
3. 点击 SPU 卡片 → 弹出 SKU 选择弹窗
4. 选择 SKU → 填写数量 → 点击"加入购物车"
5. Toast 提示"已加入购物车"
6. 购物车浮动栏数量+1
```

### 6.2 服务选购流程

```
1. 进入页面 → 获取服务分类列表
2. 点击分类 → 显示服务列表
3. 点击服务项 [+ ] → 直接加入购物车
4. Toast 提示"已加入购物车"
```

### 6.3 非标品选购流程

```
1. 进入页面 → 获取 SPU 分类（过滤非标分类）
2. 点击分类 → 显示非标品列表
3. 点击非标品 → 选中（单选）
4. 点击"选择" → 加入购物车
```

---

## 七、接口对照表

> ⚠️ 已验证（2026-05-23）
> - `/category/list` ✅ 不需要 type 参数
> - `/spu/list` ✅ 支持 cateId, limit
> - `/spu/count` ✅

### 7.1 商品 Tab

| 功能 | 接口 | 状态 | 参数 |
|------|------|------|------|
| 分类列表 | `GET /category/list` | ✅ | 无需 type 参数 |
| SPU 列表 | `GET /spu/list` | ✅ | cateId, limit |
| SPU 数量 | `GET /spu/count` | ✅ | cateId |
| SKU 列表 | `GET /product/list-by-condition` | ❌ 不存在 | - |
| SKU 库存 | `GET /product/stock-by-sku` | ❌ 不存在 | - |

### 7.2 服务 Tab

| 功能 | 接口 | 状态 | 说明 |
|------|------|------|------|
| 服务分类 | `GET /category/list` | ✅ | 同上 |
| 服务列表 | `GET /serve/list` | ✅ | 无需认证 |
| 服务数量 | `GET /serve/count` | ✅ | 需认证，count: 4713 |
| 服务详情 | `GET /serve/detail` | ✅ | 需认证，参数 `ids` |
| 游客模式 | `GET /serve/detail/mall` | ✅ | 无需认证，游客模式 |

**serve/list 参数**：
```typescript
{
  cateId?: number;       // 分类ID
  keyWord?: string;      // 关键词搜索
  states?: number[];     // 状态筛选
  isGoods?: number;      // 1=需绑定序列号 2=不需绑定
  limit?: number;
  offset?: number;
}
```

**serve/detail 参数**：
```typescript
{ ids: number[] }  // 注意是 ids 不是 id
```

### 7.3 非标品 Tab

| 功能 | 接口 | 状态 | 说明 |
|------|------|------|------|
| SPU 分类 | `GET /category/list` | ✅ | 同上 |
| 非标品列表 | `GET /item/all` | ❌ 权限不足 | 需 90000 权限 |

---

## 八、组件清单

### 8.1 页面级组件

| 组件 | 文件 | 说明 |
|------|------|------|
| ProductSelectPage | `product_select_page.dart` | 主页面 |
| ProductTab | `product_tab.dart` | 商品 Tab |
| ServiceTab | `service_tab.dart` | 服务 Tab |
| NonStandardTab | `non_standard_tab.dart` | 非标品 Tab |
| CartDrawer | `cart_drawer.dart` | 购物车抽屉 |
| CartFloatingBar | `cart_floating_bar.dart` | 购物车浮动栏 |

### 8.2 业务组件

| 组件 | 文件 | 说明 |
|------|------|------|
| CategoryList | `category_list.dart` | 左侧分类列表 |
| SpuGrid | `spu_grid.dart` | SPU 网格 |
| SpuCard | `spu_card.dart` | SPU 卡片 |
| SkuModal | `sku_modal.dart` | SKU 选择弹窗 |
| ServiceList | `service_list.dart` | 服务列表 |
| ServiceItem | `service_item.dart` | 服务项 |
| NonStandardList | `non_standard_list.dart` | 非标品列表 |
| CartItemCard | `cart_item_card.dart` | 购物车项卡片 |
| QuantityStepper | `quantity_stepper.dart` | 数量步进器 |

### 8.3 通用组件

| 组件 | 文件 | 说明 |
|------|------|------|
| SearchBar | `search_bar.dart` | 搜索栏（含扫码按钮）|
| EmptyState | `empty_state.dart` | 空状态 |
| LoadingState | `loading_state.dart` | 加载状态 |

---

## 九、状态管理

### 9.1 CartProvider

```dart
class CartItem {
  String key;
  CartItemType type;  // goods, service, nonstandard
  int id;
  String name;
  int price;
  int quantity;
  // ...
}

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];

  int get totalAmount => items.fold(0, (sum, item) => sum + item.price * item.quantity);
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(CartItem item);
  void removeItem(String key);
  void updateQuantity(String key, int quantity);
  void clear();
}
```

### 9.2 MemberProvider

```dart
class MemberProvider extends ChangeNotifier {
  Member? currentMember;
  SalesMode salesMode;  // retail, wholesale

  void switchMember(Member? member);
  void switchSalesMode(SalesMode mode);
}
```

---

## 十、接口验证结果（2026-05-23 补充）

### 已验证可用

| 接口 | 说明 |
|------|------|
| `/category/list` | 分类列表（无需 type 参数）|
| `/spu/list` | SPU 列表（支持 cateId, limit）|
| `/spu/count` | SPU 数量 |
| `/serve/list` | ✅ 服务列表（路径修正：`/serve/` 非 `/service/`）|
| `/serve/count` | ✅ 服务数量 |
| `/serve/detail` | ✅ 服务详情 |
| `/serve/detail/mall` | ✅ 游客模式（无需 token）|

### 不存在/待后端提供

| 接口 | 说明 |
|------|------|
| `/service/list` | ❌ 路径错误，应用 `/serve/list` |
| `/service/count` | ❌ 路径错误，应用 `/serve/count` |
| `/product/list-by-condition` | ❌ 不存在 |
| `/product/stock-by-spu` | ❌ 不存在 |
| `/product/stock-by-sku` | ❌ 不存在 |
| `/item/all` | ❌ 权限不足（90000）|

### 待解决

1. **SKU 列表**：需要后端提供 `/sku/list` 接口
2. **库存接口**：需要后端提供库存查询接口
3. **非标品接口**：需要后端授权 `/item/all`

---

> 上次更新：2026-05-23（v1.0 初始设计）