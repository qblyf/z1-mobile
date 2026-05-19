# Z1 Mobile · 接口规范（API Spec）

> 基于 `z1-mid` SDK 和 `z1-deno` 后端。
> 本文档按模块整理移动端需要的 API 接口。

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
| `/user/self` | GET | 获取当前用户信息 | — | `{id, name, phone, role, departmentId}` |

---

## 二、订单模块

### 2.1 零售开单

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/retail/entry` | GET | 开单入口（获取销售类型） | — | `{saleTypes: [{id, name}]}` |
| `/order/shop-sale/add` | POST | 创建零售单 | `{customerId, saleType, items[], payment}` | `{orderNumber}` |
| `/order/shop-sale-list` | GET | 零售单列表 | `{date?, status?, page, pageSize}` | `{list[], total}` |
| `/order/:orderNumber` | GET | 订单详情 | — | `{orderNumber, items[], payment, status}` |
| `/order/:orderNumber/print` | GET | 打印小票 | — | `{printData}` |

**零售单请求结构**：

```json
{
  "customerId": "string",        // 会员ID（可选）
  "saleType": "retail|wholesale|project",
  "items": [
    {
      "productId": "string",
      "skuId": "string",
      "quantity": 1,
      "price": 100.00,
      "discount": 0
    }
  ],
  "payment": {
    "method": "cash|wechat|alipay|card|combined",
    "amount": 100.00,
    "subPayments": []  // 组合支付时
  }
}
```

### 2.2 销售订单

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/sales-list` | GET | 销售订单列表 | `{dateRange?, status?, page, pageSize}` | `{list[], total}` |
| `/order/:orderNumber` | GET | 订单详情 | — | `{order}` |

### 2.3 预订单

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/pre-sale/list` | GET | 预订单列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/pre-sale/add` | POST | 创建预订单 | `{...}` | `{preOrderId}` |
| `/pre-sale/:id/confirm` | POST | 确认预订单 | — | `{orderNumber}` |
| `/pre-sale/:id/cancel` | POST | 取消预订单 | `{reason}` | `{success}` |

### 2.4 退货退款

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/order/return-list` | GET | 退货列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/order/return/:id` | GET | 退货详情 | — | `{returnOrder}` |
| `/order/return/:id/approve` | POST | 审核通过 | `{remark}` | `{success}` |
| `/order/return/:id/reject` | POST | 审核拒绝 | `{reason}` | `{success}` |

---

## 三、库存模块

### 3.1 盘库

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/stock-taking/list` | GET | 盘库列表 | `{status?, date?, page, pageSize}` | `{list[], total}` |
| `/stock-taking/add` | POST | 新建盘库单 | `{warehouseID, items[]}` ⚠️ | `{stockTakingId}` |
| `/stock-taking/:id` | GET | 盘库详情 | — | `{stockTaking}` |
| `/stock-taking/:id/add-item` | POST | 添加盘点商品 | `{barcode, systemQty, actualQty}` | `{item}` |
| `/stock-taking/:id/submit` | POST | 提交盘库 | — | `{success}` |

### 3.2 调拨

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/transfer/list` | GET | 调拨列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/transfer/add` | POST | 新建调拨单 | `{warehouseID, items[]}` ⚠️ | `{transferId}` |
| `/transfer/:id` | GET | 调拨详情 | — | `{transfer}` |
| `/transfer/:id/confirm` | POST | 确认调拨（入库方） | — | `{success}` |

### 3.3 采购

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/purchase/list` | GET | 采购单列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/purchase/:id` | GET | 采购单详情 | — | `{purchase}` |
| `/purchase/:id/inbound` | POST | 采购入库 | `{items[]}` | `{success}` |

### 3.4 查询

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/goods/serial-search` | GET | 序列号查询 | `{serialNo}` | `{goods, traceList[]}` |
| `/goods/search` | GET | 商品搜索 | `{keyword, barcode}` | `{list[]}` |
| `/inventory/stock-query` | GET | 库存查询 | `{productId?, warehouseID?}` ⚠️ | `{stockList[]}` |

---

## 四、会员模块

### 4.1 会员查询

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/list` | GET | 会员列表 | `{keyword?, page, pageSize}` | `{list[], total}` |
| `/members/specified` | GET | 会员详情 | `{member}` ⚠️ | `{member}` |
| `/members/add` | POST | 新增会员 | `{phone, name, gender, birthday, levelId}` | `{memberId}` |
| `/members/edit` | POST | 编辑会员 | `{memberId, ...fields}` | `{success}` |

### 4.2 积分

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/experience` | GET | 积分查询 | `{member}` ⚠️ | `{total, records[]}` |
| `/members/experience/edit` | POST | 积分调整 | `{member, amount, type, reason}` ⚠️ | `{success}` |
| `/members/experience/add` | POST | 消费积分 | `{member, orderNumber, amount}` ⚠️ | `{newTotal}` |

### 4.3 会员等级

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/level/list` | GET | 等级列表 | — | `{list[]}` |
| `/members/level/:id` | GET | 等级详情 | — | `{level}` |

### 4.4 会员权益

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/members/benefit/list` | GET | 权益列表 | — | `{list[]}` |
| `/members/benefit/:id` | GET | 权益详情 | — | `{benefit}` |

---

## 五、商品模块

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/product/list` | GET | 商品列表 | `{categoryId?, keyword?, page, pageSize}` | `{list[], total}` |
| `/product/detail/:id` | GET | 商品详情 | — | `{product}` |
| `/product/select-data` | GET | 商品选择数据 | `{keyword?, barcode?}` | `{list[]}` |
| `/product/barcode/:code` | GET | 条码查商品 | — | `{product}` |

---

## 六、任务/行事历

| 接口 | 方法 | 说明 | 请求参数 | 响应 |
|------|------|------|----------|------|
| `/task/calendar` | GET | 日历数据 | `{startDate, endDate}` | `{events[]}` |
| `/task/list` | GET | 任务列表 | `{status?, page, pageSize}` | `{list[], total}` |
| `/task/add` | POST | 创建任务 | `{title, content, startTime, endTime, priority, remindAt}` | `{taskId}` |
| `/task/:id` | GET | 任务详情 | — | `{task}` |
| `/task/:id/edit` | POST | 编辑任务 | `{...fields}` | `{success}` |
| `/task/:id/complete` | POST | 完成任务 | — | `{success}` |
| `/task/:id/delete` | DELETE | 删除任务 | — | `{success}` |

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
| `/warehouse/list` | GET | 仓库列表 | — | `{list[]}` |
| `/payment/method/list` | GET | 支付方式列表 | — | `{list[]}` |

---

## 九、响应格式规范

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

## 十、HTTP 状态码

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