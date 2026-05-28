# API 接口核查报告

> Flutter 开发 agent 在开发过程中发现的接口差异，基于对比后端源码（z1-deno/src/data/）和 Flutter 代码得出。
> 最后更新：2026-05-28

---

## 核查方法

1. 读取后端源码：`/Users/fan/www/AI/z1/z1-deno/src/data/` + `/Users/fan/www/AI/z1/z1-deno/src/pages/`
2. 读取 Flutter 类型文件：`z1_mobile/lib/types/api/`（SDK 类型定义）
3. 对比 Flutter datasource 代码中的字段假设

---

## 🔴 严重差异（可能导致功能错误）

### 1. `/spu/list` 返回 `skuIDs` 但 Flutter 期望 `skus: SkuModel[]`

| 维度 | 后端实际 | Flutter 假设 |
|------|---------|-------------|
| 字段名 | `skuIDs` | `skuList` |
| 类型 | `number[]`（ID 数组） | `SkuModel[]`（完整对象数组） |

**后果**：Flutter `SpuModel.fromJson` 把每个 ID 当成 SkuModel 解析，`skuName` 和 `price` 等字段全为空。但价格通过 `getSpuListByMallCate` 中的 `getProductPriceList` 补救。

**建议**：要么改 Flutter 端解析逻辑，要么后端返回完整 SKU 对象。

---

### 2. `/product/sku-by-spu` 响应格式 vs Flutter 期望

| 维度 | 后端实际 | Flutter 期望 |
|------|---------|-------------|
| 响应结构 | `{ spu, services, defaultService, skus, recommend }` | `List<SkuModel>` |
| sku.id | `number` | `skuId` |
| sku.name | `string` | `skuName` |
| sku.price | `number \| null` | `price` |
| sku.thumbnail | `string` | `image` |
| sku.stock | `number` | `stock` |
| sku.virtualStock | `number` | 无 |
| sku.isAllowance | `boolean` | 无 |

**后果**：`getSkuBySpu` 把整个响应传给 `SkuModel.fromJson`，但后端返回的是嵌套对象而非 sku 数组。这可能是 `minified:a30` 错误的来源之一。

**建议**：Flutter 需要正确解析 `res.skus[]` 数组中的每个 sku 对象，并映射字段名。

---

## 🟡 中等差异（可能导致数据丢失）

### 3. `/product/list` 响应字段

| 维度 | 后端实际 | Flutter 期望 |
|------|---------|-------------|
| 商品数组位置 | `list`（顶层） | `data`（嵌套） |
| fallback | — | `list`（已加） |

Flutter 已加 fallback 到 `list`，**目前应该能正常工作**，但逻辑上更干净的做法是直接用 `list`。

---

### 4. `/product/select-base` vs `/sku/select-base` ✅ 已确认一致

- **Flutter 使用**：`/sku/select-base`
- **后端实现**：两个路由都调用同一个函数 `getSelectSKUBaseData`
- **结论**：返回字段完全一致，无需修改

---

### 5. 后端返回但 Flutter 未处理的字段

| 后端字段 | 类型 | Flutter 状态 |
|---------|------|------------|
| `salesState` | string | ❌ 未存储 |
| `virtualStock` | number | ❌ 未存储 |
| `isAllowance` | boolean | ❌ 未存储 |
| `gtins` | string[] | ❌ 未存储 |
| `privateBarcode` | string | ❌ 未存储 |
| `shortName` | string | ✅ 已处理 |
| `recommend` | SPU[] | ❌ 未存储 |

---

### 6. `/spu/list` 的 `skuIDs` 与 `skus` 混用

Flutter `getSpuListByMallCate` 的流程：
1. 调用 `/spu/list` → 得到 `SkuModel[]`（其中 skus 只有 ID，name/price 为空）
2. 批量调用 `getProductPriceList` → 填充 `retailPrice`
3. 但 `skuName` 仍然为空

这在零售开单场景下**不影响核心功能**（价格正确），但 SKU 名称显示可能有问题。

---

## 🟢 已确认一致

| API | 状态 |
|-----|------|
| `/spu/list` 参数 `mallCateIDs` | ✅ Flutter 已修复 |
| `/sku/select-base` 返回 `mallThirdCate: number[]` | ✅ 已确认 |
| `/mall-category/list` 响应 | ✅ 字段匹配 |
| `/order/shop-sale-list` | ✅ 未发现差异 |

---

## 待行动

- [ ] 文档助手：确认 `/product/select-base` vs `/sku/select-base` 是否一致
- [ ] Flutter：修复 `/product/sku-by-spu` 响应解析逻辑（当前解析整个响应而非 `res.skus[]`）
- [ ] Flutter：考虑是否需要存储 `salesState`、`virtualStock` 等字段
- [ ] 需要实际调接口（curl）验证响应结构

---

## 关键后端类型参考

### SPU 类型（/spu/list）
```
id, name, images: { thumbnail, mainImages[], detailsImages[] },
skuIDs: number[], mallThirdCate: number[],
salesState, recycleState, brand, series, generation,
minPrice, maxPrice, weight, shortName, modelCode,
createdAt, updatedAt, showInMiniProgram, isCoin, ...
```

### SKU 类型（/product/sku-by-spu 返回的 skus）
```
id, name, price, thumbnail, listPrice,
stock, virtualStock, isAllowance, bindServices
```

### /sku/select-base 返回字段
```
skuID, skuName, gtins, privateBarcode, hasSerial,
spuName, spuID, spuCateChain[], spuCateID,
weight, spell, brand, series, generation,
state, salesState, mallThirdCate[], modelCode
```
