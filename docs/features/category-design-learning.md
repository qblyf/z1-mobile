# 3级分类设计 · 学习报告

> **日期**：2026-05-23
> **来源**：z1-mid SDK 源码分析 + PWA 组件分析

> **⚠️ 类型唯一真实源**：API 字段定义以 `lib/types/api/` 为准（相关：category-types.dart, mall-category-types.dart）。本 PRD 不复制具体字段名/类型。

---

## 一、两种分类体系

系统中有**两套独立的分类体系**，用于不同场景：

| 分类体系 | 字段 | 层级关系 | 适用场景 |
|----------|------|----------|----------|
| 进销存分类 (Category) | `pid` | pid → 子分类 | 商品/服务选择 |
| 商城分类 (MallCategory) | `level` + `pids` | 品类→品牌→系列 | 商城展示 |

---

## 二、进销存分类（商品/服务选择）

### 2.1 分类类型 (CategoryType)

> 类型定义见 `category-types.dart, mall-category-types.dart`。

### 2.2 分类字段 (Category)

> 类型定义见 `category-types.dart, mall-category-types.dart`。

### 2.3 层级结构

**进销存分类通过 `pid` 字段实现无限层级**：

```
分类1 (id=1, pid=0)          ← 顶级
├── 分类1.1 (id=11, pid=1)
│   ├── 分类1.1.1 (id=111, pid=11)
│   └── 分类1.1.2 (id=112, pid=11)
└── 分类1.2 (id=12, pid=1)
    └── 分类1.2.1 (id=121, pid=12)

分类2 (id=2, pid=0)          ← 另一个顶级
```

### 2.4 获取子分类

> 类型定义见 `category-types.dart, mall-category-types.dart`。

---

## 三、商城分类（商城展示）

### 3.1 分类层级 (MallCategoryLevel)

> 类型定义见 `category-types.dart, mall-category-types.dart`。

### 3.2 分类字段 (MallCategory)

> 类型定义见 `category-types.dart, mall-category-types.dart`。

### 3.3 层级结构

```
品类 (level=1, pids=[])          ← 顶级
├── 黄金 (品类ID=1)
│   └── 品牌 (level=2, pids=[1])
│       ├── 周大福 (品牌ID=10)
│       │   └── 系列 (level=3, pids=[1, 10])
│       │       ├── 手镯系列
│       │       └── 项链系列
│       └── 周生生 (品牌ID=11)
│           └── 系列...
└── 钻石 (品类ID=2)
    └── 品牌...
```

---

## 四、PWA 中的分类选择实现

### 4.1 SelectProduct 组件（商品选择）

**文件**：`z1-pwa/src/components/mobile/SelectProduct.tsx`

**两种分类模式**：
1. **进销存分类** (`cateType='inventory'`)
   - 使用 `getCategoryList()` 获取分类
   - 通过 `pid` 字段筛选子分类

2. **商城分类** (`cateType='mall'`)
   - 使用 `mallCategoryList()` 获取分类
   - 通过 `pids` 数组筛选子分类

**关键代码**：

> 类型定义见 `category-types.dart, mall-category-types.dart`。

### 4.2 SelectService 组件（服务选择）

**文件**：`z1-pwa/src/components/mobile/SelectService.tsx`

**特点**：
- 只支持**进销存分类**（使用 `CategoryType.服务`）
- 服务分类层级通常较浅（1-2级）
- 通过 `filterOutServiceHasSerial` 过滤有序列号的服务

---

## 五、3级分类设计建议（新 App）

### 5.1 商品分类

推荐使用**商城分类**（MallCategory），因为：
- 层级固定（品类→品牌→系列）
- 有图片和拼音码
- 更适合移动端展示

**数据结构**：

> 类型定义见 `category-types.dart, mall-category-types.dart`。

### 5.2 服务分类

使用**进销存分类**（Category），因为：
- 服务分类层级较浅
- 与商品使用同一套分类体系
- 通过 `CategoryType.服务` 筛选

### 5.3 左侧分类 + 右侧内容布局

```
┌──────────────────────────────────┐
│ [商品] [服务] [非标品]           │
├──────────────────────────────────┤
│ 分类    商品列表                  │
│ ┌────┐ ┌──────────────────┐   │
│ │黄金 │ │ 🖼️ 商品图片        │   │
│ ├────┤ │ 商品名称            │   │
│ │钻石 │ │ 库存:5  ¥2800     │   │
│ ├────┤ └──────────────────┘   │
│ │银饰 │ ┌──────────────────┐   │
│ └────┘ │ 🖼️ 商品图片        │   │
│         │ 商品名称            │   │
│         │ 库存:3  ¥18500    │   │
│         └──────────────────┘   │
└──────────────────────────────────┘
```

**实现思路**：

> 类型定义见 `category-types.dart, mall-category-types.dart`。

---

## 六、接口验证结果（2026-05-24）

### 测试结果

| 接口 | 状态 | 说明 |
|------|------|------|
| `/mall/category/list` | ❌ 90000 | 不存在的资源 |
| `/ah/product/category` | ❌ 90000 | 不存在的资源 |
| `/ah/service/category` | ❌ 90000 | 不存在的资源 |
| `/spu/category` | ❌ 90000 | 不存在的资源 |
| `/category/list?type=1` | ✅ 可用 | 返回 9298 条分类数据 |
| `/category/top` | ✅ 可用 | 返回 26 条顶级分类 |

### 可用接口

| 功能 | 接口 | 说明 |
|------|------|------|
| 分类列表 | `GET /category/list?type=X` | type=1 商品，type=7 服务 |
| 顶级分类 | `GET /category/top` | 返回简化字段（id, name）|
| 分类详情 | `GET /category/detail` | 参数 `categoryID` |

### 结论

**商城分类接口 `/mall-category/list` 可用！**（之前误以为不可用）

新 App 分类选择方案：
1. 使用 `/mall-category/list` 获取商城分类（3级固定）
2. 通过 `pids` 字段构建分类树
3. 开单使用商城分类体系

---

## 七、总结

| 场景 | 推荐分类 | 接口 |
|------|----------|------|
| **商品选购（开单）** | 商城分类 (MallCategory) | `/mall-category/list` ✅ |
| 服务选择 | 进销存分类 (Category) | `/category/list?type=7` |
| SPU 选择 | 根据分类层级 | `/spu/list?mallCateIDs[]=` |

**关键点**：
1. 商城分类用 `pids` 数组表示层级关系
2. 进销存分类用 `pid` 单字段表示父子关系
3. SPU/商品在**任意层级**都可关联，根据业务需求决定

---

> 学习来源：
> - z1-mid: `src/types/category-types.ts`, `src/types/mall-category-types.ts`
> - z1-pwa: `src/components/mobile/SelectProduct.tsx`, `SelectService.tsx`