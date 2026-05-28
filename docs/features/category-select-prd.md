# 3级分类选购 · 产品文档

> **模块**：零售开单 - 商品分类选购
> **版本**：v1.0
> **日期**：2026-05-24
> **状态**：待开发
> **依据**：z1-pwa 组件分析 + 接口验证

---

## 一、产品概述

### 1.1 业务背景

门店零售开单时，店员需要快速找到要销售的商品。为了提升选购效率，系统提供**3级分类导航**，帮助店员在海量商品中快速定位目标。

### 1.2 核心价值

| 价值 | 说明 |
|------|------|
| **快速定位** | 通过分类导航，3秒内找到目标商品 |
| **结构清晰** | 3级分类（品类→品牌→系列）符合用户心智 |
| **操作简单** | 点击分类 → 显示商品，无需搜索 |

---

## 二、用户场景

### 场景1：快速选购

**用户**：门店店员
**场景**：顾客到店购买 iPhone 手机
**流程**：
1. 打开零售开单页面
2. 选择「手机」分类
3. 选择「苹果」品牌
4. 选择「iPhone 16」系列
5. 查看该系列下的商品

### 场景2：浏览查找

**用户**：门店店员
**场景**：不知道具体要买什么，想看看有什么选择
**流程**：
1. 进入商品选购页面
2. 浏览顶级分类（手机/电脑/配件）
3. 点击「手机」查看下级分类
4. 点击具体品牌查看商品
5. 选择商品加入购物车

### 场景3：搜索+分类结合

**用户**：门店店员
**场景**：知道商品名称，但想通过分类筛选
**流程**：
1. 使用搜索框搜索商品名称
2. 同时可以看到该商品属于哪个分类
3. 点击分类可查看同类商品

---

## 三、页面结构

### 3.1 布局

```
┌──────────────────────────────────┐
│ ← 商品选购            [购物车 3] │
├──────────────────────────────────┤
│ [零售] [张三 金卡 ▼]             │ ← 销售类型 + 会员
├──────────────────────────────────┤
│ [商品] [服务] [非标品]           │ ← Tab 切换
├──────────────────────────────────┤
│ ┌──────┬─────────────────────┐  │
│ │      │  [搜索商品名称] [扫码] │  │
│ │      ├─────────────────────┤  │
│ │ 3级  │                     │  │
│ │ 分类  │     商品网格         │  │
│ │      │                     │  │
│ │ 黄金  │  ┌────┐ ┌────┐   │  │
│ │ 周大福 │  │商品│ │商品│   │  │
│ │ 手镯  │  ├────┤ ├────┤   │  │
│ │      │  │商品│ │商品│   │  │
│ │      │  └────┘ └────┘   │  │
│ │      │                     │  │
│ └──────┴─────────────────────┘  │
├──────────────────────────────────┤
│ 🛒 3件  ¥21,528   [去结算]       │ ← 购物车浮动栏
└──────────────────────────────────┘
```

### 3.2 左侧分类面板

```
┌──────────────┐
│ ← 返回      │ ← 面包屑导航
├──────────────┤
│             │
│ 黄金        │ ← 第1级：品类
│ 周大福      │ ← 第2级：品牌
│ 手镯        │ ← 第3级：系列（当前选中）
│             │
│ 钻石        │
│ 钻戒        │
│ 50分钻戒    │
│             │
│ 银饰        │
│             │
└──────────────┘
     30%
```

---

## 四、交互流程

### 4.1 分类导航流程

```
┌─────────┐
│ 打开页面 │ → 获取顶级分类 → 显示第1级
└────┬────┘
     │
     ▼
┌─────────────────┐
│ 点击分类（如"黄金"）│
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ 获取子分类 / SPU │ → 获取第2级分类 + 该分类下的 SPU
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ 点击品牌（如"周大福"）│
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ 获取子分类 / SPU │ → 获取第3级分类 + 该分类下的 SPU
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ 点击系列（如"手镯"）│
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ 显示该系列商品   │ → 显示具体商品列表
└─────────────────┘
```

### 4.2 点击分类后的行为

| 当前层级 | 点击分类 | 行为 |
|----------|----------|------|
| 第1级（品类）| 点击品类 | 显示该品类的子分类（品牌）+ 该品类的 SPU |
| 第2级（品牌）| 点击品牌 | 显示该品牌的子分类（系列）+ 该品牌的 SPU |
| 第3级（系列）| 点击系列 | 显示该系列的 SPU |
| - | 点击「返回」| 返回上级分类 |

### 4.3 面包屑导航

```
[全部] > [黄金] > [周大福] > [手镯]
  ↑         ↑         ↑         ↑
返回顶级  返回品类   返回品牌   当前系列
```

---

## 五、接口实现

### 5.1 数据获取

> ⚠️ 开单使用商城分类（`cateType: 'mall'`），不是进销存分类

```dart
// 1. 获取商城分类列表
GET /mall-category/list

// 2. 分类过滤函数（根据 pids 构建树）
List<MallCategory> getChildren(List<MallCategory> all, int parentId) {
  return all.where((c) {
    final pid = c.pids.isNotEmpty ? c.pids.last : 0;
    return pid == parentId;
  }).toList();
}

// 3. 分类节点
class MallCategoryNode {
  final int id;
  final String name;       // title 字段
  final int level;        // 1=品类, 2=品牌, 3=系列
  final List<int> pids;   // 父级ID数组
  final List<MallCategoryNode> children;

  bool get isTopLevel => level == 1;
  bool get isMiddleLevel => level == 2;
  bool get isBottomLevel => level == 3;
}
```

### 5.2 数据结构

```dart
// 商城分类字段
MallCategory {
  id: number,           // 分类ID
  title: string,        // 分类名称
  weight: number,       // 排序权重
  level: 1 | 2 | 3,    // 层级
  pids: [],             // 品类：父级为空
  pids: [品类ID],       // 品牌：父级为品类
  pids: [品类ID, 品牌ID],  // 系列：父级为品牌
  spell?: string,        // 系列才有
  imgUrl?: string,      // 系列才有
  createdAt: timestamp,
  updatedAt: timestamp,
}

// 层级结构
品类 (level=1, pids=[])
└── 品牌 (level=2, pids=[品类ID])
    └── 系列 (level=3, pids=[品类ID, 品牌ID])
```

### 5.3 获取 SPU

```dart
// 根据商城分类ID获取 SPU
GET /spu/list?mallCateIDs={mallCategoryId}

// 注意：参数是 mallCateIDs（数组），即使只有一个也要传数组
GET /spu/list?mallCateIDs[]={mallCategoryId}

// SPU 字段
SPU {
  id: number,
  name: string,
  brand: string,
  series: string,
  minPrice: number,      // 最低价格（分）
  maxPrice: number,      // 最高价格（分）
  images: [{url, isMain}],
  // stock: ❌ 不存在，需通过 /spu/get-stock 查询
}
```

### 5.4 获取库存

```dart
// SPU 总库存（POST）
POST /spu/get-stock
Body: { spuIDs: [1, 2, 3], warehouseIDs?: [1, 2] }
返回: [{spuID, stock, lockStock, saleStock}]

// 商城分类库存
POST /stock/mall-cate
Body: { mallCateIDs: [1, 2], warehouseIDs?: [1, 2] }
返回: [{mallCateID, stock, saleStock}]
```

### 5.2 数据结构

```dart
// 分类节点
class CategoryNode {
  final int id;           // 分类ID
  final String name;       // 分类名称
  final int pid;           // 父级ID（0表示顶级）
  final String spell;       // 拼音码
  final int order;         // 排序权重
  final List<CategoryNode> children;  // 子分类
}

// 分类列表返回
class CategoryListResponse {
  final List<Category> list;
  final int total;
}

// 分类字段
// id, name, spell, pid, order, type, state, chain, icon
```

### 5.3 获取 SPU

```dart
// 根据分类ID获取 SPU
final spuList = await getSPUList(cateId: categoryId, limit: 100);

// SPU 字段（来自 SDK 源码）
// id: number           - SPU ID
// name: string         - SPU 名称
// brand: string        - 品牌
// series: string       - 系列
// generation: string   - 代际
// weight: number       - 权重
// spell: string        - 拼音码
// images: SPUImages    - 图片数组 [{url, isMain}]
// minPrice: number     - 最低价格（分）
// maxPrice: number     - 最高价格（分）
// salesState: number   - 销售状态
// stock: number        - ❌ 不存在，需通过 SKU 查询

// 注意：SPU 不含库存字段，需调用 /spu/get-stock 查询
```

### 5.4 获取库存

```dart
// SPU 总库存（POST）
POST /spu/get-stock
Body: { spuIDs: [1, 2, 3], warehouseIDs?: [1, 2] }
返回: [{spuID, stock, lockStock, saleStock}]

// SKU 库存（GET）
GET /spu/sku-stock?spu={spuId}
返回: [{skuID, virtualStock, saleStock}]
```

---

## 六、组件设计

### 6.1 组件清单

| 组件 | 说明 |
|------|------|
| `CategorySelectPanel` | 左侧分类面板 |
| `CategorySidebar` | 分类列表（可折叠）|
| `CategoryBreadcrumb` | 面包屑导航 |
| `ProductGrid` | 商品网格 |
| `ProductCard` | 商品卡片 |

### 6.2 组件状态

```dart
// CategorySelectPanel 状态
enum CategoryPanelState {
  loading,      // 加载中
  topLevel,     // 显示顶级分类
  secondLevel,   // 显示第2级
  thirdLevel,    // 显示第3级
}

// 状态转换
// loading → topLevel → secondLevel → thirdLevel
// thirdLevel → secondLevel（点击返回）
// secondLevel → topLevel（点击返回）
// topLevel → topLevel（点击全部）
```

---

## 七、UI 规范

### 7.1 布局比例

| 区域 | 宽度 |
|------|------|
| 左侧分类面板 | 屏幕 30% |
| 右侧商品区域 | 屏幕 70% |

### 7.2 字号规范

| 元素 | 字号 |
|------|------|
| 当前选中分类 | 16px, 加粗 |
| 普通分类 | 14px |
| 分类拼音码 | 12px, 灰色 |

### 7.3 颜色规范

| 元素 | 颜色 |
|------|------|
| 选中背景 | #E8F4FF（浅蓝）|
| 选中文字 | #0575FF（蓝色）|
| 普通文字 | #333333（深灰）|
| 拼音码 | #999999（浅灰）|
| 分割线 | #E5E5E5 |

---

## 八、异常处理

### 8.1 分类为空

| 场景 | 处理 |
|------|------|
| 某个分类下无子分类 | 显示「暂无分类」，隐藏分类面板 |
| 某个分类下无商品 | 显示「该分类下暂无商品」空状态 |

### 8.2 加载异常

| 场景 | 处理 |
|------|------|
| 分类加载失败 | 显示重试按钮 |
| SPU 加载失败 | 显示重试按钮，点击可单独重试 |

### 8.3 网络异常

| 场景 | 处理 |
|------|------|
| 网络断开 | 显示断网提示，提供重连按钮 |
| 请求超时 | 显示超时提示，自动重试1次 |

---

## 九、SKU 选择规格流程

### 9.1 可选层级

```dart
// selectableLevels 定义可选层级
enum SelectableLevel {
  'cate',      // 分类级别
  'spu',       // SPU 级别
  'sku',       // SKU 级别
  'goods',     // 商品个体级别（针对有序列号的 SKU）
  'sku-no-serial', // 非强制序列号的 SKU
}
```

### 9.2 完整选择流程

```
分类 → SPU 列表 → 点击 SPU → SKU 选择弹窗 → 选择规格 → 加入购物车
                                              ↓
                                    如果 hasSerial=2
                                              ↓
                                    进入商品列表（goods）
```

### 9.3 SKU 选择弹窗设计

点击 SPU 后弹出 SKU 选择弹窗：

```
┌──────────────────────────────────┐
│ 选择规格                    ✕    │
├──────────────────────────────────┤
│                                  │
│ 颜色                             │
│ [黑色 ✓] [白色] [金色] [蓝色]   │
│                                  │
│ 容量                             │
│ [128GB ✓] [256GB] [512GB]      │
│                                  │
├──────────────────────────────────┤
│  已选：iPhone 16 Pro 黑色 256GB │
│  库存：5  售价：¥8999          │
├──────────────────────────────────┤
│        [加入购物车]              │
└──────────────────────────────────┘
```

### 9.4 规格选项

规格信息存储在 **SPU.skuIDs** 数组中，不是 SKU 本身：

```dart
// SPU 包含 skuIDs 字段
SPU {
  id: number,
  name: string,
  skuIDs: [
    {skuID: 1, color: "黑色", spec: "128GB", combo: "套餐1"},
    {skuID: 2, color: "黑色", spec: "256GB", combo: "套餐1"},
    {skuID: 3, color: "白色", spec: "128GB", combo: "套餐1"},
    ...
  ]
}
```

SkuIDs 支持的组合：
- `color + spec + combo`
- `color + spec`
- `color + combo`
- `spec + combo`
- `color`
- `spec`
- `combo`

### 9.5 获取 SPU 及 SKU

```dart
// 获取 SPU 详情（含 skuIDs）
GET /product/sku-by-spu?spuID={spuID}

// SPU 字段
SPU {
  id: number,
  name: string,
  skuIDs: [...],  // 规格信息
}

// SKU 字段（基本信息）
SKU {
  id: number,
  name: string,
  listPrice: number,    // 标价（分）
  price: number,        // 售价（分）
  stock: number,       // 库存
  virtualStock: number, // 虚拟库存
  isAllowance: boolean, // 是否参与补贴
  thumbnail: string,
}
```

### 9.6 规格匹配逻辑

```dart
// 从 skuIDs 获取规格选项
List<String> getColors() {
  return spu.skuIDs
    .map((s) => s.color)
    .where((c) => c != null)
    .toSet()
    .toList();
}

List<String> getSpecs() {
  return spu.skuIDs
    .map((s) => s.spec)
    .where((s) => s != null)
    .toSet()
    .toList();
}

// 选择规格后匹配 SKU ID
int? matchSkuId({color, spec, combo}) {
  final match = spu.skuIDs.firstWhere(
    (s) =>
      (color == null || s.color == color) &&
      (spec == null || s.spec == spec) &&
      (combo == null || s.combo == combo),
    orElse: () => null,
  );
  return match?.skuID;
}
```

### 9.7 hasSerial 获取方式

> ⚠️ /product/sku-by-spu 接口未返回 hasSerial
> ✅ 需使用 /product/list 接口

```dart
// 获取 Product（含 hasSerial）
GET /product/list?spuId={spuID}

// 返回字段
Product {
  id: number,
  name: string,
  hasSerial: 1 | 2,  // 1=无序列号, 2=有序列号
  // ... 其他字段
}
```

### 9.8 数据获取流程

```
1. GET /product/sku-by-spu?spuID=X
   → 返回 SPU（含 skuIDs）和 SKU 列表（不含 hasSerial）

2. GET /product/list?spuId=X
   → 返回 Product 列表（含 hasSerial）

3. 从 spu.skuIDs 提取规格选项
   → colors, specs, combos

4. 用户选择规格 → 匹配 skuID

5. 根据 hasSerial 决定：
   - hasSerial=1 → 直接选中 SKU
   - hasSerial=2 → 进入 goods 列表
```

### 9.9 字段说明

| 字段 | 说明 |
|------|------|
| `hasSerial = 2` | 有序列号，需进入 goods 列表选择具体商品 |
| `hasSerial = 1` | 无序列号，可直接选择 SKU |
| `price` | SKU 售价（分），精确价格 |
| `listPrice` | SKU 标价（分）|
| `stock` | SKU 库存 |
| `virtualStock` | 虚拟库存 |
| `isAllowance` | 是否参与补贴 |
1. GET /product/sku-by-spu?spuID=X
   → 返回 SPU（含 skuIDs 规格信息）和 SKU 列表

2. 从 spu.skuIDs 提取规格选项
   → colors, specs, combos

3. 用户选择规格 → 匹配 skuID

4. 根据 skuID 找到对应 SKU → 显示价格、库存

---

## 十、接口清单

### 10.1 分类与 SPU

| 接口 | 说明 | 状态 |
|------|------|------|
| `GET /category/list?type=1` | 获取商品分类 | ✅ 已验证 |
| `GET /category/top` | 获取顶级分类 | ✅ 已验证 |
| `GET /spu/list?mallCateIDs[]=X` | 获取 SPU 列表（含价格、图片）| ✅ 已验证 |
| `GET /spu/count?cateId=X` | 获取 SPU 数量 | ✅ 已验证 |
| `GET /product/sku-by-spu` | 获取 SPU+SKU（含 skuIDs 规格）| ✅ 已验证 |
| `GET /product/list?spuId=X` | 获取 Product（含 hasSerial）| ✅ 已验证 |

### 10.2 库存与价格

| 接口 | 说明 | 状态 |
|------|------|------|
| `GET /spu/list-base` | SPU 列表（含 minPrice, maxPrice, images）| ✅ 已验证 |
| `POST /spu/get-stock` | SPU 库存（返回 stock, lockStock, saleStock）| ✅ 已验证 |
| `GET /product-warehouse/get-stock/sku` | SKU 库存 | ✅ 已验证 |

---

## 十一、依赖关系

### 11.1 前置条件

| 依赖 | 说明 |
|------|------|
| 登录 | 需要用户登录获取 token |
| 仓库绑定 | 需要当前用户绑定仓库 |

### 11.2 后置操作

| 操作 | 说明 |
|------|------|
| 加入购物车 | 将选中的 SKU 加入购物车 |
| 查看详情 | 查看商品详情（跳转商品详情页）|

---

> 上次更新：2026-05-24