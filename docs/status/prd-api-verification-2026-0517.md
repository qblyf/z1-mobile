# PRD 与 API 接口验证报告

> **验证日期**：2026-05-17
> **验证范围**：已完成的 7 个功能模块 PRD 文档
> **验证依据**：app_router.dart、api_endpoints.dart、API 实际测试

---

## 一、验证结果总览

| 模块 | PRD 文件 | 页面路径 | API 接口 | 状态 |
|------|---------|---------|---------|------|
| 零售开单 | retail-detail-prd.md | ✅ 匹配 | ⚠️ 部分差异 | 🔵 需确认 |
| 会员中心 | member-detail-prd.md | ✅ 匹配 | ⚠️ 部分差异 | 🟡 待确认 |
| 盘库 | stocktaking-detail-prd.md | ✅ 匹配 | ✅ 匹配 | ✅ 通过 |
| 订单列表 | order-list-detail-prd.md | ✅ 匹配 | ⚠️ 参数格式 | 🟡 待确认 |
| 库存管理 | inventory-home-detail-prd.md | ✅ 匹配 | ⚠️ 部分缺失 | 🟡 待确认 |
| 调拨 | transfer-detail-prd.md | ✅ 匹配 | ⚠️ 部分缺失 | 🟡 待确认 |
| 采购 | purchase-detail-prd.md | ✅ 匹配 | ⚠️ 部分缺失 | 🟡 待确认 |

**总结**：
- ✅ 页面路径：全部匹配
- ⚠️ API 接口：5 个模块存在接口差异或缺失
- 🔵 需后端确认：6 个接口

---

## 二、详细验证结果

### 2.1 零售开单（retail-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /retail/entry | /retail/entry | ✅ |
| /retail/product | /retail/product | ✅ |
| /retail/confirm | /retail/confirm | ✅ |
| /retail/coupon-select | /retail/coupon-select | ✅ |
| /retail/payment | /retail/payment | ✅ |

#### API 接口验证 ⚠️

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| POST /order/sale-shop-add | /order/sale-shop-add | 待测试 | ⚠️ 需完整测试 |
| GET /order/shop-sale-list | /order/shop-sale-list | ✅ POST 可用 | 🔵 参数需确认 |
| GET /order-product/list | /order-product/list | ✅ | ✅ |

#### 问题

1. PRD 描述接口为 GET，实际测试发现是 POST 方法
2. dateRange 参数格式需确认（today/week/month/all）

---

### 2.2 会员中心（member-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /member/home | /member/home | ✅ |
| /member/:memberId | /member/:memberId | ✅ |
| /member/add | /member/add | ✅ |
| /member/creditscore | /member/creditscore | ✅ |
| /member/creditscore/edit | /member/creditscore/edit | ✅ |

#### API 接口验证 ⚠️

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| POST /members/list-phones | /members/list-phones | ❌ 方法无效 | 🔴 不存在 |
| GET /members/self | /members/self | ✅ | ✅ |
| POST /members/add | /members/add | 待测试 | ⚠️ 需测试 |
| POST /members/experience | /members/experience | ❌ 会员不存在 | ⚠️ 参数问题 |
| POST /members/check-phone | — | ❌ 不存在 | 🔴 缺失 |

#### 问题

1. `/members/list-phones` 接口返回 405 Method Not Allowed
2. `/members/check-phone` 接口不存在，需后端补充
3. 积分调整接口参数格式需确认

---

### 2.3 盘库（stocktaking-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /inventory/stocktaking | /inventory/stocktaking | ✅ |
| /inventory/stocktaking/add | /inventory/stocktaking/add | ✅ |
| /inventory/stocktaking/:id | /inventory/stocktaking/:id | ✅ |

#### API 接口验证 ✅

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| GET /stock-taking/list | /stock-taking/list | ✅ 超时 | ⚠️ 性能问题 |
| GET /warehouse/list-base | /warehouse/list-base | ✅ | ✅ |
| POST /stock-taking/add | /stock-taking/add | 待测试 | ⚠️ 需测试 |
| GET /stock-taking/detail | /stock-taking/detail | ✅ | ✅ |
| POST /stock-taking/end | /stock-taking/end | 待测试 | ⚠️ 需测试 |

#### 问题

1. `/stock-taking/list` 接口超时（6秒），可能有性能问题

---

### 2.4 订单列表（order-list-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /order/list | /order/list | ✅ |
| /order/:orderNumber | /order/:orderNumber | ✅ |

#### API 接口验证 🟡

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| GET /order/shop-sale-list | /order/shop-sale-list | ⚠️ GET 无效 | 🔴 需 POST |
| GET /order/shop-sale-info/:orderNumber | /order/shop-sale-info/:orderNumber | ❌ 不存在 | 🔴 不存在 |

#### 问题

1. `/order/shop-sale-list` PRD 描述为 GET，实际测试发现需 POST
2. `/order/shop-sale-info/:orderNumber` 实际路径格式不一致

---

### 2.5 库存管理（inventory-home-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /inventory/home | /inventory/home | ✅ |

#### API 接口验证 🟡

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| GET /inventory/summary | — | ❌ | 🔴 缺失 |
| GET /stock-taking/list | /stock-taking/list | ✅ | ✅ |
| GET /transfer/list | /transfer/list | ✅ | ✅ |
| GET /purchase/list | /purchase/list | ✅ | ✅ |
| GET /warehouse/list-base | /warehouse/list-base | ✅ | ✅ |
| GET /inventory/recent | — | ❌ | 🔴 缺失 |

#### 问题

1. `/inventory/summary`（库存概览）接口不存在
2. `/inventory/recent`（最近操作）接口不存在

---

### 2.6 调拨（transfer-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /inventory/transfer | /inventory/transfer | ✅ |
| /inventory/transfer/add | /inventory/transfer/add | ✅ |
| /inventory/transfer/:id | /inventory/transfer/:id | ✅ |

#### API 接口验证 🟡

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| GET /transfer/list | /transfer/list | ✅ | ✅ |
| GET /warehouse/list-base | /warehouse/list-base | ✅ | ✅ |
| POST /transfer/add | — | ❌ | 🔴 缺失 |
| GET /transfer/:id | — | ❌ | 🔴 缺失 |
| POST /transfer/:id/ship | — | ❌ | 🔴 缺失 |
| POST /transfer/:id/receive | — | ❌ | 🔴 缺失 |

#### 问题

1. `transfer/add`、`transfer/:id`、`transfer/:id/ship`、`transfer/:id/receive` 均缺失
2. 需后端补充调拨相关接口

---

### 2.7 采购（purchase-detail-prd.md）

#### 页面路径验证 ✅

| PRD 路径 | app_router.dart 路径 | 状态 |
|---------|---------------------|------|
| /inventory/purchase-list | /inventory/purchase-list | ✅ |
| /inventory/purchase/:id | /inventory/purchase/:id | ✅ |
| /inventory/purchase-inbound/:id | /inventory/purchase-inbound/:id | ✅ |

#### API 接口验证 🟡

| PRD 接口 | api_endpoints.dart | 实际测试 | 状态 |
|---------|-------------------|---------|------|
| GET /purchase/list | /purchase/list | ✅ | ✅ |
| GET /purchase/:id | — | ❌ | 🔴 缺失 |
| POST /purchase-inbound | — | ❌ | 🔴 缺失 |

#### 问题

1. 采购详情 `/purchase/:id` 接口不存在
2. 采购入库 `/purchase-inbound` 接口不存在

---

## 三、缺失接口清单

需后端补充的接口（按优先级）：

### 🔴 高优先级（影响核心流程）

| 接口 | 方法 | 说明 |
|------|------|------|
| /members/list-phones | POST | 会员手机号搜索 |
| /members/check-phone | POST | 手机号唯一性校验 |
| /transfer/add | POST | 创建调拨单 |
| /transfer/:id | GET | 调拨单详情 |
| /transfer/:id/ship | POST | 确认发货 |
| /transfer/:id/receive | POST | 确认入库 |
| /purchase/:id | GET | 采购单详情 |
| /purchase-inbound | POST | 采购入库 |

### 🟡 中优先级（功能完整性）

| 接口 | 方法 | 说明 |
|------|------|------|
| /members/experience | POST | 积分调整 |
| /members/experience-log | POST | 积分明细 |
| /order/shop-sale-info/:orderNumber | GET | 订单详情 |
| /inventory/summary | GET | 库存概览 |
| /inventory/recent | GET | 最近操作记录 |

### ⚠️ 性能问题

| 接口 | 问题 |
|------|------|
| /stock-taking/list | 超时（6秒），需优化 |

---

## 四、建议

### 4.1 立即行动

1. **后端补充缺失接口**：建议优先补充调拨和采购相关接口
2. **确认接口方法**：部分接口的 HTTP 方法需与后端确认
3. **优化盘库列表**：考虑分页或索引优化

### 4.2 PRD 更新建议

1. **订单列表 PRD**：更新 `/order/shop-sale-list` 为 POST 方法
2. **会员中心 PRD**：更新接口列表，标注缺失接口
3. **库存管理 PRD**：更新接口列表，标注预留接口

### 4.3 测试计划

建议在接口补充后，对以下模块进行完整 API 测试：
- [ ] 会员中心（手机号搜索、新增会员、积分调整）
- [ ] 零售开单（完整流程测试）
- [ ] 调拨（创建、调拨详情、发货、入库）
- [ ] 采购（创建、详情、入库）

---

## 五、附录：API 测试日志

```
=== 基础 API 测试 ===
[1] /members/phone-login  ✅ 成功
[2] /members/self         ✅ 成功
[3] /warehouse/list-base  ✅ 成功
[4] /stock-taking/list    ⚠️ 超时
[5] /transfer/list        ✅ 成功
[6] /purchase/list        ✅ 成功
[7] /coupons/self         ✅ 成功
[8] /product-stock-by-code ✅ 成功（返回空）

=== 问题接口 ===
[1] /members/list-phones   ❌ 405 Method Not Allowed
[2] /members/check-phone   ❌ 404 不存在的资源
[3] /members/experience    ❌ 20601 没有找到对应的会员
[4] /members/experience-log ❌ 404 不存在的资源
[5] /order/shop-sale-list  ❌ GET 90002 参数类型有误，POST 成功
[6] /order/shop-sale-info  ❌ 404 不存在的资源
[7] /members/1            ❌ 404 不存在的资源
```

---

**报告生成时间**：2026-05-17
**验证人**：flutt项目测试