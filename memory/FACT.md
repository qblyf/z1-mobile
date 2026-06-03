# Facts

> 长期有效的项目知识（6 个月以上仍相关）。一次性事件请用 journal。

## z1-nextapp Flutter 项目

**位置**：`/Users/fan/www/AI/phone/Flutter/z1-nextapp/`，主代码在 `z1_mobile/`。

### 关键文件

- `AGENTS.md`：开发规范与流程，阶段三拆成 3.A 模型 / 3.B 接口空跑 / 3.C 落地
- `docs/guides/ai-doc-type-workflow.md`：开发流程指南详版（含真实接口空跑章节、5 个必答问题）
- `docs/features/*-prd.md`：业务 PRD，第五节"接口清单"可加 §5.1 "真实响应已知差异"段（含响应差异 + 请求参数差异）
- `docs/status/changelog.md`：版本变更记录

### 后端环境

- Base URL：`https://z1-fun.zsqk.com.cn/deno`（硬编码在 `lib/core/constants/api_constants.dart`，无 dev/prod 分离）
- 登录接口：`POST /members/phone-login`，body `{phone, pwd}`，响应 `{code:10000, res:{token}}`
- 鉴权：`ApiInterceptor` 自动注入 `Authorization: Bearer <token>`
- ⚠️ **curl 登录必须加 `-i`**，否则后端返回 schema 描述（`{ code: int, res: {...} }`）而不是真实 JSON
- HTTP 200 ≠ 业务成功，必须双重判定 HTTP 状态 + `data.code == 10000`
- 错误响应：HTTP 4xx + `{code: 9xxxx, message: "..."}`（实测 403 权限不足返回 code=90000）

### 后端请求参数惯例（不要凭直觉假设）

- **分页**：`offset + limit`（不是 `page + pageSize`）。某些接口仍接受 `page`，但 mall-order 等模块只认 `offset/limit`。
- **数组筛选**：`status=21,22,23` 逗号分隔字符串（不是 `status[]=...` 数组，也不是 JSON）
- **同模块姐妹接口的参数名风格不一定一致**：mall-order/list 用 `status` 单数收逗号串，mall-order/detail 用 `mallOrderNumbers` 复数收逗号串，mall-order/finish 和 unpaid-cancel 又改用 `mallOrderNumber` 单数。参数名风格必须 curl 一一验证，不能照姐妹接口推。
- **详情接口"业务码 10000 + 数据为空" = 资源不存在**（HTTP 200 不可信），datasource 层就要转 Failure，否则 BLoC 拿到 Loaded(null) 一路崩溃。
- **每个新接口都要 curl 验证 2~3 种参数格式**，参考 `docs/guides/ai-doc-type-workflow.md` §2.2 实战案例
- **破坏性接口（POST 改状态）特殊处理**：测试时空跑会污染数据，本项目采取的折中是 datasource + UI 完整实现，但接口空跑推到上线前由业务方提供可作废测试订单时人工验证；docstring 必须标注"未空跑"

### 两层类型模型（v1.27 起）

- 协议层 `lib/types/api/*.dart`：后端数据库实体的 Dart 镜像
- 展示层 `lib/features/*/data/models/*.dart`：API 响应视图 + UI 派生状态
- 展示层**不能**直接调协议层 `fromJson`（required 严约束会崩）；要自己读 Map + `??` 兜底
- 展示层字段类型可借协议层枚举（如 `OrderStatus`、`MallOrderStatus`）
- 枚举压缩必须在注释里声明完整映射表
- **写"协议层与响应不符"前必须 grep 协议层文件确认**，不能凭直觉断言（v1.32 教训：误判 `assistantIdent` 为 string，实际协议层已建模为 9 字段 class，被迫修正 4 处文档）

### 项目代码模式（写新模块前必参考 features/order/）

| 层 | 文件命名 | 模式 |
|----|---------|------|
| datasource | `xxx_remote_datasource.dart` | 抽象类 + Impl，构造注入 ApiClient,返回 `Future<Result<T>>` |
| BLoC | `xxx_bloc.dart` 单文件（event/state/bloc 合并） | flutter_bloc + Equatable，state 用抽象基类 + 多子类，分页 BLoC 自管 |
| page | `xxx_page.dart` | StatefulWidget，initState `new` Bloc，Cupertino 风格，CustomScrollView + CupertinoSliverRefreshControl |
| router | `lib/core/router/app_router.dart` | go_router 单文件，ShellRoute(MainScaffold) 包底 tab |
| DI | `lib/injection.dart` | 手写 GetIt（不用 injectable），datasource→registerLazySingleton，bloc→registerFactory |

Result 类型：`lib/core/api/result.dart`，sealed `Result<T>` = `Success<T>` | `Failure<T>`，含 `.map/.fold/.isFailure/.value/.failure`。

### 阶段三 · 3.B 接口空跑（v1.28-1.30 强制 checkpoint）

写 datasource / BLoC / 页面前，先用真实接口跑一次：

1. 用账号密码 + curl 拿 token（脚本见 ai-doc-type-workflow.md §2.2 准备工作）
2. **两轮空跑**：第一轮验响应结构和字段（写模型前），第二轮验请求参数名（写完 datasource 后联调前）
3. 3 类响应都跑：正常 / 空 / 错误
4. 把响应样本贴回模型文件注释
5. 回答 5 问：协议层 vs 响应字段差集 / required 收紧放宽 / 联合类型实际子类型 / 错误兜底位置 / 请求参数名是否生效
6. 与 PRD 有出入 → 回写 PRD §5.1 "已知差异"段（响应 + 请求参数两张表）

**凭证管理**：token / 账号密码绝不进文档、commit、journal，仅会话内传递。

### 测试凭证（仅本会话使用，不持久化到文档/commit）

业务方已提供测试账号，每次需要时让用户重新提供。

### 类型文件状态（2026-05-28）

`z1_mobile/lib/types/api/` 下 18 个文件全部 0 errors。基础类型在 `z1_mobile/lib/types/common.dart`,导出索引 `z1_mobile/lib/types/api.dart`。

### 已知技术问题

- 两套分类 ID：`spuCateID`（旧）vs `mallThirdCate`（新，用于商城分类）
- 周边依赖类型暂用 `dynamic`/typedef 兜底：net-sale / order-service / coupon / coupon-class / nonstandard / label

### 模块状态

- ✅ 已完成：登录/首页、零售开单、订单列表/详情、会员中心、盘库、调拨/采购占位、序列号、选择器
- ✅ 已完成 MVP：商城订单（列表 + 详情 + 完成/取消操作）
  - v1.28 模型层完成
  - v1.29 列表接口已空跑、流程文档化
  - v1.30 列表 datasource + BLoC + 页面 + router 完成
  - v1.31 详情 3.B 空跑（揪出请求参数 `mallOrderNumbers` 复数 + 5 种错误参数名）+ 3.C 落地（datasource/BLoC/page/router/utils 抽取）
  - v1.32 详情页操作入口：`finish` + `unpaid-cancel` datasource + `_ActionBar` UI + 二次确认；**破坏性接口未空跑**（标注在 docstring/PRD/changelog）
  - 已跳过：paid-cancel（需审核）/ outed-of-warehouse（测试无 post 数据）/ 退款 / 物流 / 门店关联——各自归独立模块
  - 待补：真机回归 `transport=post` 邮寄订单 + finish/unpaid-cancel 上线前用业务方可作废订单人工空跑参数名
- 🔵 待做：工作台 / 任务 / 我的、审批、预订单、退货退款、订单变更、小票打印

## 工作模式

**单人全栈**：开发、测试、产品三个角色都由我自己承担。**不需要向任何外部 session 汇报**——以前 FACT 里写的"项目经理 / 测试 / 文档助手 session ID"和"mavis communication send 汇报"是错误预设，已删除。

完成一轮迭代时，自己决策下一步即可：
- 写代码 = 开发视角
- 真机/curl 验证 = 测试视角
- PRD / changelog / 用户体验取舍 = 产品视角

需要外部输入时（业务规则、测试账号、设计偏好），向用户确认。
