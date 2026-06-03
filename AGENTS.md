# Z1-NextApp 开发规范

> **最后更新**：2026-05-29（阶段三细分为 3.A 模型 / 3.B 接口空跑 / 3.C 落地三步）

---

## 核心规则

### ⚠️ 两层类型模型（v1.27 起正式确立）

项目使用**协议层 + 展示层**两层类型模型，各司其职：

| 层级 | 路径 | 角色 | 翻译来源 |
|------|------|------|---------|
| **协议层** | `lib/types/api/` | 后端数据库实体的 Dart 镜像，作为字段类型/枚举取值的**契约基准** | `z1-mid/src/types/`（后端 TypeScript 数据库实体） |
| **展示层** | `lib/features/*/data/models/` | 实际 API 响应视图 + UI 派生状态（`fromJson` / `copyWith` / getter） | 后端 API 实际响应结构 + UI 需求 |

**为什么两层并存（不是"协议层是唯一真实源"）：**
- 后端 TS 类型描述的是**数据库实体**，不是 API 响应 schema。响应通常多出 join 字段（`productName`、`customerName`）、聚合字段（`subtotal`）、压缩状态。
- 仅依赖协议层 → 字段缺失、状态值不匹配。
- 仅依赖展示层 → 失去与后端契约对齐的检查能力。

**两层之间的允许操作：**

| 操作 | 是否允许 | 说明 |
|------|---------|------|
| 展示层字段类型引用协议层枚举 | ✅ | 例如 `OrderStatus`，统一从协议层导入 |
| 展示层扩展协议层没有的字段 | ✅ | 例如 join 出的 `productName`、`customerName` |
| 展示层枚举值数量少于协议层 | ✅ | 例如把后端 5 个 status 值压缩为 UI 的 3 个状态 |
| 在注释中声明枚举压缩映射表 | ✅ 必须 | 否则下次维护无法定位 |
| 悄无声息地把后端字段名重命名 | ❌ | 若需更友好的名称，旧名保留为主字段，新名作为 getter |
| 展示层字段类型与协议层冲突且无注释 | ❌ | 必须显式声明差异原因 |

**重复定义的处理：**
- 同一类型在多个 features 模块中重复定义（如 `OrderStatus`）：由首次定义的模块导出，其他模块用 `import + export` 复用，禁止再写一份相同 enum。
- 协议层 (`types/api`) 内部禁止跨文件重复定义同一类型。

**Flutter Agent 必须遵守：**
- 开发新模块：先读协议层契约 → 再看相邻 features 模型示例 → 最后写展示层模型。
- 修改字段类型：协议层与展示层都要改。
- features 枚举与协议层有差异：必须在 enum 注释中声明取值映射。

| 文档类型 | 作用 |
|---------|------|
| `lib/types/api/*.dart` | 协议层契约，字段类型 / 枚举值的取值范围以此为准 |
| `lib/features/*/data/models/*.dart` | 展示层模型，描述 API 响应的实际结构和 UI 派生状态 |
| `docs/features/*prd.md` | 描述业务需求，不写具体参数名 |
| `docs/guides/ai-doc-type-workflow.md` | 开发流程规范 |

**Flutter Agent 必须阅读**：
- `docs/guides/ai-doc-type-workflow.md` - 开发流程规范
- `docs/guides/flutter-agent-type-guide.md` - 类型使用指南

---

## 开发流程（2026-05-29 更新）

```
阶段一：需求定义
  1. 业务方提需求 → 文档助手
  2. 文档助手编写 PRD：
     - 用户故事、交互流程
     - 标注「接口：XXX，类型见 lib/types/api/xxx-types.dart」
     - 不写具体参数名（避免过时）

阶段二：协议层类型同步（AI 翻译）
  3. AI 从 SDK 翻译类型到 Dart 协议层：
     - 读取：/Users/fan/www/AI/z1/z1-mid/src/types/
     - 写入：z1_mobile/lib/types/api/
     - 每个文件 flutter analyze 通过才算完成
     - 不使用脚本自动转换（会失败）
     - ⚠️ 协议层 = 后端实体镜像；不是 API 响应 schema
  4. 类型文件验证通过后，更新 api.dart 导出

阶段三：Flutter 开发（按推荐子阶段顺序，避免边写边返工）

  ### 3.A 协议层 → 展示层模型（先做这一步，先别写页面）
  5. Flutter Agent 收到 context：
     - PRD 文档（描述用户需求）
     - lib/types/api/*.dart（协议层契约）
     - 开发流程规范文档
  6. 写展示层模型（features/data/models）：
     - 先读协议层类型，确认字段类型 / 枚举取值
     - 展示层 model 直接读 Map（不调协议层 `fromJson`，避免 required 严约束在响应不完整时崩溃）
     - 扩展 join / 聚合字段
     - 枚举若压缩，注释中声明完整映射表（参考 `OrderStatus` / `MallOrderDisplayStatus`）
     - 联合类型容错：协议层 `XxxInfo.fromJson` 对未知子类型抛 ArgumentError，
       展示层要改成 `unknown` 分支兜底，后端新增子类型不崩溃
     - 参数类型尽量从协议层 import（确保字段类型契约对齐）

  ### 3.B 真实接口空跑（在写 datasource / 页面之前）
  7. ⚠️ **关键步骤**：用 `apiClient.get('/xxx-endpoint')` 真实跑一次接口，把响应 JSON 贴回
     与展示层模型对齐。这一步比"先写 datasource 再调试"成本低一个数量级：
     - 协议层定义的是数据库实体，响应通常多 join 字段（`xxxName`）、聚合字段、压缩状态
     - 真实响应跑过 → 知道哪些字段实际存在、哪些 `?? 0` 兜底是必需、哪些可以收紧 required
     - 跑空响应分支 / 错误响应分支，确认 datasource 容错符合预期
  8. 根据响应调整展示层模型（追加 join 字段 getter、收紧/放宽 required）

  ### 3.C Datasource → BLoC → Page → Router & DI
  9. 写 datasource：apiClient.get + 展示层模型 fromJson，返回 `Result<T>` 或 `Result<List<T>>`
  10. 写 BLoC：事件 / 状态 / handler，把 datasource 结果转成 UI 状态
  11. 写 Page + Widget：消费 BLoC 状态，做 UI
  12. 接入 router（`app_router.dart`）+ DI（`injection.dart`）
  13. 自测：flutter analyze + 手动点击跑通主流程

阶段四：测试验证
  14. 测试 Agent：
     - 冒烟测试（接口可达）
     - 类型映射验证（响应字段匹配类型定义）
     - 不测「参数名对不对」（类型已经保证了）
  15. 结果：
     - 通过 → 合并 MR
     - 失败 → 打回 Flutter Agent
```

---

## 文档先行（必须遵守）

**所有功能开发必须先有 PRD 才能开工。**

流程：
1. 收到开发需求 → 检查是否有对应 PRD
2. 没有 PRD → 派给文档助手补全
3. 有 PRD 且类型文件已验证 → 才能派给开发 agent

---

## 汇报规则（必须遵守）

**每次开发完成后，必须通过 `mavis communication send` 告知项目经理。**

> ⚠️ session ID 会随 agent rotation 变化，**不要写死**。以 `mavis communication peers` 实时输出为准。

**查询当前可用 session**：
```bash
mavis communication peers | jq '.sessions[] | select(.status == "finished" or .status == "started") | {title, sessionId, agentName}'
```

通常每个角色只有一个 "main" session（status=finished/idle 是可路由状态）。

**汇报给项目经理**：
```bash
mavis communication send \
  --to <项目经理 sessionId> \
  --command prompt \
  --content "..."
```

> 项目经理本身的 session ID 也可能变化，PM 启动新 session 时会主动告知当前 ID，或通过 `mavis communication peers` 查询 `agentName=agent-ca844031e7db` 的 status=started session。

---

## 分工规则

| 工作类型 | 执行人 | Agent Name | Session 查询 |
|---------|-------|-----------|-------------|
| 代码改动 | flutter开发 | `agent-2e1123841946` | `mavis communication peers` 取 title="main" |
| 测试执行 | flutter测试 | `agent-c29355ba65db` | `mavis communication peers` 取 title="main" |
| 文档编写 | 文档助手 | `agent-b16e31f79989` | `mavis communication peers` 取 title="main" |
| 调度协调 | 项目经理 | `agent-ca844031e7db` | `mavis communication peers` 取 title="main" |

> **历史 session ID 仅供参考**（已 aborted/finished 的不能接收消息）：
> - flutter开发（aborted 2026-06-03 前）：mvs_3a6e069df73f4e72bdda851544213e13
> - flutter测试（aborted 2026-06-03 前）：mvs_c8927294e7aa49478ebaa425f4ae34e1
> - 文档助手（aborted 2026-06-03 前）：mvs_d07499453c1844b99e6cff61536246b9

---

## 文档位置

| 类型 | 位置 |
|------|------|
| PRD 文档 | `docs/features/` |
| **开发流程规范** | `docs/guides/ai-doc-type-workflow.md` |
| **类型使用指南** | `docs/guides/flutter-agent-type-guide.md` |
| **协议层类型契约** | `z1_mobile/lib/types/api/` |
| **展示层数据模型** | `z1_mobile/lib/features/*/data/models/` |

---

## 已知技术问题

### 两套分类 ID 系统

| 字段 | 来源 | 用途 |
|------|------|------|
| `spuCateID` | 旧分类 | 旧系统，**不要用这个匹配商城分类** |
| `mallThirdCate` | 商城分类 | 新系统，**用于匹配商城分类** |

### 类型文件状态（2026-05-28 更新）

**✅ 全部已验证可用（18 个文件，0 errors）**

实际位置：`z1_mobile/lib/types/api/`

| 文件 | 说明 |
|------|------|
| `auth-types.dart` | 认证相关 |
| `approval-types.dart` | 审批 |
| `category-types.dart` | 旧分类（spuCateID 系统） |
| `mall-category-types.dart` | 商城分类（mallThirdCate 系统） |
| `mall-order-types.dart` | 商城订单（含 MallOrder/MallOrderStatus/MallOrderDiscountInfo 等） |
| `dashboard-types.dart` | 仪表盘 |
| `member-types.dart` | 会员 |
| `order-types.dart` | 订单（核心，含 ShopSale/OrderProduct 等） |
| `product-types.dart` | 商品 |
| `purchase-types.dart` | 采购 |
| `serial-types.dart` | 序列号 |
| `service-types.dart` | 服务项 |
| `sku-types.dart` | SKU |
| `spu-types.dart` | SPU |
| `stock-types.dart` | 库存 |
| `stocktaking-types.dart` | 盘库 |
| `task-types.dart` | 任务 |
| `transfer-types.dart` | 调拨 |

> ⚠️ 基础类型在 `z1_mobile/lib/types/common.dart`（不在 api/ 子目录），导出索引在 `z1_mobile/lib/types/api.dart`。
> ⚠️ 周边依赖类型尚未生成：`net-sale-types.dart`、`order-service-types.dart`、`coupon-types.dart`、`coupon-class-types.dart`、`nonstandard-types.dart`、`label-types.dart`。`mall-order-types.dart` 中相关字段暂用 `dynamic` 或 typedef 兜底，需要强类型时再补全。

---

## 页面状态

### 已完成模块

- ✅ 登录/首页
- ✅ 零售开单（6 页 + 优惠券）
- ✅ 订单列表/详情
- ✅ 会员中心（5 页）
- ✅ 盘库（3 页）
- ✅ 调拨（3 页，占位符）
- ✅ 采购（3 页，占位符）
- ✅ 序列号查询
- ✅ 商品/服务选择器
- ✅ 分类选择器

### 待开发模块

- 🔵 工作台 / 任务 / 我的（部分完成）
- 🔵 审批中心
- 🔵 商城订单（类型已就绪，待 UI 开发）
- 🔵 预订单
- 🔵 退货退款
- 🔵 订单变更
- 🔵 小票打印
