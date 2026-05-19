# Z1-NextApp 文档完整性检查报告

> **检查日期**：2026-05-17
> **检查范围**：已完成页面 vs 已有 PRD 文档
> **依据**：app_router.dart 路由配置 + docs/features/ 目录

---

## 一、已完成页面清单（基于代码）

| # | 页面 | 路由 | 代码文件 |
|---|------|------|----------|
| 1 | 登录页 | `/login` | `features/auth/presentation/pages/login_page.dart` |
| 2 | 首页 | `/home` | `features/home/presentation/pages/home_page.dart` |
| 3 | 零售开单入口 | `/home/retail/entry` | `features/retail/presentation/pages/retail_entry_page.dart` |
| 4 | 商品选购 | `/home/retail/product` | `features/retail/presentation/pages/retail_product_page.dart` |
| 5 | 订单确认 | `/home/retail/confirm` | `features/retail/presentation/pages/retail_confirm_page.dart` |
| 6 | 优惠券选择 | `/home/retail/coupon-select` | `features/retail/presentation/pages/coupon_select_page.dart` |
| 7 | 收款 | `/home/retail/payment` | `features/retail/presentation/pages/retail_payment_page.dart` |
| 8 | 订单完成 | `/home/retail/complete` | `features/retail/presentation/pages/retail_complete_page.dart` |
| 9 | 订单列表 | `/home/order/list` | `features/order/presentation/pages/order_list_page.dart` |
| 10 | 订单详情 | `/home/order/:orderNumber` | `features/order/presentation/pages/order_detail_page.dart` |
| 11 | 会员首页 | `/member/home` | `features/member/presentation/pages/member_home_page.dart` |
| 12 | 会员详情 | `/member/:memberId` | `features/member/presentation/pages/member_detail_page.dart` |
| 13 | 新增会员 | `/member/add` | `features/member/presentation/pages/member_add_page.dart` |
| 14 | 积分查询 | `/member/:memberId/creditscore` | `features/member/presentation/pages/member_creditscore_page.dart` |
| 15 | 积分调整 | `/member/:memberId/creditscore/edit` | `features/member/presentation/pages/member_creditscore_edit_page.dart` |
| 16 | 工作台 | `/workbench` | `features/workbench/presentation/pages/workbench_page.dart` |
| 17 | 任务 | `/task` | `features/task/presentation/pages/task_home_page.dart` |
| 18 | 库存管理首页 | `/inventory` | `features/inventory/presentation/pages/inventory_home_page.dart` |
| 19 | 盘库列表 | `/inventory/stocktaking` | `features/inventory/presentation/pages/stocktaking_list_page.dart` |
| 20 | 新建盘库 | `/inventory/stocktaking/add` | `features/inventory/presentation/pages/stocktaking_add_page.dart` |
| 21 | 盘库详情 | `/inventory/stocktaking/:id` | `features/inventory/presentation/pages/stocktaking_detail_page.dart` |
| 22 | 调拨列表 | `/inventory/transfer` | `features/inventory/presentation/pages/transfer_list_page.dart` |
| 23 | 新建调拨 | `/inventory/transfer/add` | `features/inventory/presentation/pages/transfer_add_page.dart` |
| 24 | 调拨详情 | `/inventory/transfer/:id` | `features/inventory/presentation/pages/transfer_detail_page.dart` |
| 25 | 采购列表 | `/inventory/purchase-list` | `features/inventory/presentation/pages/purchase_list_page.dart` |
| 26 | 采购详情 | `/inventory/purchase-list/:id` | `features/inventory/presentation/pages/purchase_detail_page.dart` |
| 27 | 采购入库 | `/inventory/purchase-inbound/:id` | `features/inventory/presentation/pages/purchase_inbound_page.dart` |
| 28 | 序列号查询 | `/inventory/serial-search` | `features/inventory/presentation/pages/serial_search_page.dart` |
| 29 | 我的 | `/profile` | `features/profile/presentation/pages/profile_page.dart` |

**合计**：29 个页面

---

## 二、现有 PRD 文档清单

| # | 文档名 | 覆盖页面 | 状态 |
|---|--------|---------|------|
| 1 | `feature-list.md` | 功能清单/全局规划 | v1.3 ✅ |
| 2 | `home-detail-prd.md` | `/home` | v1.0 ✅ |
| 3 | `retail-detail-prd.md` | 零售开单 6 页面 | v1.1 ✅ |
| 4 | `member-detail-prd.md` | 会员中心 5 页面 | v1.0 ✅ |
| 5 | `stocktaking-detail-prd.md` | 盘库 3 页面 | v1.0 ✅ |
| 6 | `transfer-detail-prd.md` | 调拨 2 页面（新建+详情） | v1.0 ✅ |
| 7 | `purchase-detail-prd.md` | 采购 2 页面（详情+入库） | v1.0 ✅ |

**注意**：调拨列表页面（`/inventory/transfer`）在 `transfer-detail-prd.md` 中没有独立章节，但代码已实现。

---

## 三、页面-文档对照表

| 功能模块 | 已完成页面 | 是否有文档 | 文档完整性 | 缺失内容 |
|---------|-----------|-----------|-----------|---------|
| **登录** | `/login` | ✅ feature-list.md | 完整 | 无 |
| **首页** | `/home` | ✅ home-detail-prd.md | 完整 | 无 |
| **零售开单** | 6 个页面 | ✅ retail-detail-prd.md | 完整 | 无 |
| **订单列表** | `/home/order/list` | ⚠️ retail-detail-prd.md（部分） | 需补充 | 独立订单列表页面说明 |
| **订单详情** | `/home/order/:orderNumber` | ✅ retail-detail-prd.md | 完整 | 无 |
| **会员中心** | 5 个页面 | ✅ member-detail-prd.md | 完整 | 无 |
| **工作台** | `/workbench` | ❌ 无 | **缺失** | 需新建 PRD |
| **任务** | `/task` | ❌ 无 | **缺失** | 需新建 PRD |
| **库存管理首页** | `/inventory` | ❌ 无 | **缺失** | 需新建 PRD |
| **盘库** | 3 个页面 | ✅ stocktaking-detail-prd.md | 完整 | 无 |
| **调拨** | 3 个页面 | ⚠️ transfer-detail-prd.md | 不完整 | 缺少调拨列表页面说明 |
| **采购** | 3 个页面 | ✅ purchase-detail-prd.md | 完整 | 无 |
| **序列号查询** | `/inventory/serial-search` | ❌ 无 | **缺失** | 需新建 PRD |
| **优惠券选择** | `/home/retail/coupon-select` | ✅ retail-detail-prd.md | 完整 | 无 |
| **我的** | `/profile` | ❌ 无 | **缺失** | 需新建 PRD |

---

## 四、缺失文档清单

| # | 需创建的文档 | 覆盖页面 | 优先级 |
|---|-------------|---------|--------|
| 1 | `serial-search-detail-prd.md` | `/inventory/serial-search` | P1 |
| 2 | `inventory-home-detail-prd.md` | `/inventory` | P1 |
| 3 | `order-list-detail-prd.md` | `/home/order/list` | P1 |
| 4 | `workbench-detail-prd.md` | `/workbench` | P2 |
| 5 | `task-detail-prd.md` | `/task` | P2 |
| 6 | `profile-detail-prd.md` | `/profile` | P3 |
| 7 | `transfer-detail-prd.md`（补充）| `/inventory/transfer`（调拨列表）| P1 |

---

## 五、文档质量检查

### 5.1 已有 PRD 格式一致性

| 文档 | 格式规范 | 章节完整 | 接口清单 | 异常处理 | 说明 |
|------|---------|---------|---------|---------|------|
| feature-list.md | ✅ | ✅ | ❌ | ❌ | 全局规划，非单页详细 PRD |
| home-detail-prd.md | ✅ | ✅ | ✅ | ✅ | 标准 PRD 格式 |
| retail-detail-prd.md | ✅ | ✅ | ✅ | ✅ | 标准 PRD 格式 |
| member-detail-prd.md | ✅ | ✅ | ✅ | ✅ | 标准 PRD 格式 |
| stocktaking-detail-prd.md | ✅ | ✅ | ✅ | ✅ | **参考模板** |
| transfer-detail-prd.md | ⚠️ | ⚠️ | ✅ | ✅ | 缺少调拨列表页面 |
| purchase-detail-prd.md | ✅ | ✅ | ✅ | ✅ | 缺少采购列表页面 |

### 5.2 文档格式模板（参考 stocktaking-detail-prd.md）

每个详细 PRD 应包含以下章节：

```
一、页面路径总览
二、页面 1：[页面名称]
   2.1 路由
   2.2 基本布局（ASCII 线框图）
   2.3 核心交互逻辑
   2.4 字段说明
   2.5 异常/边界情况
   2.6 跳转关系
三、页面 2：...
四、模块数据流
五、接口清单
六、待确认事项
```

---

## 六、行动建议

### 立即行动（高优先级）

1. **创建 `order-list-detail-prd.md`**
   - 覆盖：`/home/order/list`
   - 依赖零售 PRD 中的订单详情章节

2. **创建 `serial-search-detail-prd.md`**
   - 覆盖：`/inventory/serial-search`
   - 参考 stocktaking-detail-prd.md 格式

3. **创建 `inventory-home-detail-prd.md`**
   - 覆盖：`/inventory`（库存管理 Tab 首页）
   - 说明四个子模块入口（盘库/调拨/采购/查询）

### 稍后行动（中优先级）

4. **补充 `transfer-detail-prd.md`**
   - 添加调拨列表页面章节

5. **补充 `purchase-detail-prd.md`**
   - 添加采购列表页面章节

6. **创建 `workbench-detail-prd.md`**
   - 覆盖：`/workbench`

7. **创建 `task-detail-prd.md`**
   - 覆盖：`/task`

### 可选行动（低优先级）

8. **创建 `profile-detail-prd.md`**
   - 覆盖：`/profile`

---

## 七、统计汇总

| 类别 | 数量 |
|------|------|
| 已完成页面 | 29 |
| 已有详细 PRD 的页面 | 21（72%）|
| 缺失文档覆盖的页面 | 8（28%）|
| 已有 PRD 文档 | 7 |
| 需新建文档 | 7（含 1 个补充）|

---

> **结论**：项目整体文档覆盖率为 72%，核心零售/会员/盘库/采购模块文档完整。调拨、序列号查询、库存首页、工作台、任务、个人页面文档缺失，建议按优先级补充。