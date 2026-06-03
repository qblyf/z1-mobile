# 审批中心模块 · 详细 PRD

> **模块**：审批中心
> **版本**：v1.0
> **日期**：2026-05-17
> **状态**：初稿
> **依据**：feature-list.md + z1-deno 接口代码

> **⚠️ 类型唯一真实源**：API 字段定义以 `lib/types/api/` 为准（相关：approval-types.dart）。本 PRD 不复制具体字段名/类型。

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

### 2.0 实现路线说明

> ⚠️ **关键背景**：z1-pwa Web 端的审批中心未原生实现，全部走 iframe / `window.location.replace` 跳到 S1（`s1.zsqk.com.cn/mobile/approval-center`、`/desktop/approval-list`）。详见 `z1-pwa/src/pages/path-d/approval-center.tsx:42-44`、`path-i/link-to-s1-approval-list.tsx:67`。

Flutter 端有两种可选实现路径：

| 路径 | 说明 | 适用场景 |
|------|------|---------|
| **A. WebView 嵌套 S1** | 沿用 z1-pwa 思路，App 内嵌 S1 H5 | 快速上线，复用 S1 已有审批流 |
| **B. 原生实现** | 用 `/approval/list` + `/approval/count` + 各业务审批接口自建 | 体验优化，长期方案 |

本 PRD 描述的是**路径 B**。如选路径 A，本 PRD 仅作为接口契约参考。

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

> 参数与响应字段见 `approval-types.dart`。

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

> 参数与响应字段见 `approval-types.dart`。

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

## 四、核心交互逻辑（路径 B：原生实现）

> ⚠️ 以下交互细节在 z1-pwa（占位 iframe）和 Flutter（仅 workbench 入口层）源码中均无原生实现可参考，需直接观察 S1 网页或与 S1 团队确认。本节为 PRD 设计建议，不是从源码提取的事实。

### 4.1 列表加载

- 进入页面默认选中"待审批" Tab，调用 `/approval/list?status=to-audit&limit=20&offset=0`
- 下拉刷新：重置 offset=0，重新加载首页
- 上拉加载更多：`offset += 20`，分页接口参数详见 `z1-mid/src/model/z1/approval.ts:19-119`（已知支持 `approvalTypes / associated / platforms / instanceIDs / status / minCreatedAt / maxCreatedAt / createdBy / limit / offset / orderBy`）
- 切换 Tab：重置列表 + 切换 `status` 过滤值

### 4.2 状态 Tab 与红点

| Tab | `status` 取值 | 说明 |
|-----|--------------|------|
| 全部 | 不传 | 所有审批 |
| 待审批 | `to-audit`（pending） | 红点数字 = `/approval/count` 返回值 |
| 已通过 | `audited`（approved） | — |
| 已驳回 | `rejected` | — |

> 状态枚举值见 `approval-types.dart:37-53`：`pending=to-audit / rejected / approved=audited / terminated=terminate`。

**红点轮询策略**：
- z1-pwa 无轮询逻辑（占位 iframe）
- Flutter 现状：`workbench_bloc.dart:90-101` 仅在工作台加载时调用一次 `getApprovalCount()`
- 建议：进入页面时拉一次 + 下拉刷新时刷新；如需准实时，可加 30s/1min 轮询（待产品决策）

### 4.3 详情页数据来源

- **复用列表接口**：`/approval/list?instanceIDs=xxx`，返回单条详情
- 这点已经过 `z1-mid/src/model/z1/approval.ts:19-119` 接口定义验证
- 不存在独立的 `/approval/:id` GET 接口

### 4.4 通过/驳回路由

前端需根据 `approvalType` 路由到不同业务接口：

| approvalType | 通过接口 | 驳回接口 |
|--------------|---------|---------|
| `discountLog` | `/discount-log/audit` | `/discount-log/reject` |
| `purchaseOrderApply` | `/purchase-order/unaudit-to-audit` | （单条明细）`/purchase-order/item/unaudit-to-reject` |
| `priceChange` / `lowLimitPriceChange` | `/price-adjustment/audit` | `/price-adjustment/reject-audit` |
| 其他类型 | 待 S1 团队补充 | 待 S1 团队补充 |

> ⚠️ **未确认**：`lowValueAssetsPurchase / lowValueAssetsApply / standardToNonStandard / accountingVouchers / financialExpenses / financialExpensesSettle / invoiceApply / lossReportApply / entryApply / emplScoreApply` 这 10 类的审批接口路径均未在源码中找到，需直接询问后端。

### 4.5 操作后行为

z1-pwa 无可参考实现，建议 Flutter 端方案：
- 通过/驳回成功 → 弹 toast → 返回列表 → 自动刷新当前 Tab
- 驳回是否要求填写理由：当前 `/discount-log/reject` 等接口已支持理由参数，建议**强制填写**以便审计追溯（待产品确认）

### 4.6 权限

- 当前 z1-pwa 和 Flutter 均未见前端权限校验逻辑
- 后端在审批接口侧校验（操作人是否为审批节点指定人）
- 前端在通过/驳回失败时按接口返回提示

---

## 五、状态流转

```
[待审批 pending/to-audit]
   │
   ├─ 审批人通过 ──→ [已通过 approved/audited]
   │
   ├─ 审批人驳回 ──→ [已驳回 rejected]
   │
   └─ 申请人撤回 ──→ [已终止 terminated/terminate]
```

> 状态值定义见 `approval-types.dart:37-53` `ApprovalStatus` 枚举。
> 撤回流程当前 z1-pwa 和 Flutter 均无实现，是否支持需产品确认。

---

## 六、模块关联

```
┌──────────────────────────────────────────────────────────┐
│                     审批中心模块关联                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│   工作台 (workbench)                                      │
│     │ /approval/count                                     │
│     │ /approval/list?status=to-audit                     │
│     ↓                                                    │
│   ┌─────────────┐                                        │
│   │ 审批中心列表 │ ──点击单项──→ ┌──────────────┐         │
│   └─────────────┘                │ 审批详情     │         │
│                                  └──────────────┘         │
│                                       │                  │
│                       通过/驳回 ─────┴─────              │
│                       ↓                ↓                 │
│                  按 approvalType 路由到业务接口          │
│                  ├─ 折扣审批 → discount-log              │
│                  ├─ 采购审批 → purchase-order            │
│                  ├─ 改价审批 → price-adjustment          │
│                  └─ 退货审批 → return-refund-application │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### 6.1 模块跳转

| 来源 | 触发 | 目标 |
|------|------|------|
| `/approval/center` | 点击审批项 | `/approval/:id` |
| `/home` 或 `/workbench` | 点击"审批中心"入口 | `/approval/center` |
| `/approval/:id` | 点击"←" | `/approval/center`（自动刷新） |
| `/approval/:id` | 点击关联订单/单据号（待确认） | 对应业务详情页 |

### 6.2 数据共享

| 数据 | 来源 | 消费者 |
|------|------|--------|
| `count`（待审批数） | `/approval/count` | 工作台红点 / 审批中心 Tab 红点 |
| `instanceID` | 审批列表项 | 审批详情查询 / 业务接口审批操作 |
| `approvalType` | 审批列表项 | 详情页路由 / 通过/驳回接口选择 |

### 6.3 与 workbench 的关系

- `workbench_bloc.dart:90-101` 在工作台加载时调用 `getApprovalCount()` + `getPendingApprovalList()`，串行**一次性**调用，无定时轮询
- `workbench_models.dart:55-63` 处理 `approvalType=='transfer'` 特例 → 映射到 `ApprovalType.purchaseOrderApply`，未知类型 fallback 到 `priceChange`

---

## 七、待确认事项

1. **approvalData 字段**：JSON 内容结构是什么？各审批类型不同？
2. **关联单据跳转**：点击关联订单号是否跳转订单详情？
3. **不同业务审批接口**：除已知 4 类（discount-log / purchase-order / price-adjustment / return-refund-application）外，其余 10 类 ApprovalType（lowValueAssetsPurchase / lowValueAssetsApply / standardToNonStandard / accountingVouchers / financialExpenses / financialExpensesSettle / invoiceApply / lossReportApply / entryApply / emplScoreApply）的通过/驳回接口路径需向后端确认
4. **撤回流程**：是否支持申请人主动撤回审批（status → terminated）？
5. **驳回理由**：是否强制要求填写？
6. **红点轮询**：进入页面拉一次还是定时轮询（30s/1min）？
7. **WebView vs 原生**：路径 A（嵌 S1 H5）vs 路径 B（原生）需产品决策