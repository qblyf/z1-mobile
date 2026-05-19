# Z1 Mobile · 数据模型（Data Model）

> 本文档定义移动端核心业务实体的数据结构与关系。
> 实体定义参考后端 `z1-deno` 数据库设计。

---

## 一、核心实体关系图

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Member    │────▶│   Order     │◀────│   Product   │
│   会员       │     │   订单       │     │   商品       │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   │                   ▼
       ▼                   ▼            ┌─────────────┐
┌─────────────┐     ┌─────────────┐    │   Inventory │
│  Experience │     │OrderItem    │───▶│   库存       │
│  积分记录     │     │ 订单明细     │    └─────────────┘
└─────────────┘     └─────────────┘
```

---

## 二、用户认证（User/Auth）

### User（用户）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 用户 ID |
| name | string | 用户姓名 |
| phone | string | 手机号 |
| role | string | 角色 |
| departmentId | string | 门店/部门 ID |
| avatar | string | 头像 URL |
| createdAt | datetime | 创建时间 |

### Token（令牌）

| 字段 | 类型 | 说明 |
|------|------|------|
| accessToken | string | 访问令牌（有效期 7 天） |
| refreshToken | string | 刷新令牌（有效期 30 天） |
| expiresAt | datetime | 过期时间 |

---

## 三、订单（Order）

### Order（订单主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| orderNumber | string | 订单号（唯一） |
| orderType | enum | 订单类型：`retail`、`wholesale`、`project` |
| status | enum | 订单状态：`pending`、`completed`、`refunded` |
| customerId | string | 会员 ID（可选） |
| customerName | string | 客户姓名 |
| totalAmount | decimal | 订单总金额 |
| discountAmount | decimal | 折扣金额 |
| finalAmount | decimal | 实收金额 |
| paymentMethod | enum | 支付方式：`cash`、`wechat`、`alipay`、`card`、`combined` |
| paymentStatus | enum | 支付状态：`unpaid`、`paid`、`refunded` |
| remark | string | 备注 |
| operatorId | string | 操作员 ID |
| departmentId | string | 门店 ID |
| createdAt | datetime | 创建时间 |
| completedAt | datetime | 完成时间 |

### OrderItem（订单明细）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 明细 ID |
| orderNumber | string | 订单号 |
| productId | string | 商品 ID |
| productName | string | 商品名称 |
| skuId | string | SKU ID |
| barcode | string | 条码 |
| quantity | int | 数量 |
| price | decimal | 单价 |
| discount | decimal | 折扣 |
| subtotal | decimal | 小计金额 |

### Payment（支付记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 支付 ID |
| orderNumber | string | 订单号 |
| method | enum | 支付方式 |
| amount | decimal | 支付金额 |
| transactionId | string | 第三方交易号 |
| paidAt | datetime | 支付时间 |

---

## 四、会员（Member）

### Member（会员）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 会员 ID |
| name | string | 姓名 |
| phone | string | 手机号（唯一） |
| gender | enum | 性别：`male`、`female`、`unknown` |
| birthday | date | 生日 |
| levelId | string | 等级 ID |
| levelName | string | 等级名称 |
| totalExperience | int | 总积分 |
| availableExperience | int | 可用积分 |
| totalConsumption | decimal | 累计消费 |
| memberCardNo | string | 会员卡号 |
| createdAt | datetime | 注册时间 |
| lastVisitAt | datetime | 最后访问时间 |
| status | enum | 状态：`active`、`inactive`、`cancelled` |

### MemberLevel（会员等级）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 等级 ID |
| name | string | 等级名称 |
| discountRate | decimal | 折扣率（如 0.95 = 95 折） |
| experienceMultiplier | int | 积分倍数 |
| minConsumption | decimal | 升级门槛 |
| sortOrder | int | 排序 |

### ExperienceLog（积分变动记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 记录 ID |
| memberId | string | 会员 ID |
| type | enum | 类型：`consume`、`refund`、`adjust`、`expire` |
| amount | int | 变动积分（正负） |
| balance | int | 变动后余额 |
| orderNumber | string | 关联订单号 |
| reason | string | 原因 |
| operatorId | string | 操作员 |
| createdAt | datetime | 操作时间 |

---

## 五、商品（Product）

### Product（商品/SPU）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 商品 ID |
| name | string | 商品名称 |
| categoryId | string | 分类 ID |
| categoryName | string | 分类名称 |
| brand | string | 品牌 |
| unit | string | 单位 |
| price | decimal | 零售价 |
| wholesalePrice | decimal | 批发价 |
| costPrice | decimal | 成本价 |
| barcode | string | 条码 |
| image | string | 主图 URL |
| status | enum | 状态：`active`、`inactive`、`deleted` |

### ProductSku（SKU）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | SKU ID |
| productId | string | 商品 ID |
| skuCode | string | SKU 编码 |
| barcode | string | 条码 |
| spec | json | 规格属性（如 `{color: '红色', size: 'M'}`） |
| price | decimal | 价格 |
| stock | int | 库存数量 |

### GoodsSerial（序列号）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 序列号 ID |
| serialNo | string | 序列号 |
| productId | string | 商品 ID |
| skuId | string | SKU ID |
| status | enum | 状态：`available`、`sold`、`returned`、`scrapped` |
| warehouseId | string | 当前仓库 |
| purchaseOrderNo | string | 采购单号 |
| soldOrderNo | string | 销售订单号 |
| soldAt | datetime | 销售时间 |

---

## 六、库存（Inventory）

### Warehouse（仓库）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 仓库 ID |
| name | string | 仓库名称 |
| type | enum | 类型：`main`、`branch`、`store` |
| departmentId | string | 关联门店 |
| address | string | 地址 |

### Stock（库存）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 库存 ID |
| productId | string | 商品 ID |
| skuId | string | SKU ID |
| warehouseId | string | 仓库 ID |
| quantity | int | 库存数量 |
| safeQuantity | int | 安全库存 |
| updatedAt | datetime | 更新时间 |

### StockTaking（盘库单）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 盘库单 ID |
| code | string | 盘库单号 |
| warehouseId | string | 仓库 ID |
| status | enum | 状态：`pending`、`in_progress`、`submitted`、`approved` |
| totalItems | int | 总品项数 |
| profitItems | int | 盘盈品项 |
| lossItems | int | 盘亏品项 |
| operatorId | string | 操作员 |
| startedAt | datetime | 开始时间 |
| submittedAt | datetime | 提交时间 |
| approvedAt | datetime | 审核时间 |

### StockTakingItem（盘库明细）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 明细 ID |
| stockTakingId | string | 盘库单 ID |
| productId | string | 商品 ID |
| barcode | string | 条码 |
| systemQty | int | 系统数量 |
| actualQty | int | 实际数量 |
| diff | int | 差异（actual - system） |
| remark | string | 备注 |

### Transfer（调拨单）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 调拨单 ID |
| code | string | 调拨单号 |
| fromWarehouseId | string | 源仓库 |
| toWarehouseId | string | 目标仓库 |
| status | enum | 状态：`pending`、`shipped`、`received`、`cancelled` |
| totalItems | int | 总品项数 |
| operatorId | string | 操作员 |
| createdAt | datetime | 创建时间 |
| shippedAt | datetime | 发货时间 |
| receivedAt | datetime | 收货时间 |

### TransferItem（调拨明细）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 明细 ID |
| transferId | string | 调拨单 ID |
| productId | string | 商品 ID |
| quantity | int | 调拨数量 |
| shippedQty | int | 已发货数量 |
| receivedQty | int | 已收货数量 |

---

## 七、任务（Task）

### Task（任务）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 任务 ID |
| title | string | 标题 |
| content | string | 内容 |
| startTime | datetime | 开始时间 |
| endTime | datetime | 结束时间 |
| allDay | bool | 是否全天 |
| priority | enum | 优先级：`high`、`medium`、`low` |
| status | enum | 状态：`pending`、`in_progress`、`completed`、`cancelled` |
| remindAt | datetime | 提醒时间 |
| memberId | string | 关联会员（可选） |
| orderNumber | string | 关联订单（可选） |
| creatorId | string | 创建人 |
| assigneeId | string | 负责人 |
| createdAt | datetime | 创建时间 |
| completedAt | datetime | 完成时间 |

### TaskLog（任务日志）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 日志 ID |
| taskId | string | 任务 ID |
| content | string | 日志内容 |
| operatorId | string | 操作人 |
| createdAt | datetime | 操作时间 |

---

## 八、审批（Approval）

### Approval（审批单）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 审批单 ID |
| type | enum | 类型：`return`、`transfer`、`price_special`、`purchase` |
| title | string | 标题 |
| status | enum | 状态：`pending`、`approved`、`rejected` |
| applicantId | string | 申请人 |
| applicantName | string | 申请人姓名 |
| departmentId | string | 申请门店 |
| content | json | 审批内容（类型相关） |
| currentStep | int | 当前步骤 |
| totalSteps | int | 总步骤数 |
| createdAt | datetime | 申请时间 |

### ApprovalRecord（审批记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 记录 ID |
| approvalId | string | 审批单 ID |
| step | int | 步骤 |
| approverId | string | 审批人 |
| approverName | string | 审批人姓名 |
| action | enum | 操作：`approve`、`reject` |
| comment | string | 审批意见 |
| createdAt | datetime | 审批时间 |

---

## 九、枚举值参考

### 订单状态（OrderStatus）

| 值 | 说明 |
|------|------|
| `pending` | 待处理 |
| `completed` | 已完成 |
| `refunded` | 已退款 |
| `cancelled` | 已取消 |

### 支付方式（PaymentMethod）

| 值 | 说明 |
|------|------|
| `cash` | 现金 |
| `wechat` | 微信支付 |
| `alipay` | 支付宝 |
| `card` | 银行卡 |
| `combined` | 组合支付 |

### 库存状态（StockStatus）

| 值 | 说明 |
|------|------|
| `available` | 可用 |
| `reserved` | 预留 |
| `locked` | 锁定 |
| `damaged` | 损坏 |

---

> 本文档持续更新中。详细字段参考后端数据库设计。