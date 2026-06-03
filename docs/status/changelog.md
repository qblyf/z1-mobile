# 变更日志

## v1.32（2026-06-03）

### mall_order 详情页加操作入口（完成/取消），破坏性接口保留人工空跑

**背景**：v1.31 落了详情只读视图，按钮区被推到本期。原 PRD 列了 7 个待做操作（待支付取消/已支付取消/确认发货/完成/积分兑换/门店关联/数量统计），全做不现实。以**单人开发 + 测试 + 产品**视角做了一次取舍。

**产品决策（A/B/C 三层）**：

| 等级 | 接口 | 决策 | 理由 |
|------|------|------|------|
| A 必做 | `/mall-order/finish` | ✅ MVP 实施 | 自提送出后店员标完成 —— 高频且单步 |
| A 必做 | `/mall-order/unpaid-cancel` | ✅ MVP 实施 | 待支付订单作废 —— 高频且单步 |
| B 跳过 | `/mall-order/paid-cancel` | ❌ | 需审核流程跨模块联动，单这条做不了 |
| B 跳过 | `/mall-order/outed-of-warehouse` | ❌ | 测试环境抽样 5000+ 条 100% 自提，post 路径无数据 |
| B 跳过 | 退款 / 物流详情 / 门店订单关联 | ❌ | 各自是独立模块，留给对应迭代 |

**实施细节**：

- `mall_order_remote_datasource.dart`（增 +60 行，2 个 POST）
  - `finishMallOrder(number, {code})` → `POST /mall-order/finish` body `{mallOrderNumber, code?}`
  - `cancelUnpaidOrder(number, {remarks})` → `POST /mall-order/unpaid-cancel` body `{mallOrderNumber, remarks?}`
  - 复用 v1.31 抽出的 `_unwrapRes` helper
- `mall_order_detail_page.dart`（新增 `_ActionBar` StatefulWidget，~190 行）
  - 按订单状态决定显示哪个按钮：
    - `pendingPayment` → "取消订单"（destructive 红）
    - `paid` / `partiallyPaid` / `shipped` / `delivered` → "完成订单"（filled 蓝）
  - 二次确认对话框（CupertinoAlertDialog），点击"再想想"取消、"确认"提交
  - 成功 / 失败都有 alert 反馈，成功后触发 `MallOrderDetailRefreshRequested`
  - `_busy` 状态防双击，按钮置灰
- `mall_order-prd.md` §5 接口清单新增"状态"列：✅/🟡/🔵 三态标识

**⚠️ 破坏性接口保留人工空跑**：

按 v1.28-v1.30 的 3.B 流程，新接口要 curl 空跑验证参数名生效。本期 finish/unpaid-cancel 是**破坏性接口**——一旦跑过参数名就改了订单状态，测试数据会被污染。决策：

- ✅ datasource 实现完整 + dart analyze 0 errors
- ✅ UI 按钮 + 二次确认对话框 + 错误反馈完整
- ❌ **未空跑**真实接口
- 🛡️ 在 datasource 抽象类 docstring + PRD §5 警告段都标注"未空跑"
- 🛡️ POST body 的 `mallOrderNumber` 是单数，与详情接口 `mallOrderNumbers` 复数不一致——上线前业务方提供可作废测试订单时强制人工空跑一次（参考 v1.31 的 5 连错 + 唯一生效 curl 流程）

这是单人开发的 trade-off：**接口名约定测试覆盖不到的部分，靠 docstring + UI 二次确认对话框降低风险**，不是直接 ship。

**v1.31 文档自纠**：

实现 v1.32 任务 A（"重写 assistantIdent 协议层"）时去 grep 协议层，发现 `lib/types/api/mall-order-types.dart` **已经**把 `AssistantIdent` 正确建模为 9 字段 class（cashier/inspector/masher/guideData/engineer/operator/deliverer/qwCustomerService/recruitIdent），不是字符串。v1.31 的 PRD/changelog/detail_model 注释里我都写错成"协议层是 string，待重写"——已就地修正 4 处文档（PRD §5.2、changelog v1.31 表、detail_model 类注释、FACT.md 待办）。

**教训**：写"协议层与响应不符"前必须 grep 协议层文件确认，不能凭直觉断言。这条已进 journal。

**v1.32 文件清单**：

```
M  docs/features/mall-order-prd.md           # §5 接口表加状态列 + 警告段；§5.2 assistantIdent 行修正
M  docs/status/changelog.md                  # 本条目 + v1.31 assistantIdent 修正
M  memory/FACT.md                            # 模块状态更新 + assistantIdent 待办删除
M  z1_mobile/lib/features/mall_order/data/datasources/mall_order_remote_datasource.dart
M  z1_mobile/lib/features/mall_order/data/models/mall_order_detail_model.dart  # 注释修正
M  z1_mobile/lib/features/mall_order/presentation/pages/mall_order_detail_page.dart  # _ActionBar
```

**遗留**：
- 真机回归 `transport=post` 邮寄订单（test 账号无此数据）
- finish/unpaid-cancel 人工空跑（待业务方测试订单）

---

## v1.31（2026-05-29）

### mall_order 详情 3.B 空跑 + 3.C 落地，揪出请求参数 + 响应共 6 个坑

**背景**：v1.30 落了列表，详情接口空跑被推到 v1.31。继续走"两轮空跑"流程：第一轮验响应字段（写模型前），第二轮验请求参数（写完 datasource 后）。这次第二轮才是真正的雷区——光请求参数就试了 6 种全错才找到唯一生效的格式。

**第二轮空跑发现请求参数 5 连错**：

| 我以为的 | 真实情况 | 处理 |
|---------|---------|------|
| `?mallOrderID=43711`（int） | ❌ `90002 前端传入参数类型有误 mallOrderID` | — |
| `?id=` / `?number=` | ❌ 同 90002 | — |
| `?mall_order_id=` / `?orderID=` / `?mallOrderNumber=`（单数） | ❌ 同 90002 | — |
| `POST + body` | ❌ `90000 请求方法无效` | — |
| **`GET ?mallOrderNumbers=<num1>,<num2>`**（复数 + 逗号串） | ✅ 唯一生效 | datasource 用此 |

如果按"REST 风格 `/mall-order/:id`"或"`mallOrderID` 跟列表保持单数风格"的直觉写代码，会得到一个"详情页打开就报错"的死循环。**列表 + 详情两个接口的同一个字段，参数名风格完全不一致**——列表是 `status` 单数收逗号串，详情是 `mallOrderNumbers` 复数收逗号串。这种不对称只能 curl 试出来。

**响应差异**（5000+ 抽样）：

| 差异点 | 实际 | 协议层假设 | 处理 |
|--------|------|-----------|------|
| 顶层 | `{code:10000, res: MallOrder[]}` | 单对象 | datasource 取 `res[0]` |
| 订单不存在 | HTTP 200 + `res:[]` | HTTP 404 | 空数组转 `Failure("订单不存在")` |
| `assistantIdent` | object（7 角色字段全 null） | 协议层已建模 `AssistantIdent`（9 字段）—— 我之前错判为 string，实际已对 | MVP 展示层未用，无需改 |
| `info[].skuName/serviceName/itemName` | **不返回** | 假设 join 返回 | fallback `"商品/服务/定制 x{qty}"` |
| `transport=post` 全字段 | 抽样 5000+ 条 100% `store` | 期待覆盖 post | 测试环境无 post 数据，留待真机回归 |
| 6 个 nullable 字段 | 100% null | required | 模型 `?` 兜底 |

**本次落地的文件**：

- `z1_mobile/lib/features/mall_order/data/datasources/mall_order_remote_datasource.dart`（增 +44 行）
  - 新增 `getMallOrderDetail(number)`：`GET /mall-order/detail?mallOrderNumbers=<NUM>`
  - 抽 `_unwrapRes<T>` helper：list/detail 复用"剥 code/res + 错误兜底"
  - 详情场景的"业务码 10000 但语义 404"通过内部 `_NotFound` 异常表达
- `z1_mobile/lib/features/mall_order/presentation/bloc/mall_order_detail_bloc.dart`（新增 ~110 行）
  - 2 个 event：Load(number) / Refresh
  - 4 个 state，全部继承 `MallOrderDetailState(number)` —— BLoC **不持有** `_currentNumber` 可变字段，刷新从 `state.number` 读
- `z1_mobile/lib/features/mall_order/presentation/pages/mall_order_detail_page.dart`（新增 ~430 行）
  - Cupertino 风格，CustomScrollView + CupertinoSliverRefreshControl
  - 状态徽章 + 订单信息 + 收货人（自提订单跳过）+ 行项明细 + 金额合计 + 备注
  - 下拉刷新 `firstWhere` 加 15s timeout + try/catch，避免 BLoC dispose 时的 StateError
- `z1_mobile/lib/features/mall_order/presentation/utils.dart`（新增）
  - 抽 `formatMallOrderTime` + `mallOrderStatusColors`，列表 + 详情共用
  - **同时修了一个隐性 bug**：列表页旧版把 paid/shipped/all 合并成蓝色一组，详情按 6 tab 各自上色——以详情的 6 色版为准统一，列表的状态徽章颜色随之变化
- `z1_mobile/lib/features/mall_order/data/models/mall_order_detail_model.dart`（注释更新）
  - 类注释贴入 4 种 status 抽样响应样本 + 关键差异表
- `z1_mobile/lib/features/mall_order/presentation/pages/mall_order_list_page.dart`（小改）
  - `_MallOrderCard.onTap` 接入 `context.push('/home/mall-order/${number}')`
  - `_StatusBadge._colorsFor` / `_formatTime` 改用 utils
- `z1_mobile/lib/core/router/app_router.dart`
  - 加 `mall-order/:number` 子路由，跳转到 `MallOrderDetailPage`
- `docs/features/mall-order-prd.md`
  - 第五节加 §5.2 "详情接口真实响应"，请求参数 + 响应差异两张表

**得到的方法论补丁**：

- 第二轮空跑（写完 datasource 后）的"请求参数验证"必须独立成 checkpoint。第一轮验响应、第二轮验请求，缺一不可——列表/详情这种姐妹接口的参数名 **不能假设保持一致**。
- 详情接口"业务码成功 + 数据为空" = 资源不存在，是后端常见反模式（HTTP 200 不可信）。datasource 层就要识别并转 Failure，否则 BLoC 拿到 `Loaded(null)` 之后一路崩溃。
- 跨页面的 `_statusColors` / `_formatTime` 这种工具函数复制粘贴，**只要分组规则不同就一定埋 bug**——以更细的版本为准统一。

**验证**：`dart analyze` 0 errors（249 issues 全是 info/warning，且 mall_order 模块清零）。

**资源**：
- mall_order PRD：[`docs/features/mall-order-prd.md`](../features/mall-order-prd.md)
- 列表/详情页路由：`/home/mall-order/list` / `/home/mall-order/:number`

**下一步**：商城订单全功能 ≠ MVP。本次详情仅覆盖核心展示，待补：
1. 真机回归（test 账号无 `transport=post` 数据，需生产/预发数据）
2. 订单操作入口（取消、退款、确认收货、查看物流）—— 需对应模块就绪

~~3. `assistantIdent` object 结构回写协议层~~ —— **核对协议层后发现已正确建模**（`AssistantIdent` 含 9 字段），是我此前误判，无需改动。

---

## v1.30（2026-05-29）

### mall_order 列表 3.C 落地（datasource + BLoC + page + router） + 第二轮空跑发现请求参数 3 个坑

**背景**：v1.29 把空跑流程文档化后，接着用同一套方法做 mall_order 列表的 3.C 落地。
**新发现**：写完 datasource 后再跑 curl 验证参数名，揪出后端 3 个不写进文档就永远不会知道的请求参数坑。

**第二轮空跑发现**（写 datasource 后、写 BLoC/page 前）：

| 我以为的（写代码时） | 真实情况（curl 验证后） | 修正 |
|---------------------|-----------------------|------|
| `pageSize=20` 控制每页 | ❌ 被忽略，返回固定 100 条上限 | 改用 `limit` |
| `page=1,2,3` 翻页 | ❌ 被忽略（page=1/2/999 同样结果） | 改用 `offset=(page-1)*pageSize` |
| `status[]=21&status[]=22` 数组筛选 | ❌ 被忽略，等同不筛选 | 改用 `status=21,22,23` 逗号串 |

如果直接照 `page+pageSize+status[]` 套路写完整套 BLoC + 页面，会得到一个"列表能加载但筛选 tab 完全无效、上拉总加同样数据"的诡异 bug，回头不知道是哪一层错了。空跑 5 分钟试 6 种参数格式，bug 直接定位到 datasource 一行代码。

**本次落地的文件**：

- `z1_mobile/lib/features/mall_order/data/datasources/mall_order_remote_datasource.dart`（新增）
  - `MallOrderListParams`：对外暴露 `page+pageSize+status`，内部转 `offset+limit+status=逗号串`
  - `MallOrderRemoteDataSourceImpl`：剥 `{code, res}` 包装，业务码 ≠ 10000 转 `Failure`
- `z1_mobile/lib/features/mall_order/presentation/bloc/mall_order_list_bloc.dart`（新增）
  - 4 个 event：Load / LoadMore / Refresh / TabChanged
  - 5 个 state：Initial / Loading / Loaded / LoadingMore / Error（全部携带当前 tab）
  - 分页 BLoC 自己管，pageSize=20，hasReachedMax 判定 list.length < pageSize
- `z1_mobile/lib/features/mall_order/presentation/pages/mall_order_list_page.dart`（新增）
  - Cupertino 风格，6 个 tab 横向滚动
  - `CupertinoSliverRefreshControl` 下拉刷新 + ScrollController 90% 触发上拉加载
  - 状态徽章按 6 tab 分组配色（已完成绿 / 退款红 / 待支付橙 / 其它蓝）
  - 详情 onTap 留 TODO（等 `/mall-order/detail` 空跑）
- `z1_mobile/lib/core/router/app_router.dart`：新增 `/home/mall-order/list` 路由
- `z1_mobile/lib/features/mall_order/data/models/mall_order_model.dart`：注释补"请求参数差异"段
- `docs/features/mall-order-prd.md` §5.1：响应差异表 + 请求参数差异表（坑！）
- `docs/guides/ai-doc-type-workflow.md`：
  - §2.2 "空跑要回答的 4 个问题" → 5 个，新增"请求参数名是否真的生效"
  - §2.2 实战案例分两轮（响应层 + 请求层）

**验证**：

- `flutter analyze lib` → 0 errors（207 个 info 与本次改动无关）
- curl 6 个 tab 全部命中预期 status 集合
- 翻页 offset=0/3/6 limit=3 三页连续无重复

**下一步**：空跑 `/mall-order/detail`，写 `MallOrderDetailBloc` / `MallOrderDetailPage`，接入卡片 onTap 跳详情。

---

## v1.29（2026-05-29）

### 开发流程文档化「真实接口空跑」 + mall_order 列表首次空跑

**背景**：v1.28 已经在 AGENTS.md 把阶段三拆成 3.A / 3.B / 3.C，但 `docs/guides/ai-doc-type-workflow.md` 还停留在 v1.27 的"单一真实源"写法，且没有讲"如何用账号密码拿 token 调真实接口"。本次：① 把开发流程指南同步到两层模型 + 接口空跑；② 用真实凭证实际跑一次 `/mall-order/list`，把发现回写到模型/PRD/流程文档。

**真实接口空跑结果**（`GET /mall-order/list?page=1&pageSize=5`，z1-fun.zsqk.com.cn/deno，抽样 100 条）：

| 发现 | 影响 | 已处理 |
|------|------|--------|
| 顶层是 `{code:10000, res:[...]}` 不是 `{list,total}` | datasource 取数路径要改 | 写进 PRD §5.1、模型注释 |
| `customerIdent` 是 string，不是 int | 模型字段类型错了 | 模型字段改为 String、`fromJson` 用 `toString()` |
| 响应没有 join `customerName` / `skuName` | 列表卡片要异步补查会员 / 摘要走 fallback | 模型注释已声明，BLoC 阶段补查 |
| 100% `transport=="store"`、`postInfo/postAmount` 都是 null | 自提订单是常态 | 模型默认 transport=store，相关字段 `?` 可空 |
| 状态分布：`7` ~55 条 / `31` ~44 条 / `42` 1 条 | 6 tab 映射验证可用，但 UI 要考虑空 tab 体验 | PRD 已知差异段记录 |

**文档/代码改动**：

- `docs/guides/ai-doc-type-workflow.md`（397 → 700+ 行）：
  - §1.1 "单一真实源" → "两层类型模型"，与 AGENTS.md 对齐
  - §1.2 新增"类型驱动 + 真实响应驱动"原则
  - §2.1 阶段三流程图拆成 3.A 模型 / 3.B 接口空跑 / 3.C 落地
  - §2.2 ⭐ 新增"接口空跑标准操作"完整章节：
    - 准备工作：用账号密码拿 token（含 curl 一键脚本、4 个已知坑、凭证管理纪律）
    - 如何空跑（Flutter 内 probe 代码模板）
    - 3 类响应都要跑（正常 / 空 / 错误）
    - 空跑要回答的 4 个问题
    - 空跑产出物清单
    - 实战案例：`/mall-order/list` 真实发现表
  - §5 Flutter 开发规范以 mall_order 为例改写
  - §7 完整流程示例改成 mall_order 列表，Step 4 拆成 4a/4b/4c
  - §8 FAQ 补 Q5-Q7

- `docs/features/mall-order-prd.md`：新增 §5.1 "真实响应已知差异" 6 行差异表

- `z1_mobile/lib/features/mall_order/data/models/mall_order_model.dart`：
  - 顶部注释加完整真实响应 JSON 样本 + 关键差异列表
  - `customerIdent` 类型从 `int` 改为 `String`，`fromJson` 用 `toString() ?? ''`

**已知坑（凭证管理）**：

- curl 登录必须加 `-i`，否则后端返回 schema 描述而不是真值 JSON
- token / 账号密码不进文档、commit、journal，仅在会话内传递
- HTTP 200 ≠ 业务成功，必须双重判定 HTTP 状态 + `data.code == 10000`

**验证**：`flutter analyze lib/features/mall_order` → No issues found。

**下一步**：进入 3.C，写 `MallOrderRemoteDataSource` → `MallOrderListBloc` → 列表页 UI。详情接口 `/mall-order/detail` 在写 datasource 前再空跑一次。

---

## v1.28（2026-05-29）

### mall_order 模块第一步：展示层模型就绪（B 计划）

**背景**：v1.27 立完两层类型模型的规范后，第一个落地新模块是商城订单。PRD 已完备
（`docs/features/mall-order-prd.md`），协议层 21 个类型完整（`lib/types/api/mall-order-types.dart`），
但协议层 `MallOrder.fromJson` 用了 `required` 严约束，且 list 接口的真实响应字段未跑过
——直接照抄协议层模型作为展示层模型有运行时崩溃风险。

采取**分阶段策略**：本次只做模型层，下次会话先用真实响应跑通后再写 datasource / 页面。

**本次落地**：

| 文件 | 内容 |
|------|------|
| `lib/features/mall_order/data/models/mall_order_model.dart` | 列表窄视图：`MallOrderModel`（11 字段，从协议层 38 字段中精选）+ `MallOrderDisplayStatus` 枚举（12→6 状态压缩，含完整映射表注释 + `apiStatusValues` 转换给接口用） |
| `lib/features/mall_order/data/models/mall_order_detail_model.dart` | 详情视图：`MallOrderDetailModel`（聚合 summary + lineItems + shippingInfo + 折扣 / 积分 / 邮费）+ `MallOrderLineItem`（扁平化 `MallOrderInfo` 联合类型为商品/服务/非标统一行项，含 `unknown` 兜底）+ `MallOrderShippingInfo`（含手机号脱敏 getter） |

**关键设计决策**：

1. **不调协议层 `MallOrder.fromJson`**：协议层 `required` 约束严格，list/detail 实际响应可能缺字段 → 展示层直接读 Map，缺失字段兜底默认值。
2. **`MallOrderInfo` 联合类型容错**：协议层 `fromJson` 遇到未知子类型抛 `ArgumentError`；展示层 `MallOrderLineItem.fromJson` 改为 `unknown` 兜底，避免后端新增子类型时崩溃。
3. **状态压缩规范化**：`MallOrderDisplayStatus` 注释完整声明 12→6 映射表（已评价 8 归入完成 tab，PRD 未提及但务实选择），符合 v1.27 规范。
4. **手机号脱敏**：`maskedMobilePhone` getter 复用 PRD 中的 `139****6666` 格式。
5. **元/分单位**：所有金额字段沿用 `OrderModel` 的 `*Yuan` getter 命名约定。

**验证**：
- `flutter analyze lib/features/mall_order` → **No issues found**
- `flutter analyze lib` → 207 issues / 0 errors（与改前一致，未引入新问题）

**下一会话计划**：
1. 建 `mall_order_list_remote_datasource.dart` + `mall_order_detail_remote_datasource.dart`，对真实接口 `/mall-order/list` 与 `/mall-order/detail` 做空跑，把响应字段对齐展示层模型
2. 两个 BLoC + 列表页（6 tab）+ 详情页 + 物流占位页
3. router + DI 接入 + 入口按钮（首页或工作台）

---

## v1.27（2026-05-29）

### 架构决定：从"单一真实源"转向两层类型模型

**问题**：v1.26 留作后续的"16/18 类型文件被 features/data/models 重复定义破坏单一真实源"原则，在试图修复时发现是误诊：

- `lib/types/api/order-types.dart` 中的 `OrderProduct` 有 18 个字段（含 `costPrice` / `commission` / `rebate`），但**零个调用方**
- `lib/features/order/data/models/order_product_model.dart` 中的 `OrderProductModel` 只有 9 个字段，扩展了 `productName` / `skuCode`（这些字段后端通过 join 拼到响应里，不在数据库实体表中）
- 对 5 对候选枚举（OrderStatus×2 / StocktakingState / PurchaseState / TransferState）逐一比对后，发现取值集合都不兼容，**无法直接用协议层替换展示层**

**根因**：
- 时序错位：v1.x 早期写 features 模型时，types/api/ 还没翻译完
- 翻译源错误：z1-mid 的 TS 类型描述的是**数据库实体**，不是 **API 响应 schema**。响应通常包含 join 字段、聚合字段，且枚举状态值被业务压缩
- 缺乏字段级验证：v1.25 类型闭环只检查文件是否存在 + 是否被引用，没检查真实响应是否对得上

**架构决定**：项目正式采用**协议层 + 展示层**两层模型：

| 层级 | 路径 | 角色 |
|------|------|------|
| 协议层 | `lib/types/api/` | 后端实体的 Dart 镜像，作为字段类型 / 枚举取值的契约基准 |
| 展示层 | `lib/features/*/data/models/` | 实际 API 响应视图 + UI 派生状态（fromJson / copyWith / getter） |

**两层关系**：
- 展示层字段类型可引用协议层枚举（去重）
- 展示层可扩展协议层没有的字段（join / 聚合）
- 展示层枚举可压缩协议层取值（5→3），但必须在注释中**显式声明映射表**
- 禁止字段名静默重命名：旧名保留为主字段，新名作为 getter

**本次落地**（B' 计划：仅一处安全去重 + C 计划：规范升级）：

| 文件 | 操作 |
|------|------|
| `lib/features/member/data/models/member_order_model.dart` | 删除本地 `OrderStatus` enum，改用 `import + export` 复用 `order/data/models/order_model.dart` 中的同名 enum |
| `lib/features/order/data/models/order_model.dart` | `OrderStatus` 注释升级：表格化声明后端 5 个 status int → UI 3 个状态的压缩映射，作为新规范的标杆示例 |
| `AGENTS.md` | 重写「核心规则」：把"⚠️ 类型定义是唯一真实源"换成"⚠️ 两层类型模型"，配可做/不可做对照表 + 重复定义复用规则 |
| `AGENTS.md` | 同步更新「开发流程·阶段二/三」措辞：协议层契约 vs 展示层模型分别承担什么职责 |

**为什么剩余 4 对枚举不去重**：

| 枚举对 | 取值差异 | 不去重原因 |
|--------|---------|-----------|
| `StocktakingState` | 协议层 0/1/2/3/4，展示层 1/2/3 | 展示层压缩了"已撤销"/"已暂停"，业务决策 |
| `PurchaseState` | 协议层含 7 种状态，展示层仅 3 种 | 同上 |
| `TransferState` | 协议层 int，展示层 string | 翻译方向不一致，需更大范围重构 |
| `OrderStatus`（协议层 vs 展示层） | 协议层 1-5 int，展示层 pending/completed/refunded string | 同上 |

**验证**：
- `flutter analyze lib`：208 issues found（全部 warning/info），**0 errors**
- `flutter analyze lib/features/member lib/features/order`：57 issues found，0 errors，确认 `OrderStatus` 去重无回归
- 调用方 `member/presentation/pages/member_detail_page.dart` 中的 `OrderStatus.completed` 引用仍然有效（通过 `export` 透传）

**留给后续的工作**：
- 业务侧待开发：mall-order 模块 UI、41 个未使用端点的归位
- 工程债：4 处小 TODO（扫码入口 / 序列号商品列表跳转 / auth 本地存储）

### simplify 评审后的增量修复

**1. 效率热路径**：`member_detail_page.dart:_buildOrderItem` 每次 build 调用 `statusEnum` 4 次（含 `statusLabel` 内部 1 次），改为提取 `isCompleted` / `statusColor` 局部变量复用，降到 1 次。

**2. 潜在运行时崩溃**：`member_order_model.dart` 的 `fromJson` 原本假设 `json['status']` 是 String，但协议层规定 status 是 int（1-5）。引入 `_parseStatus(dynamic)` 静态方法，运行时按 int / String 类型分支调用 `OrderStatus.fromValue` 或 `OrderStatus.fromString`，避免后端切换字段类型时 cast 崩溃。

**3. TODO 规范化**：把 4 处 backlog TODO 升级为更具体的实施提示，明确依赖与同步点：
- `product_tab.dart:140` / `service_tab.dart:128`：`TODO(扫码)` 指向 `mobile_scanner` 包 + 与搜索框联动
- `product_tab.dart:293`：`TODO(序列号商品选择页)` 列出依赖的路由 / 页面 / API
- `auth_local_datasource.dart` saveUser/getUser/clearUser：`TODO(用户信息持久化)` 指向 SharedPreferences + jsonEncode 实现

**4. 死代码标注**：`AuthLocalDataSource` 整套（接口 + 实现）目前没有任何调用方，也未在 `injection.dart` 注册。在文件顶部加详细注释说明保留意图，避免后续被误删，同时让接入步骤可追溯。

---

## v1.26（2026-05-29）

### 三维代码体检后的一轮修复：编译错误 / 硬编码 / 路由 / 搜索过滤

**问题**：v1.25 完成 PRD+API+类型 三维 100% 闭环后，对 Flutter 代码做反向体检发现：

- 3 处编译 error：`ApiEndpoints.shopSaleList` 已重构为函数（接受 query params），但 home / order_list / member 三个 datasource 仍按属性方式调用
- 5 处硬编码 API 路径，未走 `ApiEndpoints` 常量：
  - `retail_payment_page.dart:101` → `/order/sale-shop-add`
  - `member_remote_datasource.dart:21` → `/members/list-phones`
  - `member_remote_datasource.dart:39` → `/member/specified`
  - `member_creditscore_page.dart:34` → `/members/creditscore`（`ApiEndpoints` 中无对应常量）
  - `member_creditscore_edit_page.dart:57` → `/members/creditscore/adjust`（同上）
- 1 处路由未注册：`retail_confirm_page.dart:476` 跳转 `/home/retail/coupon-select`，但 `app_router.dart` 没有该 GoRoute，`coupon_select_page.dart` 已实现却挂不上
- 1 处常量重复定义：`api_constants.dart` 与 `api_endpoints.dart` 存在双源，且 `userSelf` 路径冲突（`/user/self` vs `/members/self`）
- 1 处 TODO：商品搜索关键字只更新 state.searchKeyword 但未应用过滤（PRD 中标注的 TODO）

**修复**：

| 文件 | 操作 |
|------|------|
| `home/data/datasources/home_remote_datasource.dart` | `ApiEndpoints.shopSaleList` → `ApiEndpoints.shopSaleList()` |
| `order/data/datasources/order_list_remote_datasource.dart` | 同上 |
| `member/data/datasources/member_remote_datasource.dart` | 同上 + 两处硬编码改用常量 |
| `core/api/api_endpoints.dart` | 新增 3 个常量：`memberSpecifiedPath` / `memberCreditscore` / `memberCreditscoreAdjust` |
| `core/router/app_router.dart` | 新增 `/home/retail/coupon-select` → `CouponSelectPage` 路由 |
| `retail/presentation/pages/retail_payment_page.dart` | 硬编码 `/order/sale-shop-add` → `ApiEndpoints.shopSaleAdd` |
| `member/presentation/pages/member_creditscore_page.dart` | 硬编码 `/members/creditscore` → `ApiEndpoints.memberCreditscore` |
| `member/presentation/pages/member_creditscore_edit_page.dart` | 硬编码 `/members/creditscore/adjust` → `ApiEndpoints.memberCreditscoreAdjust` |
| `core/constants/api_constants.dart` | 删除业务端点字段，仅保留 baseUrl / 超时 / refreshToken（拦截器循环引用前需要的字符串） |
| `retail/presentation/pages/product_tab.dart` | `_buildSpuGrid` 应用 `searchKeyword` 本地过滤（按 spuName / brand / series 子串匹配） |

**验证**：
- `flutter analyze`：250 issues found（全部 warning/info），**0 errors**（修复前 3 errors）
- `app_router.dart`：单独分析无 issue
- `product_tab.dart`：单独分析无 issue

**未处理（留作后续）**：
- 营销/采购/调拨/盘库等模块仍存在大量 ApiEndpoints 中已定义但 features/ 层未消费的端点（41/71 unused）—— 业务侧待开发
- 16/18 类型文件的"单一真实源"原则被 features/data/models 重复定义破坏 —— 架构级问题，需独立专项
- 扫码入口、序列号商品列表页、auth 本地存储 4 处 TODO 留待业务开发

---



### API 文档全面体检与重建：73% → 100% 闭环

**问题**：22 个 PRD 在 v1.24 完成 7 维度闭环后，对 API 文档做体检发现：
- `docs/api/` 只有 3 个文件（订单 reference + 订单 examples + 闭环检查），其余 8 个模块完全缺失
- `api-product-closure-check.md` v1.0 基于 `feature-list.md` 规划清单，与代码事实脱节
- 代码 `api_endpoints.dart` 实际有 71 个端点，PRD 只引用了其中 55 个（77%），16 个端点完全没文档

**修复**：

| 文件 | 操作 | 内容 |
|------|------|------|
| `docs/api/api-index.md` | 新建 | 按 7 大模块索引 71 个端点，每条标注引用它的 PRD |
| `docs/api/api-product-closure-check.md` | 重写 v1.0 → v2.0 | 用代码端点做唯一真实源，逐模块统计闭环度 |
| `docs/features/auth-prd.md` | 新建 | 认证模块（login / refresh / logout / self）首份 PRD |
| `retail-detail-prd.md` | 增补 9.2 节 | 补 cash-coupon / renew-subsidy / coupon-class / ahs 共 6 个端点 |
| `stocktaking-detail-prd.md` | 增补 7.2 节 | 补 stock-taking-end / restocktaking / :id/products / plan-list |
| `transfer-detail-prd.md` | 接口表追加 | 补 transfer/detail + transfer-lock/received |
| `mall-order-prd.md` | 接口表追加 | 补 points-redeem/order/to-mall-order |
| `category-select-prd.md` | 接口表完善 | 显式标注 mall-category/list（之前隐含） |

**最终闭环度**：

```
═══ 三维总校验 ═══
✅ 7 维度审查：23 个 PRD 全部通过（路由/布局/交互/接口/状态/异常/关联）
✅ 类型文件引用：18 个类型文件全部对齐，0 处断裂
✅ API 端点闭环：71/71（100%）
```

**关键发现并已处理**：
- 代码已实现但 PRD 未引用的 16 个端点全部归位
- 优惠/补贴/回收子领域（9 端点）原 PRD 完全未涉及，已合并到 retail-detail-prd
- 盘库 4 个操作接口 + 调拨 1 个入库接口已补到对应 PRD
- 认证模块从 0% → 100%（新建 auth-prd.md）

**统计指标对比**：

| 维度 | v1.0（5/28） | v2.0（5/29）| 修复后 |
|------|-------------|-------------|--------|
| 数据来源 | feature-list 规划 | api_endpoints.dart 代码事实 | 同左 |
| 端点闭环率 | P0-P1 95%（虚高）| 77%（实际） | **100%** |
| 模块覆盖 | 1/9（仅订单） | 1/9 + 总索引 | 1/9 + 总索引 + auth |

---

## v1.24（2026-05-29）

### 真实闭环校验：补全 4 个 PRD 缺失的「路由」维度 + 修复 1 处类型文件名 typo

**问题**：v1.23 完成 7 维度章节补全后，进一步做真实闭环校验（不仅是章节齐全，还要类型引用 / PRD 交叉引用 / 路由维度都对得上），发现：

- 4 个 PRD 缺「路由」维度章节
- 1 处类型文件引用拼错（`pre-sale-order-types.ts` → `pre-sale-order-types.dart`）

**修复**：

| 文件 | 新增章节 | 内容 |
|------|---------|------|
| product-service-select-prd.md | 〇、页面路径 | `/home/retail/product` → `retail_product_page.dart` |
| category-select-prd.md | 〇、嵌入路径 | 嵌入 `/home/retail/product` 商品 Tab 左侧分类侧栏 |
| service-select-prd.md | 〇、嵌入路径 | 嵌入 `/home/retail/product` 服务 Tab |
| print-receipt-prd.md | 〇、触发路径 | `/home/retail/payment` / `/home/retail/detail` / `/order/:orderNumber` 触发 |
| product-select-page-design.md | 〇、页面路径 | `/home/retail/product-select` → `retail_product_page.dart` |
| pre-sale-order-prd.md | typo 修正 | `pre-sale-order-types.ts` → `pre-sale-order-types.dart` |

**校验脚本结果**（最终）：

```
共 22 个 PRD
✅ 全部 22 个 PRD 通过 7 维度审查（路由/布局/交互/接口/状态/异常/关联）
✅ 类型文件引用闭环：18 个类型文件全部对得上，0 处断裂
✅ PRD 交叉引用闭环：0 处断裂
```

**闭环维度说明**：本次校验从「章节齐全」推进到「引用真实可达」——即使章节完整，类型文件名拼错、PRD 互相引用断裂也不算闭环。

---

## v1.23（2026-05-28）

### 补全剩余 13 个 PRD 的标准章节

**问题**：v1.22 处理完 3 个偏薄 PRD 后，还有 13 个 PRD 缺 1-2 个标准维度（多数是状态流转 / 模块关联）。

**修复方法**：从 3 类源头提取真实事实，不瞎编：
- 类型文件枚举（`order-types.dart` / `purchase-types.dart` / `transfer-types.dart` / `stocktaking-types.dart` / `task-types.dart` / `serial-types.dart` 等）
- Flutter 已实现的页面跳转代码（`home_page.dart` / `workbench_page.dart` / `member_*_page.dart` / `inventory_*_page.dart` 等的 `context.push` 调用，附行号）
- 后端接口定义（`z1-mid/src/types/`）

**改动**：

| 文件 | 新增章节 | 行数变化 |
|------|---------|---------|
| retail-detail-prd.md | 状态流转 + 模块关联 | 767 → 860 |
| member-detail-prd.md | 状态流转 + 模块关联 | 519 → 580 |
| task-detail-prd.md | 状态流转（TaskStatus 实事说明）+ 模块关联 | 412 → 493 |
| product-select-page-design.md | 状态流转 + 异常边界 + 模块关联 | 403 → 469 |
| category-select-prd.md | 状态流转 | 433 → 463 |
| stocktaking-detail-prd.md | 状态流转 + 模块关联 | 374 → 457 |
| order-list-detail-prd.md | 状态流转（OrderStatus）| 417 → 455 |
| profile-detail-prd.md | 核心交互逻辑 + 状态流转 | 330 → 382 |
| approval-center-detail-prd.md | 已在 v1.22 完成 | — |
| home-detail-prd.md | 状态流转 + 模块关联 | 221 → 270 |
| serial-query-detail-prd.md | 状态流转 + 模块关联 | 186 → 269 |
| workbench-detail-prd.md | 状态流转 + 模块关联 | 210 → 263 |
| inventory-home-detail-prd.md | 状态流转 + 模块关联 | 215 → 261 |
| print-receipt-prd.md | 核心交互逻辑 + 状态流转 | 227 → 304 |
| order-change-prd.md | 状态流转 + 异常边界 | 209 → 262 |
| purchase-detail-prd.md | 状态流转 + 模块关联 | 154 → 250 |
| transfer-detail-prd.md | 状态流转 + 模块关联 | 162 → 233 |

**记录的真实状态枚举**：
- `OrderStatus`（5 种）—— 订单列表/零售开单
- `PurchaseState`（3 种）/ `PurchaseOrderStatus`（7 种）—— 采购
- `TransferState`（7 种）—— 调拨
- `StocktakingState`（2 种）/ `StocktakingPlanState`（2 种）/ `StocktakingOnDutyStatus`（4 种）—— 盘库
- `TaskStatus`（valid/invalid）—— 任务（明确指出非工作流状态）
- `GoodsStatus`（in_stock/sold/transferred）/ `TraceType`（4 种）—— 序列号

**已严守"不瞎编"原则**：
- 每条跳转关系附文件:行号引用
- 找不到状态机的模块（home / workbench / profile / inventory-home / serial / category-select / member）明确写"无业务状态机"+ 列状态字段，没硬塞流转图
- task 模块声明 `TaskStatus` 只是启用/停用，工作流状态由产品语义推断且需后端确认
- print-receipt / order-change 明确标注"Flutter/z1-pwa 均无完整实现"，本节为产品规划而非源码事实

**最终结果**：22 个 PRD 全部通过 7 维度完整性审查（路径 / 布局 / 交互 / 接口 / 状态 / 异常 / 关联）。

---

## v1.22（2026-05-28）

### 补充 3 个偏薄 PRD 的核心章节

**问题**：v1.21 完成空壳清理后，3 个 PRD 仍缺关键维度（核心交互逻辑 / 异常边界 / 状态流转 / 模块关联）。

**修复方法**：从源码提取真实事实补充，不瞎编。三处源头：
- z1-pwa Web 参考实现（`/Users/fan/www/AI/z1/z1-pwa/src/components/Sales/CreateOrder/`、`/Users/fan/www/AI/z1/z1-pwa/src/components/mobile/SelectService.tsx` 等）
- Flutter 已实现代码（`z1_mobile/lib/features/retail/`、`workbench/`）
- 后端接口定义（`/Users/fan/www/AI/z1/z1-mid/src/model/z1/approval.ts`）

**改动**：

| 文件 | 补充章节 | 行数变化 |
|------|---------|---------|
| product-service-select-prd.md | 六、核心交互逻辑 / 七、异常边界 / 八、状态流转 / 九、模块关联 | 311 → 474 |
| service-select-prd.md | 六、核心交互逻辑 / 七、状态流转 / 八、异常边界 / 九、模块关联 | 163 → 232 |
| approval-center-detail-prd.md | 四、核心交互逻辑 / 五、状态流转 / 六、模块关联 | 213 → 340 |

**关键发现并记入文档**：
- z1-pwa 审批中心未原生实现，全部走 iframe 跳到 S1（`s1.zsqk.com.cn`），Flutter 端有 WebView vs 原生两种路线选择
- 商品搜索在 Flutter bloc 中只更新 keyword 但未应用过滤（已在 PRD 标注 TODO）
- 服务数量固定为 1，多次添加按多条记录处理（参考 z1-pwa 实现）
- 14 类 ApprovalType 中只有 4 类（折扣/采购/改价/退货）能在源码中找到对应业务审批接口，其余 10 类需向后端确认
- z1-pwa Web 端 `getProductPriceList` 写死 `limit:10000`，Flutter 改为按分类分页加载

**结果**：3 个 PRD 通过完整性审查（包含所有 7 个标准维度），新增内容均附带文件:行号引用，可追溯。

---

## v1.21（2026-05-28）

### 文档深度清理：删除空壳章节、合并重复占位

**问题**：v1.19 批量清理留下了 14 个 PRD 中的空壳章节（章节标题保留，下方只剩"字段类型见 xxx-types.dart"占位）和 9 个文件的重复占位提示。

**改动**：

| 文件 | 删除行数 |
|------|---------|
| retail-detail-prd.md | -42 |
| member-detail-prd.md | -36 |
| stocktaking-detail-prd.md | -22 |
| serial-query-detail-prd.md | -16 |
| home-detail-prd.md | -16 |
| product-service-select-prd.md | -14 |
| task-detail-prd.md | -14 |
| inventory-home-detail-prd.md | -12 |
| order-list-detail-prd.md | -12 |
| workbench-detail-prd.md | -12 |
| profile-detail-prd.md | -8 |
| purchase-detail-prd.md | -6 |
| transfer-detail-prd.md | -6 |
| approval-center-detail-prd.md | -4 |

**清理规则**：
- 整章删除：章节标题下仅剩占位提示（≤3 行有效内容）的章节直接删除
- 合并占位：同一接口章节下多个占位提示合并为单条
- 头部声明不变：文档顶部的「类型唯一真实源」声明保留

**结果**：14 个 PRD 共减少 220 行无效内容，每个文件最多保留 1 处占位提示。

---

## v1.20（2026-05-28）

### 新增：商城订单类型文件

**问题**：`mall-order-types.dart` 缺失，商城订单模块开发阻塞。

**改动**：
- 从 `z1-mid/src/types/mall-order-types.ts`（1030 行 TS）翻译生成 Dart 类型文件 `lib/types/api/mall-order-types.dart`（约 700 行）
- 通过 `flutter analyze`：0 errors / 0 warnings（仅项目通用的文件命名 info）
- 已在 `lib/types/api.dart` 导出
- mall-order-prd.md 状态从「阻塞」改为「类型已就绪，待 UI 开发」
- AGENTS.md 类型文件清单 17 → 18

**类型清单**（17 个类/枚举）：
- 枚举：`MallOrderStatus`、`MallOrderTransportType`、`DiscountInfoType`、`AssistantIdentType`、`MallOrderField`
- 联合类型基类：`MallOrderInfo`（商品/服务/非标）、`MallOrderDiscountInfo`（6 种折扣）
- 主类：`MallOrder`、`OrderMallOrderDetail`
- 辅助类：`MallOrderPostInfo`、`MallOrderCoupon`、`MallOrderCashCouponInfo`、`MallOrderService`、`DeliveryInfo`、`BackServiceInfo`、`AssistantIdent`

**遗留依赖**（用 `dynamic` 或 typedef 兜底，待后续按需生成）：
- `NetSale`/`NetSalePlatformType` → `net-sale-types.dart`
- `OrderService` → `order-service-types.dart`
- `CouponID`/`CouponClassID`/`ItemID`/`LabelID` → 各自类型文件

---

## v1.19（2026-05-28）

### 文档大整理：清除字段定义违规、规整结构

**问题**：23 个 PRD 直接复制了 Dart 类定义、TS interface 或带类型字段表，违反"类型唯一真实源"规则；`docs/README.md`、`docs/prd.md` 与项目实际状态严重脱节。

**改动**：

| 类型 | 数量 | 说明 |
|------|------|------|
| 字段定义清理 | 23 个 PRD | 删除 51 个 Dart/TS 代码块、406 行带类型字段表，统一替换为类型文件引用 |
| 重复 PRD 删除 | 1 个 | `serial-search-detail-prd.md`（与 `serial-query-detail-prd.md` 重复） |
| 文件归位 | 2 个 HTML | `category-select-prototype.html`、`service-select-prototype.html` 从 features/ 移到 prototypes/ |
| 总 PRD 标记废弃 | `docs/prd.md` | 路由已过时，被 features/*-detail-prd.md 替代 |
| README 重写 | `docs/README.md` | 反映真实目录结构（含 api/ phase/ status/ tasks/） |
| AGENTS.md 更新 | 1 个 | 类型文件清单从"18 个"修正为"17 个"（mall-order 待生成）；待开发模块从 2 个补全到 7 个 |

**新增 PRD 头部统一声明**：
> ⚠️ 类型唯一真实源：API 字段定义以 `lib/types/api/` 为准。本 PRD 不复制具体字段名/类型。

**已知遗留**：
- `mall-order-types.dart` 类型文件仍待从后端 TS 翻译生成，相关模块阻塞
- 部分 PRD「字段说明」表已替换为引用提示，但章节标题保留（不影响阅读）

---

## v1.18（2026-05-24）

### 新增：服务选择文档

| 文档 | 说明 |
|------|------|
| `service-select-prd.md` | 服务选择 PRD：分类、搜索、多选 |
| `service-select-prototype.html` | 服务选择原型图 |

**要点**：
- 服务使用进销存分类（`/category/list?type=7`）
- 接口：`/serve/list` + `/serve/count`
- 支持单选和多选模式

### 新增：SKU 选择规格流程

| 文档 | 说明 |
|------|------|
| `category-select-prd.md` | 新增第九章：SKU 选择规格流程 |

**要点**：
- selectableLevels 定义可选层级：cate/spu/sku/goods
- hasSerial=true 需进入 goods 列表选择具体商品
- SKU 包含精确价格和库存
- **修复**：SPU 列表接口参数 `mallCateId` → `mallCateIDs`

---

## v1.17（2026-05-24）

### 新增：3级分类选购文档

| 文档 | 说明 |
|------|------|
| `category-select-prd.md` | 产品需求文档：用户场景、交互流程、接口实现 |
| `category-select-prototype.html` | 原型图：展示3级分类（品类→品牌→系列）UI |

### 修复：库存接口路径
- `/sku/stock-by-spu` → `/spu/get-stock`（POST）

### 修正：分类体系
- 开单使用商城分类（`/mall-category/list`），不是进销存分类（`/category/list`）
- 商城分类层级固定3级：品类→品牌→系列

---

## v1.13（2026-05-20）

### 新增：开单选择商品/服务页面 PRD

文件：`docs/features/product-service-select-prd.md`

#### z1-pwa 组件清单整理

| 类别 | 组件数 | 说明 |
|------|--------|------|
| 核心选择组件 | 3 | SelectProduct、SelectService、SelectNonStandardGoods |
| 优惠相关组件 | 5 | SelectCoupons、SelectCashCoupons、SelectRenewSubsidy、SelectAutoGiveaways、CashCouponsList |
| 辅助选择组件 | 7 | SelectRecycleOrder、SelectSerialFromHistoryOrder、SelectPayments 等 |
| 信息展示组件 | 5 | ItemTypeTag、NonStandardGoodInfo 等 |
| 数量/价格修改组件 | 4 | ChangeQty、AmountInputModal 等 |
| 订单创建组件 | 1 | CreateOrder（1792行核心组件）|

#### 页面设计

- 商品 Tab：分类 → SPU → SKU → 加入购物车
- 服务 Tab：分类 → 服务列表 → 加入购物车
- 购物车：分类展示（商品/服务）+ 数量修改

---

## v1.12（2026-05-19）

### 重新设计商品选购页面

#### 新增功能
- **商品/服务 Tab 切换**：页面顶部新增"商品"和"服务"两个 Tab，支持切换
- **购物车分类展示**：购物车中商品和服务分开展示

#### 接口更新
- `/product/select-base` - 获取基础商品选择数据（商品+服务）
- `/product/select?ids=` - 批量查询商品
- `/product/list-by-code?codes=` - 按条码搜索商品

#### 字段更新
- `Product.genre` - 新增商品类型字段（`goods`/`service`）
- `CartItem.genre` - 购物车项新增 genre 字段

#### 测试反馈修正（v1.12 补充）

- ✅ `/product/select-base` - 可用
- ✅ `/product/select` - 可用
- ❌ `/product/list-by-code` - 已删除（测试不可用）
- ❌ `genre` 字段 - 已删除（后端不支持）

> 原则：测试后不可用的接口一律直接删除，不留「待后端实现」标注
- 新增 `product-list-new.html`（新版带商品/服务 Tab）

---

## v1.11（2026-05-19）

### 零售开单 PRD 更新（flutter开发反馈）

1. **路由路径修正**：所有 `/order/retail/...` 改为 `/home/retail/...`（涉及 5 个页面）
2. **查会员 API**：`/members/search-by-phones` → `/members/list-phones`
3. **会员卡字段**：补充完整（name/wxName、mobilePhone、levelName、experience、totalConsume）
4. **最近会员**：输入框下方显示最近搜索过的会员标签（最多 3 个）

> 同步更新：workbench-detail-prd.md、home-detail-prd.md、feature-list.md

### 接口路径验证（实测通过）

以下接口经代码验证路径正确：

| 功能 | 接口 | 方法 |
|------|------|------|
| 积分编辑 | `/members/experience` | POST |
| 会员等级列表 | `/member-level/list` | GET |
| 会员等级详情 | `/member-level/detail-or-all` | GET |
| 会员权益详情 | `/member-benefit/detail-or-all` | GET |
| 完成任务 | `/points-task-instance/complete` | POST |
| 销售列表 | `/order/shop-sale-list` | GET |
| 预售-支付 | `/pre-sale-order/pay` | POST |
| 预售-取消 | `/pre-sale-order/cancel` | POST |
| 退货审核 | `/return-refund-application/audit` | POST |
| 盘库新建 | `/stock-taking/add` | POST |

### 补充接口

- `GET /members/list-phones` - 按手机号搜索会员（支持逗号分隔多手机号）

### 商品选购接口（测试结果）

- ✅ `GET /product/select?ids=xxx` - 可用
- ✅ `GET /product/select-base` - 可用
- ❌ `GET /order/genre` - 不存在，已删除
- ❌ `GET /order/all-info` - 不存在，已删除
- ❌ `GET /order/product-can-sale-service` - 不存在，已删除
- ⚠️ `GET /product/list-by-code` - 参数名待确认
- ⚠️ `POST /order/add` - 参数结构待确认

> 已同步到 api-spec.md

---

## v1.9（2026-05-19）

### 测试 agent 实测结果更新（api-test-report-2026-0519.md）

#### 参数名称修正

| 接口 | 原参数 | 修正后 |
|------|--------|--------|
| GET /members/specified | `memberId` | `userIdents` |
| POST /members/add | `phone` | `user.mobilePhone` |
| POST /stock-taking/add | `warehouseId` | `warehouseID` |
| POST /members/experience | `memberId` | `member` |

#### 删除不存在的接口

- 会员：`/members/level/list`、`/members/benefit/list`、`/members/experience/edit`
- 订单：`/order/retail/entry`、`/order/shop-sale/add`
- 库存：盘库/调拨/采购详情及操作接口（路径待确认）
- 商品：`/product/detail/:id`、`/product/select-data`、`/product/barcode/:code`
- 任务：`/task/calendar`、`/task/add`、`/task/:id` 及相关操作接口
- 通用：`/warehouse/list`（改为 `/warehouse/list-base`）、`/payment/method/list`

#### 添加性能警告

- `/stock-taking/list`：响应时间约 6 秒

#### 新增已验证接口章节

- 文档新增「九、已验证可用接口」章节，列出实测通过的接口

---

## v1.8（2026-05-17）

### 新增文档

| 文件 | 说明 |
|------|------|
| `features/approval-center-detail-prd.md` | 审批中心模块详细 PRD，2 个页面（列表/详情） |
| `features/profile-detail-prd.md` | 我的页面详细 PRD，5 个页面（主页/账号设置/数据看板/消息通知/操作日志） |

### 接口验证

| 模块 | 接口 | 说明 |
|------|------|------|
| 审批中心 | `/approval/list`、`/approval/count` | 已验证 |
| 我的 | `/members/self` | 已验证 |

### 待确认

- 审批详情接口 `/approval/:id` 是否存在？
- 审批操作接口（通过/驳回）路径？
- 消息通知、操作日志接口是否存在？

---

## v1.7（2026-05-16）

### 测试验证 + 修正

| 文档 | 修正内容 |
|------|----------|
| home-detail-prd.md | 接口修正：`/user/self` → `/members/self`；`/dashboard/today-stat` 和 `/pending/items` 标注为待确认（接口不存在）；更新待确认事项列表 |

---

## v1.6（2026-05-16）

| 文件 | 说明 |
|------|------|
| `features/home-detail-prd.md` | 首页模块详细 PRD，1 个页面（含门店卡片/欢迎语/今日数据/功能菜单/最近订单/待处理事项） |

---

## v1.5（2026-05-16）

| 文档 | 修正内容 |
|------|----------|
| member-detail-prd.md | `/members/list-phones` 方法改为 GET；积分查询改用 `GET /members/self` 的 experience 字段；`POST /members/experience` 改为调整接口（删除 edit 后缀） |
| stocktaking-detail-prd.md | `/warehouse/list` → `/warehouse/list-base`；`/product/barcode/:code` → `/product-stock-by-code`；`/stock-taking/list` 加性能警告备注 |

---

## v1.4（2026-05-16）

| 文件 | 说明 |
|------|------|
| `features/member-detail-prd.md` | 会员中心模块详细 PRD，5 个页面（首页/详情/新增/积分查询/积分调整） |
| `features/stocktaking-detail-prd.md` | 盘库模块详细 PRD，3 个页面（列表/新建/详情）含扫码流程 |

---

## v1.3（2026-05-15）

| 修正 | 内容 |
|------|------|
| Bug | 订单创建 JSON `productInfos` → `items`，字段结构对齐 api-spec.md |
| 修正 | 积分接口 `GET /members/experience/:memberId` → `POST /members/experience`（需传会员ID） |
| 新增 | 优惠券选择页面（第六点），格式与其他页面一致 |
| 接口更新 | 4 个接口路径修正：search-by-phones、product/search、coupon-list、experience |
| 字段 | 金额字段注明单位为分（cent），非元 |

### 待确认

- `/order/shop-sale/add` 和 `/order/:orderNumber` 路径待测试最终确认

---

## v1.2（2026-05-15）

### 新增文档

| 文件 | 说明 |
|------|------|
| `features/retail-detail-prd.md` | 零售开单模块详细 PRD，覆盖 5 个页面的完整交互说明 |

---

## v1.1（2026-05-15）

| 文件 | 说明 |
|------|------|
| `design/api-spec.md` | 接口规范，按模块整理（认证/订单/库存/会员/任务/审批） |
| `design/data-model.md` | 数据模型，核心实体定义（User/Order/Member/Product/Inventory/Task） |

### 文档索引更新

- README.md 补充 `api-spec.md` 和 `data-model.md` 到归属表

---

## v1.0（2026-05-15）

### 初始文档结构

- 建立标准目录结构（design/features/status/prototypes）
- 整理文档归属，废弃冗余文件
- 新增 README.md 作为文档索引

### 文档迁移

| 文件 | 操作 |
|------|------|
| project-design.md | 移动到 design/ |
| feature-list.md | 移动到 features/ |
| phase1-implementation.md | 移动到 status/ 并重命名为 implementation.md |
| sales-list-prd.md | 废弃 |
| retail-prd.md | 废弃 |
| prototype/ | 移动到 docs/prototypes/prototype_backup/ |

---

*后续变更请在此文件追加记录。*