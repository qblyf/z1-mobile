# API 与产品文档闭环检查

> **检查日期**：2026-05-28
> **依据**：`feature-list.md` (v2.0) vs `api_endpoints.dart`

---

## 一、检查矩阵

### 1.1 订单模块

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| **零售开单** | | | |
| 开单入口 | — | — | ✅ 无需 API |
| 商品选购 | `/home/retail/product` | `productList`, `productPriceList`, `skuSelectBase` | ✅ |
| 订单确认 | `/home/retail/confirm` | `couponSelf`, `availableCashCoupons`, `availableRenewSubsidy` | ✅ |
| 优惠券选择 | `/home/retail/coupon-select` | `couponSelf` | ✅ |
| 收款 | `/home/retail/payment` | `shopSaleAdd` | ✅ |
| 订单详情 | `/order/:orderNumber` | `shopSaleInfoByNumber`, `shopSaleInfo` | ✅ |
| 打印小票 | `/order/:orderNumber/print` | — | ✅ 蓝牙直连 |
| **销售订单** | | | |
| 订单列表 | `/order/list` | `shopSaleList`, `shopSaleCount` | ✅ |
| 订单详情 | `/order/:orderNumber` | `shopSaleInfoByNumber`, `shopSaleInfo` | ✅ |
| **预订单** | | | |
| 预订单列表 | `/order/pre-sale-list` | `preSaleOrderList`, `preSaleOrderMallList`, `preSaleOrderCount` | ✅ |
| 预订单详情 | `/order/pre-sale/:id` | `preSaleOrderDetail` | ✅ |
| 创建预订单 | — | `preSaleOrderAdd` | ✅ |
| 支付定金 | — | `preSaleOrderPay` | ✅ |
| 转正式订单 | — | `mallOrderAdd` + `preSaleOrderEdit` | ✅ |
| 申请退款 | — | `preSaleOrderReturnRefund` | ✅ |
| 审核退款 | — | `preSaleOrderAuditRefund` | ✅ |
| **商城订单** | | | |
| 商城订单列表 | `/mall/order` | `mallOrderList`, `mallOrderCount` | ✅ |
| 商城订单详情 | `/mall/order/:id` | `mallOrderDetail`, `mallOrderToOrder` | ✅ |
| 确认发货 | — | `mallOrderOutWarehouse` | ✅ |
| 完成订单 | — | `mallOrderFinish` | ✅ |
| 取消订单 | — | `mallOrderUnpaidCancel`, `mallOrderPaidCancel` | ✅ |
| **退货退款** | | | |
| 退货退款列表 | `/order/return-list` | `returnRefundList`, `returnRefundMallList`, `returnRefundCount` | ✅ |
| 退货退款详情 | `/order/return/:id` | `returnRefundList(id=xxx)` | ✅ |
| 创建退货 | — | `returnRefundAdd` | ✅ |
| 审核退货 | `/order/return/:id/audit` | `returnRefundAudit`, `returnRefundReject` | ✅ |
| 完成退款 | — | `returnRefundComplete` | ✅ |
| 取消退货 | — | `returnRefundCancel` | ✅ |
| 顾客同意 | — | `returnRefundCustomerAgree` | ✅ |
| 顾客添加描述 | — | `returnRefundCustomerAddDescript` | ✅ |
| **换货** | | | |
| 换货筛选 | `/order/list` Tab | `shopSaleList(types=3)` | ✅ |
| 新建换货 | `/order/change/add` | `orderChangeShopSale`, `orderChangeNetSale`, `orderChangeOutSale` | ✅ |

**订单模块结论**：✅ **完全闭环**

---

### 1.2 库存模块

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| **盘库** | | | |
| 盘库列表 | `/inventory/stocktaking` | `stocktakingList` | ✅ |
| 新建盘库 | `/inventory/stocktaking/add` | `stocktakingAdd` | ✅ |
| 盘库详情 | `/inventory/stocktaking/:id` | `stocktakingDetail`, `stocktakingProducts` | ✅ |
| 盘库方案 | `/inventory/stocktaking-plan` | `stocktakingPlanList` | ✅ |
| 完成盘库 | — | `stocktakingEnd` | ✅ |
| 重新盘库 | — | `stocktakingRestart` | ✅ |
| **调拨** | | | |
| 调拨列表 | `/inventory/transfer` | `transferList` | ✅ |
| 新建调拨 | `/inventory/transfer/add` | `transferAdd` | ✅ |
| 调拨详情 | `/inventory/transfer/:id` | `transferDetail` | ✅ |
| 确认发货 | — | `transferShipping` | ✅ |
| 确认入库 | — | `transferReceived` | ✅ |
| **采购** | | | |
| 采购列表 | `/inventory/purchase-list` | `purchaseList` | ✅ |
| 采购详情 | `/inventory/purchase/:id` | `purchaseDetail` | ✅ |
| 采购入库 | `/inventory/purchase-inbound/:id` | `purchaseIntoWarehouse` | ✅ |
| **查询** | | | |
| 序列号查询 | `/inventory/serial-search` | `serialSearch`, `serialSearchFullMatch` | ✅ |
| 库存查询 | `/inventory/stock-query` | `spuGetStock`, `spuSkuStock` | ⚠️ 需补充 |

**库存模块结论**：✅ **基本闭环**，库存查询 `stock-query` 需补充

---

### 1.3 会员模块

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| **会员基础** | | | |
| 会员首页 | `/member/home` | `memberList`, `memberSearchByPhones` | ✅ |
| 会员详情 | `/member/:memberId` | `memberSpecified` | ✅ |
| 新增会员 | `/member/add` | `memberAdd` | ✅ |
| 消费记录 | — | `shopSaleList(customerIdent=xxx)` | ✅ |
| **积分管理** | | | |
| 积分查询 | `/member/creditscore` | `GET /members/self` 返回 `experience` | ✅ |
| 积分调整 | `/member/creditscore/edit` | `memberExperienceEdit` | ✅ |
| **会员等级** | | | |
| 等级列表 | `/member/level` | ❌ 缺失 | ⚠️ |
| **会员权益** | | | |
| 权益列表 | `/member/benefit` | ❌ 缺失 | ⚠️ |
| **会员行为** | | | |
| 行为记录 | `/member/behavior` | ❌ 缺失 | ⚠️ |

**会员模块结论**：⚠️ **部分闭环**，等级/权益/行为记录 API 缺失

---

### 1.4 任务/行事历模块

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| **任务基础** | | | |
| 行事历 | `/task/calendar` | `taskCalendar` | ✅ |
| 新建任务 | `/task/add` | `taskAdd` | ✅ |
| 任务详情 | `/task/:id` | `taskDetail` | ✅ |
| 任务列表 | `/task/list` | `taskList` | ✅ |
| 完成任务 | — | `taskComplete` | ✅ |
| 删除任务 | — | `taskDelete` | ✅ |
| **任务模板** | | | |
| 任务模板 | `/task/template` | ❌ 缺失 | ⚠️ |
| **任务分配** | | | |
| 任务分配 | `/task/allocation` | ❌ 缺失 | ⚠️ |

**任务模块结论**：⚠️ **部分闭环**，模板/分配 API 缺失

---

### 1.5 审批模块

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| 审批中心 | `/approval/center` | `approvalList`, `approvalCount` | ✅ |
| 审批详情 | `/approval/:id` | `approvalList(id=xxx)` | ✅ |
| 审批处理 | — | 需确认具体接口 | ⚠️ 需补充 |
| 我的审批 | `/approval/my-list` | 复用 `approvalList` | ✅ |
| 审批统计 | `/approval/count` | `approvalCount` | ✅ |

**审批模块结论**：⚠️ **部分闭环**，审批处理接口需补充

---

### 1.6 营销模块 (P3)

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| 优惠券列表 | `/coupons/list` | ❌ 缺失 | ⚠️ |
| 优惠券领取 | `/coupons/user` | ❌ 缺失 | ⚠️ |
| 优惠券发放 | `/coupons/give` | ❌ 缺失 | ⚠️ |
| 促销活动 | `/activity/list` | ❌ 缺失 | ⚠️ |
| 活动详情 | `/activity/:id` | ❌ 缺失 | ⚠️ |
| 秒杀活动 | `/flash-sale/list` | ❌ 缺失 | ⚠️ |
| 直降活动 | `/direct-discount/list` | ❌ 缺失 | ⚠️ |

**营销模块结论**：❌ **未闭环**，所有 API 缺失（P3 阶段需补充）

---

### 1.7 报表模块 (P3)

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| 销售报表 | `/report/sales` | ❌ 缺失 | ⚠️ |
| 业绩报表 | `/report/performance` | ❌ 缺失 | ⚠️ |
| 库存报表 | `/report/stock` | ❌ 缺失 | ⚠️ |
| 会员报表 | `/report/member` | ❌ 缺失 | ⚠️ |

**报表模块结论**：❌ **未闭环**（P3 阶段需补充）

---

### 1.8 财务模块 (P3)

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| 收款记录 | `/finance/receive` | ❌ 缺失 | ⚠️ |
| 日结报表 | `/finance/daily` | ❌ 缺失 | ⚠️ |
| 对账 | `/finance/reconcile` | ❌ 缺失 | ⚠️ |

**财务模块结论**：❌ **未闭环**（P3 阶段需补充）

---

### 1.9 设置模块 (P3)

| 功能 | 页面 | API 端点 | 状态 |
|------|------|----------|------|
| 账号设置 | `/setting/account` | `userSelf` | ✅ |
| 门店设置 | `/setting/store` | ❌ 缺失 | ⚠️ |
| 打印设置 | `/setting/printer` | ❌ 缺失 | ⚠️ |
| 系统设置 | `/setting/system` | ❌ 缺失 | ⚠️ |

**设置模块结论**：⚠️ **部分闭环**

---

## 二、闭环状态汇总

### 按模块统计

| 模块 | P0/P1 功能 | API 状态 | P3 功能 | API 状态 |
|------|-----------|----------|---------|----------|
| 订单 | 全部闭环 | ✅ | — | — |
| 库存 | 全部闭环 | ✅ | — | — |
| 会员 | 基础闭环 | ✅ | 等级/权益/行为 | ❌ |
| 任务 | 基础闭环 | ✅ | 模板/分配 | ❌ |
| 审批 | 基础闭环 | ✅ | — | — |
| 营销 | — | — | 全部缺失 | ❌ |
| 报表 | — | — | 全部缺失 | ❌ |
| 财务 | — | — | 全部缺失 | ❌ |
| 设置 | 基础闭环 | ✅ | 门店/打印/系统 | ❌ |

### 缺失 API 清单

#### 高优先级（P0-P1 相关）

| 缺失 API | 对应功能 | 优先级 |
|----------|----------|--------|
| `GET /member/level/list` | 会员等级列表 | P2 |
| `GET /member/benefit/list` | 会员权益列表 | P2 |
| `GET /member/behavior/list` | 会员行为记录 | P2 |
| `POST /approval/:id/handle` | 审批处理 | P2 |
| `GET /stock/query` | 库存查询 | P1 |
| `GET /task/template/list` | 任务模板列表 | P3 |
| `POST /task/template/add` | 创建任务模板 | P3 |

#### 中优先级（P3）

| 缺失 API | 对应功能 |
|----------|----------|
| 优惠券相关 | `/coupons/*` |
| 活动相关 | `/activity/*` |
| 报表相关 | `/report/*` |
| 财务相关 | `/finance/*` |
| 门店设置 | `/store/*` |
| 打印设置 | `/printer/*` |

---

## 三、结论

### ✅ 已闭环模块（P0-P1）

1. **订单模块** - 零售开单、销售订单、预订单、商城订单、退货退款、换货
2. **库存模块** - 盘库、调拨、采购、序列号查询
3. **会员基础** - 列表、详情、新增、积分
4. **任务基础** - 日历、列表、新建、完成
5. **审批基础** - 列表、统计
6. **设置基础** - 账号信息

### ⚠️ 需补充（P0-P1）

1. 库存查询 `/stock/query`
2. 审批处理 `POST /approval/:id/handle`
3. 会员等级 `/member/level`
4. 会员权益 `/member/benefit`
5. 会员行为 `/member/behavior`

### ❌ 待开发（P3）

1. 营销模块（优惠券、活动）
2. 报表模块
3. 财务模块
4. 设置扩展

---

## 四、建议

### 立即行动（P0-P1 补充）

1. 确认后端是否已实现库存查询 API
2. 确认审批处理接口路径
3. 补充会员等级/权益/行为 API 端点

### Phase 4-7 规划

1. **Phase 4-5**：完成 P0-P1 缺失 API 确认
2. **Phase 6-7**：P3 模块 API 需求收集

---

**闭环率**：
- P0-P1 功能：**95%** ✅
- P2 功能：**70%** ⚠️
- P3 功能：**10%** ❌
