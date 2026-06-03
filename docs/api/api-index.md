# API 端点总索引

> **版本**：v1.0
> **日期**：2026-05-29
> **依据**：`z1_mobile/lib/core/api/api_endpoints.dart`（71 个端点）+ 22 个 PRD

> **⚠️ 唯一真实源**：端点路径以 `api_endpoints.dart` 为准。本文档由代码反推生成。

---

## 〇、总览

| 维度 | 数量 |
|------|------|
| 代码端点总数 | 71 |
| 有 PRD 引用 | 52（73%）|
| 无 PRD 引用 | 19（27%）|
| 模块分组 | 24 |

详见：
- 闭环检查报告：[`api-product-closure-check.md`](./api-product-closure-check.md)
- 订单接口规范：[`order-api-reference.md`](./order-api-reference.md)
- 订单调用示例：[`order-api-examples.md`](./order-api-examples.md)

---

## 一、订单模块

### 1.1 销售订单

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `shopSaleAdd` | POST `/order/sale-shop-add` | 创建零售单 | retail-detail / print-receipt |
| `shopSaleList` | GET `/order/shop-sale-list` | 零售单列表 | order-list-detail / home-detail |
| `shopSaleCount` | GET `/order/shop-sale-count` | 零售单数量 | order-list-detail |
| `shopSaleInfo` | GET `/order-product/details-by-order-id` | 订单商品列表 | order-list-detail |
| `shopSaleInfoByNumber` | GET `/order/shop-sale-list?number=xxx` | 按单号查订单 | order-list-detail |

### 1.2 退货退款

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `returnRefundList` | GET `/return-refund-application/list` | 退货退款列表（门店） | return-refund |
| `returnRefundMallList` | GET `/return-refund-application/mall` | 退货退款列表（商城） | return-refund |
| `returnRefundCount` | GET `/return-refund-application/count` | 退货数量 | return-refund |
| `returnRefundAdd` | POST `/return-refund-application/add` | 创建退货 | return-refund |
| `returnRefundAudit` | POST `/return-refund-application/audit` | 审核退货 | return-refund / approval-center |
| `returnRefundComplete` | POST `/return-refund-application/complete` | 完成退款 | return-refund |
| `returnRefundReject` | POST `/return-refund-application/reject-audit` | 驳回退货 | return-refund / approval-center |
| `returnRefundCancel` | POST `/return-refund-application/cancel` | 取消退货 | return-refund |
| `returnRefundCustomerAgree` | POST `/return-refund-application/customer/agree` | 顾客同意 | return-refund |
| `returnRefundCustomerAddDescript` | POST `/return-refund-application/customer/add-descript` | 顾客补充描述 | return-refund |

### 1.3 预订单

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `preSaleOrderList` | GET `/pre-sale-order/list` | 预订单列表（门店） | pre-sale-order |
| `preSaleOrderMallList` | GET `/pre-sale-order/mall-list` | 预订单列表（商城） | pre-sale-order |
| `preSaleOrderCount` | GET `/pre-sale-order/count` | 预订单数量 | pre-sale-order |
| `preSaleOrderDetail` | GET `/pre-sale-order/mall-detail` | 预订单详情 | pre-sale-order |
| `preSaleOrderAdd` | POST `/pre-sale-order/add` | 创建预订单 | pre-sale-order |
| `preSaleOrderEdit` | POST `/pre-sale-order/edit` | 编辑/转正式订单 | pre-sale-order |
| `preSaleOrderPay` | POST `/pre-sale-order/pay` | 支付定金 | pre-sale-order |
| `preSaleOrderReturnRefund` | POST `/pre-sale-order/return-refund` | 申请退款 | pre-sale-order |
| `preSaleOrderAuditRefund` | POST `/pre-sale-order/audit-return-refund` | 审核退款 | pre-sale-order |

### 1.4 商城订单

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `mallOrderList` | GET `/mall-order/list` | 商城订单列表 | mall-order |
| `mallOrderCount` | GET `/mall-order/count` | 商城订单数量 | mall-order |
| `mallOrderAdd` | POST `/mall-order/add` | 创建商城订单 | pre-sale-order |
| `mallOrderDetail` | GET `/mall-order/detail` | 商城订单详情 | mall-order |
| `mallOrderToOrder` | GET `/mall-order/order-mall-order-detail` | 门店视角订单详情 | mall-order |
| `mallOrderOutWarehouse` | POST `/mall-order/outed-of-warehouse` | 确认发货 | mall-order |
| `mallOrderFinish` | POST `/mall-order/finish` | 完成订单 | mall-order |
| `mallOrderUnpaidCancel` | POST `/mall-order/unpaid-cancel` | 待支付取消 | mall-order |
| `mallOrderPaidCancel` | POST `/mall-order/paid-cancel` | 已支付取消 | mall-order |

### 1.5 换货

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `orderChangeShopSale` | POST `/order-change/add/shop-sale` | 门店换货 | order-change |
| `orderChangeNetSale` | POST `/order-change/add/net-sale` | 网销换货 | order-change |
| `orderChangeOutSale` | POST `/order-change/add/out-sale` | 批发换货 | order-change |

---

## 二、商品/服务/分类

### 2.1 商品

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `productList` | GET `/product/list` | 商品列表 | retail-detail / order-list-detail |
| `productListBySpuId` | GET `/product/list?spuId=xxx` | 含 hasSerial 的商品列表 | retail-detail |
| `productSelectBase` | GET `/sku/select-base` | 商品选择基础数据 | product-service-select |
| `productSelect` | GET `/product/select?ids=xxx` | 批量查询商品 | order-list-detail |
| `productPriceList` | GET `/product-price/list` | 商品价格列表 | retail-detail |
| `productBarcode` | GET `/product/barcode/:code` | 条码查商品（遗留）| ⚠️ 无 PRD |

### 2.2 SKU / SPU 库存

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `skuSelectBase` | GET `/sku/select-base` | SKU 选择基础数据 | product-service-select |
| `skuBySpu` | GET `/product/sku-by-spu` | SPU 下的 SKU 列表 | ⚠️ 无 PRD |
| `spuGetStock` | POST `/spu/get-stock` | SPU 总库存 | category-select |
| `spuSkuStock` | GET `/spu/sku-stock` | SKU 库存 | category-select |

### 2.3 分类

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `categoryList` | GET `/category/list` | 进销存分类树 | category-select |
| `categoryTop` | GET `/category/top` | 顶级分类 | ⚠️ 无 PRD |
| `mallCategoryList` | GET `/mall-category/list` | 商城分类（3 级） | ⚠️ 无 PRD |
| `spuList` | GET `/spu/list` | SPU 列表（按分类） | product-service-select |

### 2.4 服务

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `serveList` | GET `/serve/list` | 服务列表 | service-select / product-service-select |

---

## 三、优惠/补贴

### 3.1 优惠券

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `couponSelf` | GET `/coupons/self` | 会员优惠券列表 | retail-detail |

### 3.2 代金券

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `availableCashCoupons` | GET `/cash-coupon/available` | 可用代金券（开单用） | ⚠️ 无 PRD |
| `cashCouponList` | GET `/cash-coupon/list` | 会员持有代金券 | ⚠️ 无 PRD |

### 3.3 换新补贴

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `availableRenewSubsidy` | GET `/renew-subsidy/available` | 可用换新补贴 | ⚠️ 无 PRD |
| `couponClassList` | GET `/coupon-class/list` | 换新补贴分类 | ⚠️ 无 PRD |
| `availableCouponClass` | GET `/renew-subsidy/available?couponClassId=xxx` | 按分类筛补贴 | ⚠️ 无 PRD |

### 3.4 回收单（以旧换新）

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `allowBindAhsOrderList` | GET `/ahs/allow-bind` | 可绑定回收单 | ⚠️ 无 PRD |
| `checkAhsOrder` | GET `/ahs/check/:id` | 校验回收单 | ⚠️ 无 PRD |

### 3.5 积分兑换

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `pointsRedeemOrderToMallOrder` | POST `/points-redeem/order/to-mall-order` | 积分订单转商城订单 | ⚠️ 无 PRD |

---

## 四、会员

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `memberSearchByPhones` | GET `/members/list-phones` | 手机号搜会员 | retail-detail / task-detail |
| `memberList` | GET `/members/list` | 会员列表 | member-detail |
| `memberSpecified` | GET `/member/specified` | 会员详情 | order-list-detail |
| `memberAdd` | POST `/members/add` | 新增会员 | member-detail |
| `memberExperienceEdit` | POST `/members/experience` | 积分调整 | member-detail / retail-detail |
| `userSelf` | GET `/members/self` | 当前用户/积分 | home-detail / member-detail / profile-detail |

---

## 五、库存

### 5.1 仓库

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `warehouseList` | GET `/warehouse/list-base` | 仓库列表 | inventory-home / stocktaking-detail / transfer-detail |

### 5.2 盘库

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `stocktakingList` | GET `/stock-taking/list` | 盘库列表 | inventory-home / stocktaking-detail |
| `stocktakingAdd` | POST `/stock-taking/add` | 新建盘库 | stocktaking-detail |
| `stocktakingDetail` | GET `/stock-taking/detail` | 盘库详情 | stocktaking-detail |
| `stocktakingProducts` | GET `/stock-taking/:id/products` | 盘库商品 | ⚠️ 无 PRD |
| `stocktakingEnd` | POST `/stock-taking/end` | 完成盘库 | ⚠️ 无 PRD |
| `stocktakingRestart` | POST `/stock-taking/restocktaking` | 重新盘库 | ⚠️ 无 PRD |
| `stocktakingPlanList` | GET `/stock-taking-plan/list` | 盘库方案 | ⚠️ 无 PRD |

### 5.3 采购

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `purchaseList` | GET `/purchase/list` | 采购列表 | inventory-home / purchase-detail |
| `purchaseDetail` | GET `/purchase/detail` | 采购详情 | purchase-detail |
| `purchaseIntoWarehouse` | POST `/purchase/into-warehouse` | 采购入库 | purchase-detail |

### 5.4 调拨

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `transferList` | GET `/transfer/list` | 调拨列表 | inventory-home / transfer-detail |
| `transferAdd` | POST `/transfer/add` | 创建调拨 | transfer-detail |
| `transferDetail` | GET `/transfer/detail` | 调拨详情 | transfer-detail |
| `transferShipping` | POST `/transfer-lock/shipping` | 确认发货 | transfer-detail |
| `transferReceived` | POST `/transfer-lock/received` | 确认入库 | ⚠️ 无 PRD |

### 5.5 序列号查询

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `serialSearch` | GET `/serial/search` | 模糊搜索 | serial-query-detail |
| `serialSearchFullMatch` | GET `/serial/search/full-match` | 全匹配 | serial-query-detail |

---

## 六、任务/审批

### 6.1 任务

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `taskList` | GET `/task/list` | 任务列表 | task-detail / workbench-detail |
| `taskCalendar` | GET `/task/calendar` | 行事历 | home-detail / task-detail |
| `taskAdd` | POST `/task/add` | 创建任务 | task-detail |
| `taskDetail` | GET `/task/:id` | 任务详情 | task-detail / workbench-detail |
| `taskComplete` | POST `/task/:id/complete` | 完成任务 | task-detail |
| `taskDelete` | DELETE `/task/:id/delete` | 删除任务 | task-detail |

### 6.2 审批

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `approvalList` | GET `/approval/list` | 审批列表 | approval-center / workbench-detail |
| `approvalCount` | GET `/approval/count` | 审批数量 | approval-center / home-detail / workbench-detail |

---

## 七、认证

| 方法 | 路径 | 说明 | 引用 PRD |
|------|------|------|---------|
| `login` | POST `/members/phone-login` | 手机号登录 | ⚠️ 无 PRD |
| `refreshToken` | POST `/auth/refresh-token` | 刷新 token | ⚠️ 无 PRD |
| `logout` | POST `/auth/logout` | 登出 | ⚠️ 无 PRD |

---

## 八、未被任何 PRD 引用的端点（19 个）

按是否需要补 PRD 分两类：

### 8.1 应当补 PRD（业务端点）

| 端点 | 模块 | 建议补到 |
|------|------|---------|
| `/cash-coupon/available` | 代金券 | retail-detail-prd 或新建 coupon-prd |
| `/cash-coupon/list` | 代金券 | retail-detail-prd |
| `/renew-subsidy/available` | 换新补贴 | retail-detail-prd |
| `/coupon-class/list` | 换新补贴 | retail-detail-prd |
| `/ahs/allow-bind` | 回收单 | retail-detail-prd（以旧换新场景） |
| `/ahs/check/:id` | 回收单 | retail-detail-prd |
| `/points-redeem/order/to-mall-order` | 积分兑换 | mall-order-prd 或 member-detail-prd |
| `/category/top` | 分类 | category-select-prd |
| `/mall-category/list` | 商城分类 | category-select-prd（核心接口）|
| `/product/sku-by-spu` | SKU | category-select-prd |
| `/stock-taking-plan/list` | 盘库方案 | stocktaking-detail-prd |
| `/stock-taking/:id/products` | 盘库商品 | stocktaking-detail-prd |
| `/stock-taking/end` | 完成盘库 | stocktaking-detail-prd |
| `/stock-taking/restocktaking` | 重盘 | stocktaking-detail-prd |
| `/transfer-lock/received` | 调拨入库 | transfer-detail-prd |

### 8.2 系统级端点（无需独立 PRD）

| 端点 | 说明 |
|------|------|
| `/members/phone-login` | 登录（待补 auth-prd） |
| `/auth/refresh-token` | Token 刷新 |
| `/auth/logout` | 登出 |
| `/product/barcode/:code` | 条码查商品（遗留接口） |

---

## 九、维护

- 新增端点：在 `api_endpoints.dart` 添加后，运行闭环检查脚本同步本表
- 删除端点：先确认无 PRD 引用，否则同时更新 PRD
- PRD 引用接口：在 PRD 中用反引号包裹路径，例如 \`/order/sale-shop-add\`，便于检索

---

> 上次更新：2026-05-29（v1.0 首次按代码反推生成）
