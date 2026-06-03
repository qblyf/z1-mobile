# API 与产品文档闭环检查

> **版本**：v2.1
> **检查日期**：2026-05-29
> **依据**：`api_endpoints.dart`（71 端点）vs 23 个 PRD（含新建 auth-prd）
> **闭环度**：✅ **100%**（71/71）

---

## 〇、闭环结果

```
═══ 三维总校验 ═══
✅ 7 维度审查：23 个 PRD 全部通过
✅ 类型文件引用：18 个类型文件全部对齐
✅ API 端点闭环：71/71（100%）
```

完成于 v1.25（2026-05-29）。详见 [changelog v1.25](../status/changelog.md)。

---

## 一、检查方法

1. 从 `z1_mobile/lib/core/api/api_endpoints.dart` 提取所有真实端点（71 个）
2. 扫描 `docs/features/*-prd.md` 中所有反引号包裹的路径，归一化后比对
3. 双向对比：
   - 代码有 / PRD 未提：19 个（说明 PRD 不完整）
   - PRD 提到 / 代码未实现：约 60 个（多数是规划中或后端未开发）

---

## 二、按模块汇总

### 2.1 订单（订单/退货/预订单/商城订单/换货）

| 子模块 | 端点数 | PRD 覆盖 | 状态 |
|--------|-------|---------|------|
| 销售订单 | 5 | 5/5 | ✅ 完全闭环 |
| 退货退款 | 10 | 10/10 | ✅ 完全闭环 |
| 预订单 | 9 | 9/9 | ✅ 完全闭环 |
| 商城订单 | 9 | 8/9（mallOrderAdd 在 pre-sale-order）| ✅ 闭环 |
| 换货 | 3 | 3/3 | ✅ 完全闭环 |

**结论**：订单模块 36 个端点全部有 PRD 引用 ✅

---

### 2.2 商品 / 服务 / 分类

| 子模块 | 端点数 | PRD 覆盖 | 状态 |
|--------|-------|---------|------|
| 商品 | 6 | 5/6（productBarcode 遗留无 PRD）| ⚠️ |
| SKU/SPU | 4 | 3/4（skuBySpu 缺 PRD 引用）| ⚠️ |
| 分类 | 4 | 2/4（categoryTop / mallCategoryList 缺）| ❌ |
| 服务 | 1 | 1/1 | ✅ |

**结论**：分类模块缺关键引用 —— `mallCategoryList` 是开单核心接口但未在 category-select-prd 中显式标注。

---

### 2.3 优惠 / 补贴 / 回收

| 子模块 | 端点数 | PRD 覆盖 | 状态 |
|--------|-------|---------|------|
| 优惠券 | 1 | 1/1 | ✅ |
| 代金券 | 2 | 0/2 | ❌ 完全未文档化 |
| 换新补贴 | 3 | 0/3 | ❌ 完全未文档化 |
| 回收单 | 2 | 0/2 | ❌ 完全未文档化 |
| 积分兑换 | 1 | 0/1 | ❌ |

**结论**：优惠/补贴/回收子领域代码已实现 9 个端点，PRD 完全未涉及 —— 需要在 retail-detail-prd 中补充或新建独立 PRD。

---

### 2.4 会员

| 端点数 | PRD 覆盖 | 状态 |
|-------|---------|------|
| 6 | 6/6 | ✅ 完全闭环 |

---

### 2.5 库存

| 子模块 | 端点数 | PRD 覆盖 | 状态 |
|--------|-------|---------|------|
| 仓库 | 1 | 1/1 | ✅ |
| 盘库 | 7 | 3/7（end / restocktaking / products / plan-list 缺）| ❌ |
| 采购 | 3 | 3/3 | ✅ |
| 调拨 | 5 | 4/5（transferReceived 缺）| ⚠️ |
| 序列号查询 | 2 | 2/2 | ✅ |

**结论**：盘库子模块缺失严重 —— 完成盘库 / 重盘 / 商品列表 / 方案列表 4 个核心接口 stocktaking-detail-prd 未引用。

---

### 2.6 任务 / 审批

| 子模块 | 端点数 | PRD 覆盖 | 状态 |
|--------|-------|---------|------|
| 任务 | 6 | 6/6 | ✅ |
| 审批 | 2 | 2/2 | ✅ |

**结论**：任务和审批基础接口闭环 ✅。但 PRD 中提及的 `/discount-log/audit` / `/price-adjustment/audit` / `/purchase-order/unaudit-to-audit` 等审批操作接口在代码中**未找到** —— 待向后端确认。

---

### 2.7 认证

| 端点数 | PRD 覆盖 | 状态 |
|-------|---------|------|
| 3 | 0/3 | ❌ 无 auth-prd |

**结论**：登录 / refresh-token / logout 三个端点没有任何 PRD 文档化。建议新建 `auth-prd.md` 或在 `profile-detail-prd` 中补充登录登出流程。

---

## 三、汇总指标

### 3.1 闭环度

| 指标 | 数值 |
|------|------|
| 代码端点总数 | 71 |
| 有 PRD 引用 | 52（73%） |
| 无 PRD 引用 | 19（27%） |
| **闭环率** | **73%** |

### 3.2 模块完整度

| 模块 | 状态 |
|------|------|
| 订单 | ✅ 100% |
| 会员 | ✅ 100% |
| 任务 | ✅ 100% |
| 审批 | ✅ 100% |
| 序列号 | ✅ 100% |
| 商品 | ⚠️ 83% |
| SKU/SPU | ⚠️ 75% |
| 调拨 | ⚠️ 80% |
| 分类 | ❌ 50% |
| 盘库 | ❌ 43% |
| 优惠/补贴/回收 | ❌ 12% |
| 认证 | ❌ 0% |

---

## 四、缺失 19 个端点的修复建议

### P0 高优先级（业务核心，需立即补 PRD）

| 端点 | 模块 | 建议归属 PRD |
|------|------|------------|
| `/mall-category/list` | 商城分类 | category-select-prd |
| `/cash-coupon/available` | 代金券 | retail-detail-prd |
| `/cash-coupon/list` | 代金券 | retail-detail-prd |
| `/renew-subsidy/available` | 换新补贴 | retail-detail-prd |
| `/coupon-class/list` | 换新补贴 | retail-detail-prd |
| `/ahs/allow-bind` | 回收单 | retail-detail-prd |
| `/ahs/check/:id` | 回收单 | retail-detail-prd |
| `/points-redeem/order/to-mall-order` | 积分兑换 | mall-order-prd |
| `/stock-taking/end` | 完成盘库 | stocktaking-detail-prd |
| `/stock-taking/restocktaking` | 重盘 | stocktaking-detail-prd |
| `/stock-taking/:id/products` | 盘库商品 | stocktaking-detail-prd |
| `/stock-taking-plan/list` | 盘库方案 | stocktaking-detail-prd |
| `/transfer-lock/received` | 调拨入库 | transfer-detail-prd |

### P1 中优先级

| 端点 | 建议归属 PRD |
|------|------------|
| `/category/top` | category-select-prd |
| `/product/sku-by-spu` | category-select-prd |

### P2 系统级

| 端点 | 建议 |
|------|------|
| `/members/phone-login` | 新建 auth-prd 或并入 profile-detail-prd |
| `/auth/refresh-token` | 同上 |
| `/auth/logout` | 同上 |
| `/product/barcode/:code` | 标注为遗留接口 |

---

## 五、PRD 提及但代码未实现的端点

### 5.1 应该实现但代码缺失

| 端点 | PRD | 处理建议 |
|------|-----|---------|
| `/mall-order/list` 等商城订单接口 | mall-order-prd | mall-order-types.dart 已就绪，端点应已实现 |
| `/discount-log/audit` | approval-center-detail-prd | 后端确认 |
| `/price-adjustment/audit` | approval-center-detail-prd | 后端确认 |
| `/purchase-order/unaudit-to-audit` | approval-center-detail-prd | 后端确认 |
| `/member-level/detail-or-all` | member-detail-prd | 后端已确认，前端未集成 |

### 5.2 P3 阶段（feature-list 规划中）

营销、报表、财务模块的所有接口（约 30+）属于 P3 规划，不计入闭环度统计。

---

## 六、行动清单

### 立即（P0，预计 30 分钟）

- [ ] retail-detail-prd 增补 cash-coupon / renew-subsidy / ahs 共 7 个端点引用
- [ ] stocktaking-detail-prd 增补 stock-taking-end / restocktaking / products / plan-list
- [ ] category-select-prd 增补 mall-category / category-top / sku-by-spu
- [ ] transfer-detail-prd 增补 transfer-lock/received
- [ ] mall-order-prd 增补 points-redeem 引用

完成后闭环度可从 73% → **96%**（68/71）。

### 短期（P1）

- [ ] 新建 `auth-prd.md`（认证 3 端点）→ 100% 闭环
- [ ] 补充 mall-order 接口的代码核查
- [ ] approval 操作接口后端确认

---

## 七、与上一版（v1.0）的差异

| 维度 | v1.0（5/28） | v2.0（5/29） |
|------|-------------|-------------|
| 数据来源 | feature-list（规划） | api_endpoints.dart（代码事实）|
| 端点总数 | 未明确 | 71 |
| 闭环率 | P0-P1: 95% / P2: 70% | 73%（按代码端点） |
| 准确性 | 部分判定与现实不符 | 与代码 1:1 对齐 |

v1.0 报告的「需补充」清单已部分过时（例如 `/stock/query` 实际是 `/spu/get-stock`，已在代码中），v2.0 重新对齐。

---

> 下次更新触发条件：`api_endpoints.dart` 新增/删除端点，或 PRD 新增模块时
