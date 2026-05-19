# Z1 全网连锁 · 页面审计报告

> **审计日期**：2026-05-17
> **审计范围**：产品文档（feature-list.md、PRD 文档）vs 代码实现（app_router.dart + 页面文件）
> **依据**：
> - `/docs/features/feature-list.md`（页面清单 v1.2）
> - `/docs/features/retail-detail-prd.md`（零售开单 PRD）
> - `/docs/features/member-detail-prd.md`（会员中心 PRD）
> - `/docs/features/home-detail-prd.md`（首页 PRD）
> - `/docs/features/stocktaking-detail-prd.md`（盘库 PRD）
> - `/z1_mobile/lib/core/router/app_router.dart`（路由配置）
> - 各页面文件

---

## 一、路由架构总览

### 1.1 当前代码中的路由结构

```
/login                                    # 登录页（无 TabBar）

ShellRoute (MainScaffold + TabBar)
├── /home                                  # Tab 1: 首页
│   ├── /home/retail/entry                 # 零售开单入口
│   ├── /home/retail/product              # 商品选购
│   ├── /home/retail/confirm              # 订单确认
│   ├── /home/retail/payment              # 收款
│   ├── /home/retail/complete             # 完成页
│   ├── /home/order/list                  # 订单列表
│   └── /home/order/:orderNumber          # 订单详情
│
├── /member                                # Tab 2: 会员
│   └── /member/:memberId                 # 会员详情
│
├── /workbench                             # Tab 3: 工作台
├── /task                                  # Tab 4: 任务
└── /profile                               # Tab 5: 我的
```

### 1.2 TabBar 导航结构

| Tab | 路由 | 名称 | 状态 |
|-----|------|------|------|
| 1 | `/home` | 首页 | ✅ 已实现 |
| 2 | `/member` | 会员 | ✅ 已实现 |
| 3 | `/workbench` | 工作台 | ✅ 已实现 |
| 4 | `/task` | 任务 | ✅ 已实现 |
| 5 | `/profile` | 我的 | ✅ 已实现 |

---

## 二、PRD vs 代码路由对照表

### 2.1 零售开单模块（Phase 4 P0）

| PRD 路由 | 代码路由 | 页面文件 | 状态 | 备注 |
|----------|----------|----------|------|------|
| `/order/retail/entry` | `/home/retail/entry` | `retail_entry_page.dart` | ⚠️ 路由路径不一致 | PRD 要求 `/order/retail/entry`，实际在 `/home/retail/entry` |
| `/order/retail/edit` | `/home/retail/product` | `retail_product_page.dart` | ⚠️ 路由+命名不一致 | PRD 叫 `edit`，代码叫 `product` |
| `/order/retail/confirm` | `/home/retail/confirm` | `retail_confirm_page.dart` | ✅ 一致 | |
| `/order/retail/payment` | `/home/retail/payment` | `retail_payment_page.dart` | ✅ 一致 | |
| `/order/:orderNumber` | `/home/order/:orderNumber` | `order_detail_page.dart` | ⚠️ 路由路径不一致 | PRD 在 `/order/` 下，代码在 `/home/order/` 下 |
| `/order/retail/coupon-select` | — | — | ❌ 缺失 | 优惠券选择页面未实现 |

### 2.2 订单模块

| PRD 路由 | 代码路由 | 页面文件 | 状态 | 备注 |
|----------|----------|----------|------|------|
| `/order/sales-list` | `/home/order/list` | `order_list_page.dart` | ⚠️ 路由+命名不一致 | PRD 叫 `sales-list`，代码叫 `list` |
| `/order/pre-sale-list` | — | — | ❌ 缺失 | 预订单列表 |
| `/order/pre-sale/:id` | — | — | ❌ 缺失 | 预订单处理 |
| `/order/return-list` | — | — | ❌ 缺失 | 退货列表 |
| `/order/return/:id` | — | — | ❌ 缺失 | 退货处理 |
| `/order/change-list` | — | — | ❌ 缺失 | 退换货列表 |
| `/order/change/:id` | — | — | ❌ 缺失 | 退换货处理 |

### 2.3 库存模块

| PRD 路由 | 代码路由 | 页面文件 | 状态 | 备注 |
|----------|----------|----------|------|------|
| `/inventory/home` | — | — | ❌ 缺失 | 库存管理首页 |
| `/inventory/stocktaking` | — | — | ❌ 缺失 | 盘库列表 |
| `/inventory/stocktaking/add` | — | — | ❌ 缺失 | 新建盘库 |
| `/inventory/stocktaking/:id` | — | — | ❌ 缺失 | 盘库详情 |
| `/inventory/transfer` | — | — | ❌ 缺失 | 调拨列表 |
| `/inventory/transfer/add` | — | — | ❌ 缺失 | 新建调拨 |
| `/inventory/transfer/:id` | — | — | ❌ 缺失 | 调拨详情 |
| `/inventory/purchase-list` | — | — | ❌ 缺失 | 采购列表 |
| `/inventory/purchase/:id` | — | — | ❌ 缺失 | 采购详情 |
| `/inventory/purchase-inbound/:id` | — | — | ❌ 缺失 | 采购入库 |
| `/inventory/serial-search` | — | — | ❌ 缺失 | 序列号查询 |

### 2.4 会员模块

| PRD 路由 | 代码路由 | 页面文件 | 状态 | 备注 |
|----------|----------|----------|------|------|
| `/member/home` | `/member` | `member_home_page.dart` | ✅ 路由语义等价 | 代码用 Tab 路由 `/member` 作为首页 |
| `/member/:memberId` | `/member/:memberId` | `member_detail_page.dart` | ✅ 一致 | |
| `/member/add` | — | — | ❌ 缺失 | 新增会员 |
| `/member/creditscore` | — | — | ❌ 缺失 | 积分查询 |
| `/member/creditscore/edit` | — | — | ❌ 缺失 | 积分调整 |
| `/member/level` | — | — | ❌ 缺失 | 会员等级 |
| `/member/benefit` | — | — | ❌ 缺失 | 会员权益 |
| `/member/behavior` | — | — | ❌ 缺失 | 会员行为 |

### 2.5 任务/审批模块

| PRD 路由 | 代码路由 | 页面文件 | 状态 | 备注 |
|----------|----------|----------|------|------|
| `/task/calendar` | `/task` | `task_home_page.dart` | ⚠️ 路由不一致 | 代码用 `/task` 作为任务首页 |
| `/task/add` | — | — | ❌ 缺失 | 新建任务 |
| `/task/:id` | — | — | ❌ 缺失 | 任务详情 |
| `/task/list` | — | — | ❌ 缺失 | 任务列表 |
| `/approval/center` | — | — | ❌ 缺失 | 审批中心 |
| `/approval/:id` | — | — | ❌ 缺失 | 审批详情 |

---

## 三、占位符页面清单

以下页面存在，但只有基础 UI 结构，核心业务逻辑未实现：

| 页面 | 文件 | 问题 |
|------|------|------|
| 零售开单入口 | `retail_entry_page.dart` | 会员绑定功能未实现（TODO: 调用会员搜索接口）|
| 工作台 | `workbench_page.dart` | 快捷操作按钮未绑定路由（扫码、查序列号、查会员）|
| 审批中心入口 | `profile_page.dart` | 审批中心按钮未绑定路由 |
| 库存管理入口 | `home_page.dart` | 库存管理菜单项 `onTap: () {}` 空实现 |
| 审批中心入口 | `home_page.dart` | 审批中心菜单项 `onTap: () {}` 空实现 |
| 快速操作-查序列号 | `home_page.dart` | `onTap: () {}` 空实现 |
| 快速操作-查会员 | `home_page.dart` | `onTap: () {}` 空实现 |

---

## 四、跳转链路缺失清单

### 4.1 零售开单完整链路（Phase 4 核心）

```
PRD 要求链路：
/order/retail/entry → /order/retail/edit → /order/retail/confirm → /order/retail/payment → /order/:orderNumber

代码实际链路：
/home/retail/entry → /home/retail/product → /home/retail/confirm → /home/retail/payment → /home/retail/complete
                                                                          ↓
                                                                   ❌ 缺少 coupon-select

问题：
1. 路由路径不匹配（/order/ vs /home/）
2. 缺少优惠券选择页 /order/retail/coupon-select
3. 完成页不是 /order/:orderNumber，而是 /home/retail/complete
```

### 4.2 首页 → 订单列表 → 订单详情

```
代码链路：
/home → /home/order/list → /home/order/:orderNumber

问题：
- 链路存在，但路由路径与 PRD 不一致（PRD 要求 /order/sales-list）
```

### 4.3 首页 → 会员中心 → 会员详情

```
代码链路：
/home → /member → /member/:memberId

问题：
- 首页"会员中心"按钮跳转到 `/member`（Tab 切换），符合预期
- 会员详情链路完整
- 但缺少新增会员 /member/add
```

### 4.4 工作台 → 零售开单

```
代码链路：
/workbench → /home/retail/entry

问题：
- 工作台"零售开单"快捷操作已绑定路由 ✅
- 但其他快捷操作（扫码、查序列号、查会员）未绑定
```

### 4.5 TabBar 跳转

| 从 | 触发 | 目标 | 状态 |
|----|------|------|------|
| Tab 1 首页 | 点击 TabBar 第 2 项 | /member | ✅ 正常 |
| Tab 1 首页 | 点击 TabBar 第 3 项 | /workbench | ✅ 正常 |
| Tab 1 首页 | 点击 TabBar 第 4 项 | /task | ✅ 正常 |
| Tab 1 首页 | 点击 TabBar 第 5 项 | /profile | ✅ 正常 |

---

## 五、接口未联调清单

### 5.1 零售开单模块

| 页面 | 接口 | 状态 | 说明 |
|------|------|------|------|
| 零售开单入口 | `POST /members/search-by-phones` | ❌ 未联调 | 代码中 TODO 标注 |
| 商品选购 | `GET /product/list` | ⚠️ 模拟数据 | 使用硬编码商品列表 `_products` |
| 商品选购 | `GET /product/search` | ❌ 未实现 | 搜索功能未联调 API |
| 订单确认 | `GET /coupons/self` | ❌ 未联调 | 优惠券查询接口未调用 |
| 订单确认 | `POST /members/experience` | ❌ 未联调 | 积分抵扣计算未实现 |
| 收款 | `POST /order/shop-sale/add` | ⚠️ 已调用但路径可能错误 | 代码中调用 `/order/create` |
| 订单详情 | `GET /order-product/list` | ⚠️ 部分实现 | BLoC 已有但需验证 |

### 5.2 会员模块

| 页面 | 接口 | 状态 | 说明 |
|------|------|------|------|
| 会员首页 | `GET /members/list` | ⚠️ 已实现 | BLoC 已实现 |
| 会员首页 | `GET /members/recent` | ❌ 未实现 | 最近访问会员未实现 |
| 会员详情 | `GET /members/specified` | ⚠️ 已实现 | BLoC 已实现 |
| 会员详情 | `GET /order/list` | ⚠️ 已实现 | 消费记录已实现 |
| 新增会员 | `POST /members/add` | ❌ 未实现 | 页面不存在 |
| 新增会员 | `POST /members/check-phone` | ❌ 未实现 | 页面不存在 |

### 5.3 首页模块

| 页面 | 接口 | 状态 | 说明 |
|------|------|------|------|
| 首页 | `GET /user/self` | ⚠️ 已实现 | BLoC 已实现 |
| 首页 | `GET /dashboard/today-stat` | ⚠️ 模拟数据 | 使用硬编码统计 |
| 首页 | `GET /order/shop-sale-list` | ⚠️ 已实现 | BLoC 已实现 |
| 首页 | `GET /pending/items` | ❌ 未实现 | 待处理事项未实现 |

### 5.4 库存模块

| 页面 | 接口 | 状态 | 说明 |
|------|------|------|------|
| 盘库列表 | `GET /stock-taking/list` | ❌ 页面不存在 | — |
| 新建盘库 | `POST /stock-taking/add` | ❌ 页面不存在 | — |
| 盘库详情 | `GET /stock-taking/:id` | ❌ 页面不存在 | — |
| 仓库列表 | `GET /warehouse/list-base` | ❌ 页面不存在 | — |

---

## 六、优先级排序的后续工作清单

### P0（紧急 - 门店正常营业必需）

| 序号 | 工作项 | 路由 | 优先级说明 |
|------|--------|------|-----------|
| 1 | **修复零售开单路由路径** | 将 `/home/retail/*` 改为 `/order/retail/*` | 当前路由与 PRD 不一致，影响业务流程 |
| 2 | **实现优惠券选择页** | `/order/retail/coupon-select` | 订单确认页需要跳转优惠券选择 |
| 3 | **实现商品搜索 API 联调** | `GET /product/search` | 商品选购页搜索功能 |
| 4 | **实现会员搜索 API 联调** | `POST /members/search-by-phones` | 零售开单入口会员绑定 |

### P1（重要 - 日常业务场景覆盖）

| 序号 | 工作项 | 路由 | 优先级说明 |
|------|--------|------|-----------|
| 5 | **实现新增会员页面** | `/member/add` | 会员中心必需功能 |
| 6 | **实现积分查询页面** | `/member/creditscore` | 会员详情页需要跳转 |
| 7 | **实现积分调整页面** | `/member/creditscore/edit` | 会员详情页需要跳转 |
| 8 | **实现库存管理首页** | `/inventory/home` | 首页库存入口需要跳转 |
| 9 | **实现盘库列表** | `/inventory/stocktaking` | Phase 4 核心功能 |
| 10 | **实现新建盘库** | `/inventory/stocktaking/add` | Phase 4 核心功能 |
| 11 | **实现盘库详情** | `/inventory/stocktaking/:id` | Phase 4 核心功能 |
| 12 | **修复订单列表路由** | `/order/sales-list` | 与 PRD 保持一致 |

### P2（常规 - 提升效率和管理能力）

| 序号 | 工作项 | 路由 | 优先级说明 |
|------|--------|------|-----------|
| 13 | **实现审批中心** | `/approval/center` | 工作台入口需要 |
| 14 | **实现审批详情** | `/approval/:id` | 审批流程需要 |
| 15 | **实现调拨列表** | `/inventory/transfer` | 库存管理子模块 |
| 16 | **实现新建调拨** | `/inventory/transfer/add` | 库存管理子模块 |
| 17 | **实现调拨详情** | `/inventory/transfer/:id` | 库存管理子模块 |
| 18 | **实现序列号查询** | `/inventory/serial-search` | 首页快捷操作需要 |

### P3（可选 - 增强用户粘性）

| 序号 | 工作项 | 路由 |
|------|--------|------|
| 19 | 预订单列表 | `/order/pre-sale-list` |
| 20 | 预订单处理 | `/order/pre-sale/:id` |
| 21 | 退货列表 | `/order/return-list` |
| 22 | 退货处理 | `/order/return/:id` |
| 23 | 会员等级 | `/member/level` |
| 24 | 会员权益 | `/member/benefit` |
| 25 | 新建任务 | `/task/add` |
| 26 | 任务详情 | `/task/:id` |

---

## 七、关键问题汇总

### 7.1 路由架构问题

1. **零售开单路由不在 TabBar 体系内**
   - PRD 要求 `/order/retail/entry` 在 `/order` 下
   - 代码放在 `/home/retail/entry`（Home Tab 内）
   - 这导致零售开单流程与 TabBar 其他入口隔离

2. **订单相关路由嵌套在 `/home` 下**
   - `/home/order/list`、`/home/order/:orderNumber`
   - PRD 要求在 `/order` 下
   - 建议重构订单路由

### 7.2 页面完整性问题

| 模块 | PRD 页面数 | 已实现数 | 完成率 |
|------|-----------|---------|--------|
| 零售开单 | 6 | 5 | 83% |
| 订单管理 | 12 | 2 | 17% |
| 库存管理 | 11 | 0 | 0% |
| 会员中心 | 8 | 2 | 25% |
| 任务/审批 | 10 | 1 | 10% |
| **合计** | **60+** | **~15** | **~25%** |

### 7.3 跳转闭环问题

1. **零售开单 → 收款 → 完成** 链路存在，但完成页不是订单详情页
2. **会员详情 → 积分查询/调整** 页面缺失，链路断环
3. **首页 → 库存管理** 入口存在但目标页面缺失
4. **工作台 → 零售开单** 已实现，但其他快捷操作未绑定

---

## 八、建议

1. **立即修复**：零售开单路由路径（`/order/retail/*` vs `/home/retail/*`）
2. **立即实现**：优惠券选择页（订单确认流程中断）
3. **短期目标**：完成 Phase 4 P0 功能（零售开单+盘库+订单列表）
4. **中期目标**：完善 P1 功能（会员中心、库存查询）
5. **长期目标**：扩展 P2/P3 功能（审批、营销、报表）

---

> 审计完成时间：2026-05-17
> 审计人：Mavis Agent