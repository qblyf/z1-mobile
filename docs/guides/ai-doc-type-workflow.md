# AI 文档与接口开发流程

> 基于 2026-05-27 类型系统重建经验 + 2026-05-29 两层模型与接口空跑实践总结

---

## 一、核心原则

### 1.1 两层类型模型（v1.27 起正式确立）

```
协议层 (lib/types/api/*.dart)              = 后端数据库实体的 Dart 镜像
展示层 (lib/features/*/data/models/*.dart) = API 响应视图 + UI 派生状态
PRD   (docs/features/*.md)                 = 业务需求描述
```

**为什么不能"协议层即唯一真实源"**：
- 协议层翻译自后端 TypeScript 数据库实体，描述的是**表结构**。
- API 响应通常是**实体的视图**：多出 join 字段（`productName`、`customerName`）、
  聚合字段（`subtotal`），状态枚举也可能被压缩。
- 仅依赖协议层 → 响应缺失/多余字段时 `required` cast 崩溃。
- 仅依赖展示层 → 失去与后端契约对齐的检查能力，字段类型可能漂移。

**两层之间的关系**：

| 操作 | 是否允许 | 说明 |
|------|---------|------|
| 展示层字段类型引用协议层枚举 | ✅ | 例如 `OrderStatus`、`MallOrderStatus` |
| 展示层扩展 join / 聚合字段 | ✅ | 例如 `productName`、`customerName`、`subtotal` |
| 展示层枚举值数量少于协议层 | ✅ | 例如 12 → 6 tab，必须在注释中声明完整映射表 |
| 展示层直接调协议层 `fromJson` | ❌ | 协议层 required 严格，响应不全会崩 |
| 展示层悄无声息地重命名后端字段 | ❌ | 必须保留旧字段名作为主字段，新名做 getter |

### 1.2 类型驱动 + 真实响应驱动

```
PRD 文档          →  描述"做什么"
协议层类型        →  描述"字段类型契约"
真实接口响应      →  描述"实际有哪些字段、哪些可能缺失"
展示层模型        →  描述"UI 怎么消费"
Flutter 代码      →  描述"怎么做"
```

**关键洞察**：写 datasource / 页面之前先用真实接口跑一次响应，比"写完再调试"
成本低一个数量级。响应一旦贴回，展示层模型该收紧的 required、该兜底的 `?? 0`、
该补的 join 字段 getter 全都自动浮现。

---

## 二、流程设计

### 2.1 总体流程

```
┌─────────────────────────────────────────────────────────────┐
│ 阶段一：需求定义                                            │
├─────────────────────────────────────────────────────────────┤
│ 1. 业务方提需求                                            │
│ 2. AI 编写 PRD：                                           │
│    - 用户故事、交互流程                                     │
│    - 标注「调用 XX 接口，参数见 lib/types/api/XXX」          │
│    - 不写具体参数名（避免过时）                            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 阶段二：类型同步（AI 翻译）                                │
├─────────────────────────────────────────────────────────────┤
│ 3. AI 从 z1-mid SDK 翻译类型到 Dart：                      │
│    - 读取 SDK: /Users/fan/www/AI/z1/z1-mid/src/types/   │
│    - 写入: z1_mobile/lib/types/api/                      │
│    - 每个文件 flutter analyze 通过才算完成                  │
│    - 不使用脚本自动转换（会失败）                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 阶段三：Flutter 开发（拆成 3.A / 3.B / 3.C，避免边写边返工）│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 3.A 协议层 → 展示层模型（先做这一步，先别写页面）           │
│ ────────────────────────────────────────────────────────── │
│ 4. Flutter Agent 收 context（PRD + 协议层契约 + 本流程文档）│
│ 5. 写展示层模型 features/data/models/*.dart：               │
│    - 读协议层确认字段类型 / 枚举取值                        │
│    - 直接读 Map（不调协议层 fromJson，避免 required 崩溃）  │
│    - 扩展 join / 聚合字段                                   │
│    - 枚举压缩 → 在注释里写完整映射表                        │
│    - 联合类型 → 用 unknown 分支兜底，后端新增子类型不崩     │
│                                                             │
│ 3.B 真实接口空跑（⚠️ 关键步骤，写 datasource / 页面之前）   │
│ ────────────────────────────────────────────────────────── │
│ 6. apiClient.get('/xxx-endpoint') 真实跑一次，贴回响应 JSON │
│    - 协议层是数据库实体，响应通常多 join / 聚合 / 压缩状态  │
│    - 跑过真实响应才知道：                                   │
│      · 哪些字段实际存在                                     │
│      · 哪些 ?? 0 / ?? '' 兜底是必需                         │
│      · 哪些 required 可以收紧                               │
│      · 空响应 / 错误响应分支 datasource 是否容错            │
│ 7. 根据真实响应调整展示层模型                               │
│                                                             │
│ 3.C Datasource → BLoC → Page → Router & DI                  │
│ ────────────────────────────────────────────────────────── │
│ 8.  datasource：apiClient.get + 展示层 fromJson → Result<T> │
│ 9.  BLoC：事件 / 状态 / handler                             │
│ 10. Page + Widget：消费 BLoC 状态                           │
│ 11. 接入 router (app_router.dart) + DI (injection.dart)     │
│ 12. flutter analyze + 手动点击跑通主流程                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 阶段四：测试验证                                            │
├─────────────────────────────────────────────────────────────┤
│ 13. 测试 Agent：                                            │
│    - 冒烟测试（接口可达）                                  │
│    - 类型映射验证（响应字段匹配类型定义）                   │
│    - 不测「参数名对不对」（类型已保证）                    │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 阶段三 · 接口空跑的标准操作（v1.28 新增）

> ⚠️ 这是阶段三里最容易被跳过、但收益最大的一步。把它当成强制 checkpoint。

#### 何时空跑

- 模型层（3.A）已经写完、`flutter analyze` 通过
- 还没开始写 datasource / BLoC / 页面
- 协议层与展示层之间存在已知差异（join 字段、聚合字段、压缩状态等）

#### 准备工作：用账号密码拿 token

> 2026-05-29 实测可用，环境 `https://z1-fun.zsqk.com.cn/deno`。

所有业务接口都走 `ApiInterceptor` 注入 `Authorization: Bearer <token>` 头，
所以空跑前要先用账号密码换出 token。**推荐用 curl 直连后端**，不依赖 Flutter
运行时，速度最快。

**1. 登录拿 token**

```bash
BASE=https://z1-fun.zsqk.com.cn/deno

# ⚠️ 必须加 -i（输出含响应头），否则后端会返回 schema 描述而不是真实 JSON
curl -sS -i -X POST "$BASE/members/phone-login" \
  -H 'Content-Type: application/json' \
  -d '{"phone":"<手机号>","pwd":"<密码>"}'
```

响应结构（`code: 10000` 表示成功）：

```json
{ "code": 10000, "res": { "token": "eyJhbGciOiJIUzI1Ni..." } }
```

**2. 一键脚本（登录 + 调业务接口）**

```bash
BASE=https://z1-fun.zsqk.com.cn/deno
PHONE='<手机号>'
PWD='<密码>'

# 登录 → 提取 token（res.token）。注意 -i 是必须的
LOGIN=$(curl -sS -i -X POST "$BASE/members/phone-login" \
  -H 'Content-Type: application/json' \
  -d "{\"phone\":\"$PHONE\",\"pwd\":\"$PWD\"}")
BODY=$(echo "$LOGIN" | awk 'BEGIN{p=0}/^\r?$/{p=1;next}p')
TOKEN=$(echo "$BODY" | python3 -c 'import sys,json;print(json.load(sys.stdin)["res"]["token"])')

# 调业务接口
curl -sS "$BASE/mall-order/list?page=1&pageSize=5" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

**3. 已知坑**

| 坑 | 现象 | 处理 |
|---|------|------|
| 漏 `-i` | 登录返回 schema 描述（`{ code: int, res: {...} }`）而不是真值 | 必须加 `-i` |
| 密码含 `$`、`!` 等 shell 特殊字符 | Bash 展开变量 | 用单引号包裹整个 JSON，或对密码做 shell 转义 |
| token 过期 | 业务接口返回 401 / `code != 10000` | 重新跑登录拿新 token |
| 后端响应 `code` 字段 ≠ HTTP 状态码 | HTTP 200 但 `code: 40000` 是业务错误 | datasource 必须双重判定：先看 HTTP，再看 `data.code` |

**4. 凭证管理**

- 测试凭证**禁止**写进文档、commit、journal。仅在会话内传递。
- 如果跑空跑 probe 需要 token，token 也只放在 shell 临时变量里，不落盘。
- PR 描述里可以写"已在 z1-fun 环境登录跑过"，但不要贴 token / 账号。

#### 如何空跑（在 Flutter 内）

如果需要在 Flutter 运行时调（例如为了走 `ApiInterceptor` 完整链路），
可以在已有页面 initState、临时 main、或 BLoC 调试入口里跑：

```dart
import 'package:z1_mobile/core/api/api_client.dart';
import 'package:z1_mobile/features/mall_order/data/models/mall_order_model.dart';

Future<void> probeMallOrderList() async {
  final apiClient = sl<ApiClient>(); // 或 GetIt.I<ApiClient>()
  final raw = await apiClient.get(
    '/mall-order/list',
    queryParameters: {'page': 1, 'pageSize': 5},
  );
  // 1) 打印原始响应，确认字段集合
  debugPrint('raw: ${raw.data}');
  // 2) 尝试用展示层模型解析，验证容错
  final list = (raw.data['list'] as List)
      .map((e) => MallOrderModel.fromJson(e as Map<String, dynamic>))
      .toList();
  debugPrint('parsed: ${list.length} items, first=${list.first}');
}
```

**2. 三类响应都要跑一遍**：

| 分支 | 触发方式 | 关注点 |
|------|---------|--------|
| 正常响应 | 用真实参数请求 | 字段是否齐全、类型是否对得上、`?? 兜底` 是否被吃到 |
| 空响应 | 用极端参数（如不存在的会员 ID）| `list: []`、`total: 0` 时模型是否崩溃 |
| 错误响应 | 故意传错 token / 必填字段 | `Result.failure` 是否被 datasource 正确捕获 |

**3. 把响应样本贴回到模型文件的文档注释里**：

```dart
/// 真实响应样本（2026-05-29 抓的，环境：z1-fun.zsqk.com.cn/deno）
/// ```json
/// {
///   "number": "SC202605170001",
///   "status": 22,
///   "customerIdent": 1024,
///   "customerName": "李四",        // ← join 出来的，协议层没有
///   "info": [{"skuID": 88, "skuName": "足金手镯", "qty": 1, ...}],
///   ...
/// }
/// ```
class MallOrderModel { ... }
```

#### 空跑要回答的 5 个问题

完成空跑前，模型文件里的注释或 commit message 必须能回答：

1. **协议层 vs 真实响应的字段差集**：响应里有但协议层没有的字段（join / 聚合）；
   协议层有但响应里缺失的字段（需要 `?? 兜底`）。
2. **`required` 收紧 / 放宽决策**：哪些字段在真实响应里 100% 出现，可以保留
   `required`；哪些可能缺失，需要默认值兜底。
3. **联合类型实际出现哪些子类型**：响应里出现的 kind，未在协议层枚举里的归入
   `unknown` 分支。
4. **datasource 错误分支兜底位置**：401 / 500 / 业务错误码（`raw.data['code']`）
   分别在哪一层被转成 `Result.failure`。
5. **请求参数名是否真的生效**（v1.29 新增）：分页参数是 `page+pageSize` 还是
   `offset+limit`？数组筛选是 `key[]=...` 还是 `key=a,b,c` 还是 JSON 字符串？
   ⚠️ **绝不能凭"看起来合理"假设**。最快验法：用 curl 试 2~3 种格式，
   通过返回的 count 和元素内容验证哪种真正生效。

#### 空跑产出物

阶段 3.B 完成后，提交时应包含：

- 模型文件里的"真实响应样本"注释
- 在 changelog / journal 里记录"已空跑哪几个接口、哪些字段被调整"
- 如果发现 PRD 与真实响应有出入，回写 PRD 第五节"接口清单"或"已知差异"段

#### 实战案例：`/mall-order/list` 空跑（2026-05-29，分两轮）

**第一轮空跑（写 datasource 前）发现的响应层问题**：

| 发现 | 修正前 | 修正后 |
|------|--------|--------|
| 顶层包装是 `{code, res: [...]}` 不是 `{list, total}` | datasource 取 `data.list` | 取 `data.res` |
| `customerIdent` 实际是 **string**（`"235787983"`），不是 int | 模型字段 `final int customerIdent` + `?? 0` | 改成 `final String customerIdent` + `toString() ?? ''` |
| 响应**没有** join `customerName` 和 `skuName` | 默认依赖 join 字段展示 | BLoC 异步补查会员；摘要走 `'商品 x{qty}'` fallback |
| 100% 订单 `transport == "store"`、`postInfo == null`、`postAmount == null` | 模型默认 `transport: post` | 默认改成 `store`，相关字段确认 `?` 可空 |

**第二轮空跑（写 datasource 后、写联调前）发现的请求参数问题**：

| 我以为的 | 真实情况 | 修正 |
|---------|---------|------|
| `pageSize=20` 控制每页大小 | ❌ **被忽略**，永远返回 100 条上限 | 改用 `limit` |
| `page=1,2,3...` 翻页 | ❌ **被忽略**（page=1/2/999 同样结果） | 改用 `offset = (page-1)*pageSize` |
| `status[]=21&status[]=22` 数组 | ❌ 被 dio 序列化，但后端不识别，等同于不筛选 | 改用 `status=21,22,23` 逗号串 |
| `status=[21,22,23]` JSON 字符串 | ❌ 返回空列表 | 同上 |
| `status=21&status=22` 重复 key | ❌ 只取第一个 | 同上 |

**真正生效的格式**：`?offset={n}&limit={n}&status=21,22,23`

抽样状态分布（100 条）：`status=7` 约 55 条、`status=31` 约 44 条、`status=42` 1 条
—— 6 tab 压缩映射验证可用，但生产环境数据可能极度倾斜某 2~3 个状态，UI 设计时
要考虑空 tab 的体验。

**结论**：

1. 响应层空跑（模型设计前）+ 请求层空跑（写 datasource 后）**是两件事**，
   都要做。第一轮验证响应结构和字段差异；第二轮逐个参数试错以确认后端真实
   接受的 key 和格式。
2. 不要凭"看起来合理"假设参数名 —— `page/pageSize` 是行业惯例，但本项目用
   `offset/limit`；数组用 `[]` 后缀是 PHP 惯例，本项目用逗号串。**所有参数
   名都要至少试 2~3 种格式确认**。
3. 整条 mall_order 列表（datasource + BLoC + page + router）从开始到联调通过
   总耗时约 30 分钟，**其中"空跑发现参数 bug"的 5 分钟，避免了至少 1 小时
   的"为什么列表不刷新/筛选不生效"调试**。

---

## 三、PRD 编写规范

### 3.1 文档结构

```markdown
# [功能名] · PRD

> **模块**：XXX
> **版本**：v1.0
> **日期**：YYYY-MM-DD
> **依据**：业务需求

---

## 一、页面路径

```
/xxx/home              → 功能首页
        └── /xxx/:id   → 详情页
```

---

## 二、用户故事

### 用户 A（角色）
**作为** [角色]
**我想要** [功能]
**以便** [价值]

---

## 三、接口设计

### 3.1 接口清单

| 页面区块 | 接口 | 类型文件 | 说明 |
|---------|------|---------|------|
| 列表 | GET /xxx/list | `lib/types/api/xxx-types.dart` | 获取列表 |
| 详情 | GET /xxx/:id | `lib/types/api/xxx-types.dart` | 获取详情 |

### 3.2 关键类型

**请求参数**：见 `lib/types/api/xxx-types.dart` 的 `XxxParams`

**响应数据**：见 `lib/types/api/xxx-types.dart` 的 `XxxData`

### 3.3 业务规则

- 金额单位：分（类型中 RMBFen 已标注）
- 时间格式：Unix 时间戳
- 状态枚举：见类型文件中对应的 enum

---

## 四、异常处理

| 场景 | 处理 |
|------|------|
| 接口超时 | 显示错误提示，可重试 |
| 数据为空 | 显示空状态 |
| 权限不足 | 跳转登录 |

---

## 五、跳转关系

| 来源 | 触发 | 目标 |
|------|------|------|
| 首页 | 点击 | /xxx/list |
| 列表 | 点击 item | /xxx/:id |
```

### 3.2 文档示例

```markdown
## 三、接口设计

### 3.1 会员列表

| 页面区块 | 接口 | 类型文件 |
|---------|------|---------|
| 会员列表 | GET /members/list | `lib/types/api/member-types.dart` |

**关键类型**：
- 请求：`MemberListParams`（分页、筛选参数）
- 响应：`Member`（包含 userIdent, mobilePhone, realName 等）

**注意**：
- 手机号字段：`mobilePhone`
- 会员 ID：`userIdent`（不是 `memberId`）
```

---

## 四、类型文件编写规范

### 4.1 文件位置

```
z1_mobile/lib/types/
├── common.dart              # 基础类型（唯一真实源）
└── api/
    ├── member-types.dart    # 会员类型
    ├── order-types.dart    # 订单类型
    └── ...
```

### 4.2 类型文件结构

```dart
// ============================================================
// [模块名] 类型
// 从 z1-mid SDK [原文件].ts 翻译而来
// ============================================================

// 基础类型已在 common.dart 定义
export 'package:z1_mobile/types/common.dart';

// ============================================================
// 枚举类型
// ============================================================

enum XxxStatus {
  pending(1),    // 待处理
  approved(2),   // 已通过
  rejected(3);  // 已拒绝

  final int value;
  const XxxStatus(this.value);

  static XxxStatus fromValue(int value) {
    return XxxStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => XxxStatus.pending,
    );
  }
}

// ============================================================
// 数据模型
// ============================================================

class XxxData {
  final int id;
  final String name;
  final RMBFen amount;  // 金额单位：分
  final List<String> tags;

  XxxData({
    required this.id,
    required this.name,
    required this.amount,
    this.tags = const [],
  });

  factory XxxData.fromJson(Map<String, dynamic> json) {
    return XxxData(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: json['amount'] as RMBFen,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
```

### 4.3 注意事项

| 问题 | 解决方案 |
|------|---------|
| 联合类型 (`A \| B`) | 拆成两个类，用 `dynamic` 或泛型 |
| 条件类型 | 根据实际 API 响应决定类型 |
| 缺失类型 | 先在 common.dart 添加 typedef |
| 重复定义 | 删除 common.dart 中的重复枚举 |

### 4.4 验证流程

```bash
# 每个类型文件必须通过分析
flutter analyze lib/types/api/xxx-types.dart

# 0 errors 才能导出
# warnings (文件名规范) 可忽略
```

---

## 五、Flutter 开发规范

### 5.1 协议层 import（仅用于类型 / 枚举对齐）

```dart
// 协议层枚举：直接 import 用于字段类型对齐
import 'package:z1_mobile/types/api/mall-order-types.dart' show MallOrderStatus;

// ⚠️ 不要 import 协议层 class 然后直接调 fromJson 解析响应
// 协议层 required 严格，响应不全会崩。展示层应当自己读 Map。
```

### 5.2 展示层模型（features/data/models/*.dart）

```dart
class MallOrderModel extends Equatable {
  final String number;
  final MallOrderStatus status;       // ← 字段类型借协议层枚举
  final String customerName;          // ← 协议层没有的 join 字段
  final int orderAmount;              // 单位：分（RMBFen）

  /// 容错解析：直接从 Map 取，缺失字段兜底
  factory MallOrderModel.fromJson(Map<String, dynamic> json) {
    return MallOrderModel(
      number: json['number'] as String? ?? '',
      status: MallOrderStatus.fromValue((json['status'] as int?) ?? 1),
      customerName: json['customerName'] as String? ?? '',
      orderAmount: (json['orderAmount'] as int?) ?? 0,
    );
  }

  double get orderAmountYuan => orderAmount / 100;
}
```

**核心模式**：
- 字段类型用 `T?` + `?? 兜底值`，避免协议层 `required` cast 崩溃
- 枚举借协议层 `fromValue` 拿默认值兜底
- 金额单位保持分，元在 getter 里转换

### 5.3 联合类型容错分支

```dart
enum MallOrderLineItemKind { product, service, nonStandard, unknown }

factory MallOrderLineItem.fromJson(Map<String, dynamic> json) {
  if (json.containsKey('skuID')) {
    return MallOrderLineItem(kind: MallOrderLineItemKind.product, ...);
  }
  // ... service / nonStandard
  // 后端将来若新增子类型，落到 unknown 分支而不是抛 ArgumentError
  return MallOrderLineItem(kind: MallOrderLineItemKind.unknown, ...);
}
```

### 5.4 枚举压缩必须声明映射表

```dart
/// 展示层订单状态分组（PRD 6 tab 模型）
///
/// 协议层 12 个 MallOrderStatus 值在 UI 上压缩成 6 个 tab：
///
/// | 展示层 tab | 协议层 status (int)  | 含义 |
/// |-----------|----------------------|------|
/// | pendingPay| 1                    | 待支付 |
/// | paid      | 21 / 22 / 23         | 部分支付 / 已支付 / 已支付未完成 |
/// | shipped   | 6 / 61               | 已出库 / 已送达 |
/// | completed | 7 / 8                | 已完成 / 已评价 |
/// | refunded  | 31 / 32 / 41 / 42    | 各种退款 / 撤销 |
enum MallOrderDisplayStatus { ... }
```

### 5.5 金额处理

```dart
// 协议层字段单位已是 RMBFen (分)，展示层在 getter 里转元
double get amountYuan => amount / 100;
Text('¥${order.amountYuan.toStringAsFixed(2)}')
```

---

## 六、测试验证

### 6.1 测试内容

| 测试项 | 说明 |
|--------|------|
| 接口可达 | 发送请求，确认返回 200 |
| 类型映射 | 响应字段能正确解析为类型 |
| 字段完整性 | 必填字段有值，可选字段可空 |

### 6.2 测试不测

| 不测 | 原因 |
|------|------|
| 参数名对不对 | 类型已保证 |
| 字段名拼写 | 类型已保证 |
| 字段顺序 | JSON 解析不依赖顺序 |

---

## 七、示例：完整流程（以 mall_order 列表为例）

### Step 1: 业务提需求

> 我需要一个商城订单列表页面，能按状态筛选（6 个 tab）和按会员搜索

### Step 2: AI 写 PRD

`docs/features/mall-order-prd.md`，标注接口和类型文件位置，
**不写具体字段名**（参考已有的 mall-order-prd.md）。

### Step 3: AI 补充协议层类型（如果缺失）

```bash
# 检查类型是否存在
ls lib/types/api/mall-order-types.dart  # 已存在 ✅

# 不存在则从 SDK 翻译
# 读取: /Users/fan/www/AI/z1/z1-mid/src/types/mall-order-types.ts
# 写入: lib/types/api/mall-order-types.dart
# 验证: flutter analyze 通过
```

### Step 4a: 写展示层模型（先做这一步，先别写页面）

```dart
// lib/features/mall_order/data/models/mall_order_model.dart
import '../../../../types/api/mall-order-types.dart';

class MallOrderModel extends Equatable {
  final String number;
  final MallOrderStatus status;
  final String customerName;
  final int orderAmount;
  // ... 11 个窄视图字段

  factory MallOrderModel.fromJson(Map<String, dynamic> json) {
    return MallOrderModel(
      number: json['number'] as String? ?? '',
      status: MallOrderStatus.fromValue((json['status'] as int?) ?? 1),
      customerName: json['customerName'] as String? ?? '',
      orderAmount: (json['orderAmount'] as int?) ?? 0,
      // ...
    );
  }
}
```

`flutter analyze lib/features/mall_order` → 0 errors。

### Step 4b: 真实接口空跑（⚠️ 关键，先别写 datasource / 页面）

```dart
// 一次性 probe（已有页面 initState、临时 main、BLoC 调试入口都行）
final raw = await apiClient.get(
  '/mall-order/list',
  queryParameters: {'page': 1, 'pageSize': 5},
);
debugPrint('raw response: ${raw.data}');

final items = (raw.data['list'] as List)
    .map((e) => MallOrderModel.fromJson(e as Map<String, dynamic>))
    .toList();
debugPrint('parsed ${items.length} items');
```

**期望产出**：
- 一段真实响应 JSON，贴回 `mall_order_model.dart` 顶部注释
- 一份"协议层 vs 真实响应"字段差集笔记
- 三类响应（正常 / 空 / 错误）的兜底确认

**典型发现**（举例）：
- `customerName` 实际有 join 返回，模型不需要再异步补查
- `info` 数组里 `skuName` 偶尔为空，`firstItemSummary` 需要 fallback 到 `'商品 x{qty}'`
- 后端可能返回 `transport: "post" | "store"`，模型需要 string → enum 转换

### Step 4c: Datasource → BLoC → Page → Router

```dart
// datasource
class MallOrderRemoteDataSource {
  Future<Result<List<MallOrderModel>>> list({...}) async {
    try {
      final raw = await apiClient.get('/mall-order/list', queryParameters: {...});
      final list = (raw.data['list'] as List)
          .map((e) => MallOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
// BLoC / Page / Router & DI 略
```

### Step 5: 测试验证

- 冒烟测试：列表页能打开，6 个 tab 切换不崩
- 类型映射：响应字段能解析为 `MallOrderModel`（已经在 4b 验证过）
- 不测：参数名对不对（类型已保证）

---

## 八、常见问题

### Q1: PRD 中的参数名过时了怎么办？

**A**: 更新类型文件中的注释，PRD 中的参数引用只是提示，不是真实源。

### Q2: 多个接口返回同一实体用什么类型？

**A**: 同一个实体用一个类型文件，如 `Member` 在 `member-types.dart`。

### Q3: API 返回字段比类型少怎么办？

**A**: 使用可选类型 `?`，如 `String? optionalField`。

### Q4: 字段类型不确定怎么办？

**A**: 使用 `dynamic`，在注释中说明可能的类型。先把展示层模型写出来，
然后走 3.B 空跑用真实响应把类型敲定。

### Q5: 为什么不能直接写 datasource、出问题再调试？

**A**: 协议层是数据库实体的镜像，与 API 响应有结构性差异（join 字段、聚合字段、
压缩状态）。如果先写完 datasource → BLoC → 页面，跑起来发现响应不匹配，
就要回头改 4 个文件；而 3.B 空跑只需要写一段 ~10 行的 probe 代码，
代价低一个数量级。**真实响应是模型设计的最强反馈源，不要把它留到最后。**

### Q6: 空跑的 probe 代码要不要提交？

**A**: probe 本身不提交（它只是一次性验证脚本），但**真实响应样本必须以 JSON
注释的形式贴回模型文件**，作为下次维护时的参考。如果发现 PRD 与真实响应不一致，
要回写 PRD。

### Q7: 如果连不上后端怎么办？

**A**: 优先恢复连接（开 VPN、确认环境地址、确认 token 有效）。3.B 是强制
checkpoint，不能跳过。如果短期确实无法连接，至少要在 PR / journal 里标注
"未空跑"，并在恢复后立刻补做。

---
