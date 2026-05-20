# Z1 Mobile · 接口规范（API Spec）

> 基于 `z1-mid` SDK 和 `z1-deno` 后端。
> 本文档按模块整理移动端需要的 API 接口。
>
> ⚠️ 本文档已根据测试 agent 实测结果更新（2026-05-19）
> 详细测试报告：`docs/status/api-test-report-2026-0519.md`

---

## 一、认证模块

### 1.1 登录

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/auth/login` | POST | 手机号密码登录 | `{phone, password, rememberMe}` | `{accessToken, refreshToken, user}` |
| `/auth/dingtalk-login` | POST | 钉钉扫码登录 | `{code}` | `{accessToken, refreshToken, user}` |
| `/auth/refresh-token` | POST | 刷新 Token | `{refreshToken}` | `{accessToken, refreshToken}` |

### 1.2 用户信息

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/self` | GET | 获取当前用户信息 | — | `{userId, name, phone, role, departmentId}` |

---

## 二、订单模块

### 2.1 零售开单

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/shop-sale-list` | GET | 零售单列表 | `{date?, status?, page, pageSize}` | `{list[], total}` |
| `/order/add` | POST | 创建订单 ⚠️ | `{type, genre, orderAmount, discountAmount, items[], payment...}` | `{orderNumber}` |

> ⚠️ `POST /order/add` 必填参数：`customerIdent`、`orderAmount`、`discountAmount`、`type`、`genre`、`status`、`handlerIdent` |
> ⚠️ `/order/genre` → `[后端无]` 改用 `GET /order/genre/customer?user=`；`/order/all-info` → `[后端无]` 实际为导出接口；`/order/product-can-sale-service` → `[待确认]` 实际路径 `/order/order-product-can-sale-service`

### 2.2 销售订单

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/:orderNumber` | GET | 订单详情 | — | `{order}` |

### 2.3 销售列表

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/shop-sale-list` | GET | 店内零售列表 | `{date?, status?, page, pageSize}` | `{list[], total}` |
| `/order/net-sale-list` | GET | 网络销售列表 | `{date?, status?, page, pageSize}` | `{list[], total}` |
| `/order/out-sale-list` | GET | 外批销售列表 | `{date?, status?, page, pageSize}` | `{list[], total}` |

> ⚠️ ~~`/order/sales-list`~~ 已废弃，请使用 `/order/shop-sale-list`

### 2.4 预订单

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/pre-sale/list` | GET | 预订单列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/pre-sale/add` | POST | 创建预订单 | `{...}` | `{preOrderId}` |
| `/pre-sale-order/pay` | POST | 预售支付确认 | `{preOrderId, paymentInfo}` | `{success}` |
| `/pre-sale-order/cancel` | POST | 预售取消 | `{preOrderId, reason?}` | `{success}` |

> ⚠️ ~~`POST /pre-sale/:id/confirm`~~ 已废弃，请使用 `POST /pre-sale-order/pay`
> ⚠️ ~~`POST /pre-sale/:id/cancel`~~ 已废弃，请使用 `POST /pre-sale-order/cancel`

### 2.5 退货退款

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/return-list` | GET | 退货列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/order/return/:id` | GET | 退货详情 | — | `{returnOrder}` |
| `/return-refund-application/audit` | POST | 退货退款审核通过 | `{id, remark?}` | `{success}` |
| `/return-refund-application/reject-audit` | POST | 退货退款审核拒绝 | `{id, reason}` | `{success}` |

> ⚠️ ~~`POST /order/return/:id/approve`~~ 已废弃
> ⚠️ ~~`POST /order/return/:id/reject`~~ 已废弃

---

## 三、库存模块

### 3.1 盘库

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/stock-taking/list` | GET | 盘库列表 | `{status?, date?, page, pageSize}` | `{list[], total}` ⚠️ **性能警告：响应时间约 6 秒** |
| `/stock-taking/add` | POST | 新建盘库单 | `{warehouseID, items[]}` | `{stockTakingId}` |
| `/stock-taking-product/add` | POST | 添加盘点商品 | `{stockTakingId, products[]}` | `{success}` |
| `/stock-taking` | POST | 提交盘库 | `{stockTakingId}` | `{success}` |
| `/stock-taking` | PUT | 更新盘库 | `{stockTakingId, items[]}` | `{success}` |

> ⚠️ ~~`POST /stock-taking/:id/add-item`~~ 已废弃，请使用 `POST /stock-taking-product/add`
> ⚠️ ~~`POST /stock-taking/:id/submit`~~ 已废弃，请使用 `POST /stock-taking`
> ⚠️ 盘库详情 `GET /stock-taking/detail?id=`

### 3.2 调拨

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/transfer/list` | GET | 调拨列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/transfer/add` | POST | 新建调拨单 | `{toWarehouseId, items[]}` | `{transferId}` |

> ⚠️ 以下接口路径已修正：调拨详情 `GET /transfer/detail?id=`、确认调拨 `POST /transfer/confirm`

### 3.3 采购

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/purchase/list` | GET | 采购单列表 | `{status?, page, pageSize}` | `{list[], total}` |

> ⚠️ 以下接口路径已修正：采购单详情 `GET /purchase/detail?id=`、采购入库 `POST /purchase/into-warehouse`

### 3.4 查询

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/serial/search` | GET | 序列号查询 | `{serialNo}` | `{goods, traceList[]}` |

> ⚠️ 以下接口路径待确认：`/goods/search`（商品搜索）、`/inventory/stock-query`（库存查询）

---

## 四、会员模块

### 4.1 会员查询

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/list` | GET | 会员列表 | `{keyword?, page, pageSize}` | `{list[], total}` |
| `/members/list-phones` | GET | 按手机号搜索会员 | `{phones}` | `{res[]}` |
| `/members/specified` | GET | 会员详情 | `{userIdents}` | `{member}` |

> ⚠️ 参数名已修正：`member` → `userIdents`（2026-05-19）
> ⚠️ `/members/list-phones` 参数 `phones` 支持逗号分隔多个手机号

### 4.2 积分

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/experience` | POST | 积分查询 | `{member}` | `{total, records[]}` |
| `/members/experience` | POST | 积分调整 | `{member, amount, type?, reason?}` | `{total, records[]}` |

> ⚠️ `amount` 为正数表示增加积分，为负数表示扣除积分
> ⚠️ ~~`/members/experience/edit`~~ 已废弃，请使用 `POST /members/experience`（带 amount 参数）

### 4.3 会员等级

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/member-level/list` | GET | 会员等级列表 | — | `{list[]}` |
| `/member-level/detail-or-all` | GET | 会员等级详情 | `{ids?}` | `{level}` |

### 4.4 会员权益

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/member-benefit/detail-or-all` | GET | 会员权益详情 | `{ids?}` | `{benefit}` |

---

## 五、商品模块

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/product/list` | GET | 商品列表 | `{categoryId?, keyword?, page, pageSize}` | `{list[], total}` |
| `/product/select` | GET | 批量查询商品（按 SKU ID）| `{ids}` | `{res[]}` ✅ 已验证 |
| `/product/select-base` | GET | 获取基础商品选择数据 | — | `{res[]}` ✅ 已验证 |
| `/product/list-by-code` | GET | 按条码搜索商品 | `{codes}` | `{list[]}` | ⚠️ `[待确认]` 后端存在，参数为逗号分隔多条码 |

> ⚠️ 商品分为 `goods`（商品）和 `service`（服务）两种类型，开单时需区分
> ⚠️ `/product/list-by-code` 参数名待确认

---

## 六、任务/行事历

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/task/list` | GET | 任务列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/task/add` | POST | 创建任务 | `{title, content?, dueDate?, remindAt?}` | `{taskId}` |
| `/task/edit` | POST | 编辑任务 | `{taskId, title?, content?, dueDate?, remindAt?, status?}` | `{success}` |
| `/task/detail` | GET | 任务详情 | `{id}` | `{task}` |
| `/task/invalid` | POST | 删除任务 | `{taskId}` | `{success}` |
| `/task/calendar` | GET | 日历数据 | `{startDate, endDate}` | `{events[]}` |
| `/points-task-instance/complete` | POST | 完成任务 | `{taskInstanceId}` | `{success}` |

> ⚠️ ~~`POST /task/:id/complete`~~ 已废弃，请使用 `POST /points-task-instance/complete`

---

## 七、审批中心

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/approval/list` | GET | 审批列表 | `{status?, approvalTypes?, platforms?, createdBy?, instanceIDs?, minCreatedAt?, maxCreatedAt?, limit?, offset?, orderBy?}` | `{list[], code: 10000}` |
| `/approval/count` | GET | 审批数量统计 | `{status?, approvalTypes?, platforms?, createdBy?, minCreatedAt?, maxCreatedAt?}` | `{count, code: 10000}` |

**业务审批接口（按类型调用）**：

| 接口 | 方法 | 说明 |
|------|------|------|
| `/discount-log/audit` | POST | 折扣审批通过 |
| `/discount-log/reject` | POST | 折扣审批拒绝 |
| `/purchase-order/unaudit-to-audit` | POST | 采购订单提交审核 |
| `/purchase-order/item/unaudit-to-audit` | POST | 采购订单明细审核通过 |
| `/purchase-order/item/unaudit-to-reject` | POST | 采购订单明细审核拒绝 |
| `/return-refund-application/audit` | POST | 退货退款审批通过 |
| `/return-refund-application/reject-audit` | POST | 退货退款审批拒绝 |
| `/price-adjustment/audit` | POST | 价格调整审批通过 |
| `/price-adjustment/reject-audit` | POST | 价格调整审批拒绝 |
| `/purchase/reject-audit` | POST | 采购审核拒绝 |

> 注意：审批列表使用 `instanceIDs` 查询单条详情，审批操作根据 `approvalType` 调用对应业务接口。

---

## 八、通用

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/department/list` | GET | 门店/部门列表 | — | `{list[]}` |
| `/warehouse/list-base` | GET | 仓库列表 | — | `{list[]}` |

> ⚠️ `/warehouse/list` 路径已修正为 `/warehouse/list-base`
> ⚠️ `/payment/method/list` 接口不存在，支付方式数据来源待确认

---

## 九、已验证可用接口（实测通过）

以下接口经测试 agent 验证通过（2026-05-19）：

| 模块 | 接口 |
|------|------|
| 认证 | `GET /members/self` |
| 会员 | `GET /members/list`、`GET /members/specified?userIdents={id}`、`GET /members/list-phones`、`GET /member-level/list`、`GET /member-level/detail-or-all`、`GET /member-benefit/detail-or-all` |
| 积分 | `POST /members/experience`（查询+调整） |
| 订单 | `GET /order/shop-sale-list`、`POST /pre-sale-order/pay`、`POST /pre-sale-order/cancel`、`POST /return-refund-application/audit` |
| 库存 | `GET /stock-taking/list`、`POST /stock-taking/add`、`GET /transfer/list`、`GET /purchase/list` |
| 商品 | `GET /product/list`、`GET /product/select`、`GET /product/select-base`、`GET /product/list-by-code` |
| 任务 | `GET /task/list`、`POST /points-task-instance/complete` |
| 审批 | `GET /approval/list`、`GET /approval/count` |
| 通用 | `GET /department/list`、`GET /warehouse/list-base` |

---

## 十、响应格式规范

### 成功响应

```json
{
  "success": true,
  "data": { ... }
}
```

### 分页响应

```json
{
  "success": true,
  "data": {
    "list": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```

### 错误响应

```json
{
  "success": false,
  "error": {
    "code": "AUTH_TOKEN_EXPIRED",
    "message": "Token 已过期，请重新登录"
  }
}
```

---

## 十一、HTTP 状态码

| 状态码 | 含义 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 / Token 过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

---

> 本文档持续更新中。详细接口定义参考后端代码：`/Users/fan/www/AI/z1/z1-deno/src/pages/`

---

## 附录：参数变更记录（2026-05-19）

> ⚠️ = 待确认/疑似与实际不符，需测试 agent 二次验证

| 接口 | 参数 | 原文档值 | 更新值 | 说明 |
|------|------|---------|-------|------|
| `/auth/login` | phone | `phone` | `user.mobilePhone` | 实际参数嵌套在 user 对象中 |
| `/members/specified` | memberId | `memberId` | `member` | 实际参数名 |
| `/members/experience` | memberId | `memberId` | `member` | 统一用 member |
| `/members/experience/edit` | memberId | `memberId` | `member` | 统一用 member |
| `/members/experience/add` | memberId | `memberId` | `member` | 统一用 member |
| `/members/add` | phone | `phone` | `user.mobilePhone` | 实际参数嵌套在 user 对象中 |
| `/stock-taking/add` | warehouseId | `warehouseId` | `warehouseID` | 大驼峰命名 |
| `/stock-taking/list` | — | — | — | ⚠️ 标注性能问题，待优化 |
| `/transfer/add` | toWarehouseId | `toWarehouseId` | `warehouseID` | 大驼峰命名 |
| `/inventory/stock-query` | warehouseId | `warehouseId` | `warehouseID` | 大驼峰命名 |

### 待验证接口（19个）

以下接口缺少后端实现或返回结构未知，需测试 agent 补充验证：

#### 后端不存在的接口（12个）

| 接口 | 说明 | 正确路径 |
|------|------|----------|
| `POST /members/experience/edit` | ❌ 后端无 | ~~已废弃~~ 改用 `POST /members/experience`（带 amount 参数为调整） |
| `GET /members/level/list` | ❌ 后端无 | ~~已废弃~~ 应使用 `GET /member-level/list` |
| `POST /task/:id/complete` | ❌ 后端无 | ~~已废弃~~ 任务完成应使用 `POST /points-task-instance/complete` |
| `GET /order/sales-list` | ❌ 后端无 | ~~已废弃~~ 应使用 `GET /order/shop-sale-list` |
| `POST /pre-sale/:id/confirm` | ❌ 后端无 | ~~已废弃~~ 预订单确认应使用 `POST /pre-sale-order/pay` |
| `POST /pre-sale/:id/cancel` | ❌ 后端无 | ~~已废弃~~ 预订单取消应使用 `POST /pre-sale-order/cancel` |
| `POST /order/return/:id/approve` | ❌ 后端无 | ~~已废弃~~ 应使用 `POST /return-refund-application/audit` |
| `POST /order/return/:id/reject` | ❌ 后端无 | ~~已废弃~~ 应使用 `POST /return-refund-application/reject-audit` |
| `POST /stock-taking/:id/add-item` | ❌ 后端无 | ~~已废弃~~ 盘库追加商品应使用 `POST /stock-taking-product/add` |
| `POST /stock-taking/:id/submit` | ❌ 后端无 | ~~已废弃~~ 提交盘库应使用 `POST /stock-taking` |
| `GET /members/level/:id` | ❌ 后端无 | ~~已废弃~~ 应使用 `GET /member-level/detail-or-all?ids=` |
| `GET /members/benefit/:id` | ❌ 后端无 | ~~已废弃~~ 应使用 `GET /member-benefit/detail-or-all?ids=` |

#### 路径/实现待确认（7个）

| 接口 | 说明 |
|------|------|
| `GET /goods/search` | 商品搜索 |
| `GET /inventory/stock-query` | 库存查询 |
| `GET /task/calendar` | 日历数据 |
| `GET /product/detail/:id` | 商品详情 |
| `GET /product/select-data` | 商品选择数据 |
| `GET /product/barcode/:code` | 条码查商品 |
| `GET /payment/method/list` | 支付方式列表 |

> 上次更新：2026-05-19（根据测试 agent 实测结果）
> 本次更新：2026-05-19（补充正确接口定义）