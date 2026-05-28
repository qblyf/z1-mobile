# AI 文档与接口开发流程

> 基于 2026-05-27 类型系统重建经验总结

---

## 一、核心原则

### 1.1 单一真实源

```
类型文件 (lib/types/api/*.dart)  = 唯一真实源
文档 (docs/*.md)               = 参考说明
```

**规则**：
- API 参数名/字段类型 → 以类型文件为准
- 文档只描述业务逻辑，不写具体参数名
- 参数名过时 → 更新类型文件，不是文档

### 1.2 类型驱动开发

```
PRD 文档          →  描述"做什么"
类型文件          →  描述"用什么字段"
Flutter 代码      →  描述"怎么做"
```

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
│ 阶段三：Flutter 开发                                        │
├─────────────────────────────────────────────────────────────┤
│ 4. Flutter Agent：                                         │
│    - 读取 PRD 了解业务需求                                 │
│    - 读取类型文件获取字段定义                               │
│    - 实现代码，参数类型从类型文件 import                    │
│    - 运行 flutter analyze 确认无错误                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 阶段四：测试验证                                            │
├─────────────────────────────────────────────────────────────┤
│ 5. 测试 Agent：                                            │
│    - 冒烟测试（接口可达）                                  │
│    - 类型映射验证（响应字段匹配类型定义）                   │
│    - 不测「参数名对不对」（类型已保证）                    │
└─────────────────────────────────────────────────────────────┘
```

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

### 5.1 引用类型

```dart
import 'package:z1_mobile/types/api.dart';
import 'package:z1_mobile/types/api/member-types.dart';

// 使用类型
final member = Member.fromJson(response.data);
```

### 5.2 金额处理

```dart
// 类型定义中金额单位已是 RMBFen (分)
// 显示时转换
Text('¥${(order.amount / 100).toStringAsFixed(2)}')
```

### 5.3 枚举使用

```dart
// 使用 fromValue 从 API 响应转换
final status = OrderStatus.fromValue(json['status'] as int);

// 使用枚举值
if (status == OrderStatus.shippedPaid) { ... }
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

## 七、示例：完整流程

### Step 1: 业务提需求

> 我需要一个会员列表页面，能按手机号搜索

### Step 2: AI 写 PRD

```markdown
# 会员列表 · PRD

## 接口设计

| 页面区块 | 接口 | 类型文件 |
|---------|------|---------|
| 会员列表 | GET /members/list | `lib/types/api/member-types.dart` |

## 业务规则
- 搜索参数：`keyword`（支持手机号模糊搜索）
- 分页参数：`page`, `pageSize`
```

### Step 3: AI 补充类型（如果缺失）

```bash
# 检查类型是否存在
ls lib/types/api/member-types.dart  # 已存在，跳过

# 如果不存在，从 SDK 翻译
# 读取: /Users/fan/www/AI/z1/z1-mid/src/types/member-types.ts
# 写入: lib/types/api/member-types.dart
```

### Step 4: Flutter 开发

```dart
// lib/features/member/list/page.dart
import 'package:z1_mobile/types/api.dart';

class MemberListPage extends StatelessWidget {
  Future<List<Member>> fetchMembers(String keyword) async {
    final response = await dio.get('/members/list', queryParameters: {
      'keyword': keyword,
      'page': 1,
      'pageSize': 20,
    });
    return (response.data['list'] as List)
        .map((e) => Member.fromJson(e))
        .toList();
  }
}
```

### Step 5: 测试验证

```bash
# 测试 Agent
curl https://z1-fun.zsqk.com.cn/deno/members/list?keyword=138

# 验证响应能解析为 Member 类型
flutter test
```

---

## 八、常见问题

### Q1: PRD 中的参数名过时了怎么办？

**A**: 更新类型文件中的注释，PRD 中的参数引用只是提示，不是真实源。

### Q2: 多个接口返回同一实体用什么类型？

**A**: 同一个实体用一个类型文件，如 `Member` 在 `member-types.dart`。

### Q3: API 返回字段比类型少怎么办？

**A**: 使用可选类型 `?`，如 `String? optionalField`。

### Q4: 字段类型不确定怎么办？

**A**: 使用 `dynamic`，在注释中说明可能的类型。
