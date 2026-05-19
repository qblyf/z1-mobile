# 审批中心模块 · 详细 PRD

> **模块**：审批中心
> **版本**：v1.0
> **日期**：2026-05-17
> **状态**：初稿
> **依据**：feature-list.md + z1-deno 接口代码

---

## 一、页面路径总览

```
路径：/approval/center
名称：审批中心
Tab：工作台 Tab（底部导航栏第三项）
```

```
┌──────────────────────────────────┐
│ 审批中心                        │
├──────────────────────────────────┤
│ [全部] [待审批] [已通过] [已驳回] │  ← 状态 Tab
│                                  │
│  🔴 待审批 (5)                   │
│  ┌────────────────────────────┐  │
│  │ 易耗品采购 - 张三  1小时前  │  │
│  │ 申请金额：¥500.00          │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ 折扣申请 - 李四  2小时前    │  │
│  │ 订单号：Z1-xxx  折扣：¥80  │  │
│  └────────────────────────────┘  │
│  ...                              │
│                                  │
├──────────────────────────────────┤
│ 🏠 | 👥 | 💼 | 📋 | 👤          │  ← TabBar
└──────────────────────────────────┘
```

---

## 二、页面 1：审批中心列表页

### 2.1 路由

```
路径：/approval/center
名称：审批中心（Approval Center）
Tab：TabBar 第 3 项（工作台）
```

### 2.2 页面结构

#### 2.2.1 顶部 Tab 栏

- 四个状态 Tab：全部 / 待审批 / 已通过 / 已驳回
- 当前 Tab 高亮（蓝色下划线）
- 待审批 Tab 显示红点数字（待处理数量）
- 点击切换筛选条件

#### 2.2.2 审批列表

- 下拉刷新加载数据
- 分页加载（pageSize=20，上拉加载更多）
- 显示审批类型、申请人、申请时间、金额/内容摘要

#### 2.2.3 空状态

- 无审批记录时显示空状态插画
- 文案："暂无审批记录"

### 2.3 字段说明

#### ApprovalItem（审批项）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 审批 ID |
| approvalType | enum | 审批类型（见 ApprovalType）|
| approvalData | string | 审批内容（JSON 字符串，需解析）|
| associated | object | 关联单据（订单号等）|
| platform | enum | 平台类型：`dingtalk`/`weixin`/`feishu`/`s1` |
| instanceID | string | 外部审批实例 ID |
| status | enum | 状态：`to-audit`/`rejected`/`audited`/`terminate` |
| result | string/null | 审批结果备注 |
| createdAt | number | 创建时间（Unix 时间戳，秒）|
| createdBy | number | 创建人用户 ID |
| updatedAt | number | 更新时间（Unix 时间戳，秒）|
| updatedBy | number | 更新人用户 ID |

#### ApprovalType（审批类型枚举）

| 值 | 说明 |
|----|------|
| `lowValueAssetsPurchase` | 易耗品采购 |
| `lowValueAssetsApply` | 易耗品申请 |
| `standardToNonStandard` | 标品转非标 |
| `accountingVouchers` | 会计凭证 |
| `discountLog` | 折扣记录 |
| `financialExpenses` | 财务支出 |
| `financialExpensesSettle` | 财务支出结算 |
| `invoiceApply` | 发票申请 |
| `lossReportApply` | 报损单申请 |
| `entryApply` | 入职申请 |
| `priceChange` | 改价申请 |
| `lowLimitPriceChange` | 低于大盘价改价申请 |
| `emplScoreApply` | 工分申报单 |
| `purchaseOrderApply` | 采购订单申请 |

#### PlatformType（平台类型枚举）

| 值 | 说明 |
|----|------|
| `dingtalk` | 钉钉 |
| `weixin` | 企业微信 |
| `feishu` | 飞书 |
| `s1` | S1审批 |

### 2.4 接口清单

| 页面区块 | 接口 | 方法 | 说明 |
|----------|------|------|------|
| 审批列表 | `/approval/list` | GET | 审批列表（支持状态/类型筛选）|
| 待审批数量 | `/approval/count` | GET | 待审批总数（首页红点）|

**`/approval/list` 参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 否 | 审批状态（`to-audit`/`rejected`/`audited`/`terminate`，逗号分隔多个）|
| approvalTypes | string | 否 | 审批类型（逗号分隔，如 `discountLog,priceChange`）|
| platforms | string | 否 | 平台类型（逗号分隔，如 `dingtalk,feishu`）|
| createdBy | string | 否 | 创建人 ID（逗号分隔多个）|
| instanceIDs | string | 否 | 审批实例 ID（逗号分隔，用于筛选特定审批）|
| minCreatedAt | number | 否 | 创建时间范围起点（Unix 秒）|
| maxCreatedAt | number | 否 | 创建时间范围终点（Unix 秒）|
| limit | number | 否 | 每页条数（默认 20）|
| offset | number | 否 | 偏移量（默认 0）|
| orderBy | string | 否 | 排序（如 `createdAt:DESC`）|

**`/approval/count` 参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 否 | 审批状态（传 `to-audit` 获取待审批数）|
| approvalTypes | string | 否 | 审批类型（逗号分隔）|
| platforms | string | 否 | 平台类型（逗号分隔）|
| createdBy | string | 否 | 创建人 ID（逗号分隔多个）|
| minCreatedAt | number | 否 | 创建时间范围起点（Unix 秒）|
| maxCreatedAt | number | 否 | 创建时间范围终点（Unix 秒）|

### 2.5 异常/边界情况

| 场景 | 处理 |
|------|------|
| 网络断开 | 显示缓存数据，顶部显示网络异常提示条 |
| 无审批数据 | 显示空状态插画 |
| 加载失败 | 显示错误提示，点击重试 |
| status 参数无效 | 接口返回错误，前端保持当前 Tab |

---

## 三、页面 2：审批详情页（跳转）

> 点击审批项 → 跳转 `/approval/:id`（审批详情）

### 3.1 路由

```
路径：/approval/:id
名称：审批详情（Approval Detail）
Tab：无（独立页面）
```

### 3.2 页面结构

```
┌──────────────────────────────────┐
│  ← 审批详情                      │
├──────────────────────────────────┤
│                                  │
│  审批类型：折扣申请               │
│  申请人：张三                     │
│  申请时间：2026-05-16 14:30       │
│                                  │
│  ─────────────────────────────── │
│                                  │
│  关联订单：Z1-20260516-001        │
│  原价：¥328.00                   │
│  申请折扣：¥80.00                │
│  折后价：¥248.00                 │
│                                  │
│  ─────────────────────────────── │
│                                  │
│  [驳回]              [通过]        │
│                                  │
└──────────────────────────────────┘
```

### 3.3 接口清单

审批详情通过 `/approval/list` 接口查询，使用 `instanceIDs` 参数筛选。

| 页面区块 | 接口 | 方法 | 说明 |
|----------|------|------|------|
| 审批详情 | `/approval/list` | GET | 通过 `instanceIDs` 参数获取单条审批详情 |

**`/approval/list` 查询单条详情参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| instanceIDs | string | 是 | 审批实例 ID（如 `123456`）|

### 3.4 审批操作接口

审批操作通过各业务类型对应的接口实现，非统一审批中心接口：

| 操作 | 接口路径 | 方法 | 说明 |
|------|----------|------|------|
| 折扣审批通过 | `/discount-log/audit` | POST | 折扣记录审批通过 |
| 折扣审批拒绝 | `/discount-log/reject` | POST | 折扣记录审批拒绝 |
| 采购订单提交审核 | `/purchase-order/unaudit-to-audit` | POST | 采购订单提交审核 |
| 采购订单审核通过 | `/purchase-order/item/unaudit-to-audit` | POST | 采购订单明细审核 |
| 采购订单审核拒绝 | `/purchase-order/item/unaudit-to-reject` | POST | 采购订单明细拒绝 |
| 退货退款审批通过 | `/return-refund-application/audit` | POST | 退货退款审批通过 |
| 退货退款审批拒绝 | `/return-refund-application/reject-audit` | POST | 退货退款审批拒绝 |
| 价格调整审批通过 | `/price-adjustment/audit` | POST | 价格调整审批通过 |
| 价格调整审批拒绝 | `/price-adjustment/reject-audit` | POST | 价格调整审批拒绝 |

> 具体业务类型的审批接口不同，前端需根据 `approvalType` 调用对应接口。

---

## 四、跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| `/approval/center` | 点击审批项 | `/approval/:id` |
| `/home` | 点击"审批中心" | Tab 切换到工作台 |
| `/approval/:id` | 点击"←" | `/approval/center` |

---

## 五、待确认事项

1. **approvalData 字段**：JSON 内容结构是什么？各审批类型不同？
2. **关联单据跳转**：点击关联订单号是否跳转订单详情？
3. **不同业务审批接口**：前端需根据 `approvalType` 调用对应业务审批接口，接口路径已在上文列出。