# Z1-NextApp 开发规范

> **最后更新**：2026-05-28

---

## 核心规则

### ⚠️ 类型定义是唯一真实源

**API 类型定义文件 `lib/types/api/` 是唯一真实源，文档仅供参考。**

| 文档类型 | 作用 |
|---------|------|
| `lib/types/api/*.dart` | **唯一真实源**，参数名/字段类型以此为准 |
| `docs/features/*prd.md` | 描述业务需求，不写具体参数名 |
| `docs/guides/ai-doc-type-workflow.md` | 开发流程规范 |

```
❌ 旧做法：文档写具体参数名 → 参数名过时，代码报错
✅ 新做法：文档只引用类型路径 → 类型不匹配，编译失败
```

**Flutter Agent 必须阅读**：
- `docs/guides/ai-doc-type-workflow.md` - 开发流程规范
- `docs/guides/flutter-agent-type-guide.md` - 类型使用指南

---

## 开发流程（2026-05-28 更新）

```
阶段一：需求定义
  1. 业务方提需求 → 文档助手
  2. 文档助手编写 PRD：
     - 用户故事、交互流程
     - 标注「接口：XXX，类型见 lib/types/api/xxx-types.dart」
     - 不写具体参数名（避免过时）

阶段二：类型同步（AI 翻译）
  3. AI 从 SDK 翻译类型到 Dart：
     - 读取：/Users/fan/www/AI/z1/z1-mid/src/types/
     - 写入：z1_mobile/lib/types/api/
     - 每个文件 flutter analyze 通过才算完成
     - 不使用脚本自动转换（会失败）
  4. 类型文件验证通过后，更新 api.dart 导出

阶段三：Flutter 开发
  5. Flutter Agent 收到 context：
     - PRD 文档（描述用户需求）
     - lib/types/api/*.dart（唯一真实源）
     - 开发流程规范文档
  6. 开发时：
     - 先读类型文件
     - 参数类型从类型文件 import
     - 类型不匹配 → 编译失败，立刻发现
  7. 自测：flutter analyze + flutter build web

阶段四：测试验证
  8. 测试 Agent：
     - 冒烟测试（接口可达）
     - 类型映射验证（响应字段匹配类型定义）
     - 不测「参数名对不对」（类型已经保证了）
  9. 结果：
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

**每次开发完成后，必须通过 mavis communication send 告知项目经理（session ID: mvs_edb5225cc4284c29bb93eb2244ec6f66）。**

---

## 分工规则

| 工作类型 | 执行人 | Session ID |
|---------|-------|------------|
| 代码改动 | flutter开发 | mvs_3a6e069df73f4e72bdda851544213e13 |
| 测试执行 | flutter测试 | mvs_c8927294e7aa49478ebaa425f4ae34e1 |
| 文档编写 | 文档助手 | mvs_d07499453c1844b99e6cff61536246b9 |
| 调度协调 | 项目经理 | mvs_edb5225cc4284c29bb93eb2244ec6f66 |

---

## 文档位置

| 类型 | 位置 |
|------|------|
| PRD 文档 | `docs/features/` |
| **开发流程规范** | `docs/guides/ai-doc-type-workflow.md` |
| **类型使用指南** | `docs/guides/flutter-agent-type-guide.md` |
| **类型文件（唯一真实源）** | `z1_mobile/lib/types/api/` |

---

## 已知技术问题

### 两套分类 ID 系统

| 字段 | 来源 | 用途 |
|------|------|------|
| `spuCateID` | 旧分类 | 旧系统，**不要用这个匹配商城分类** |
| `mallThirdCate` | 商城分类 | 新系统，**用于匹配商城分类** |

### 类型文件状态（2026-05-28 更新）

**✅ 全部已验证可用（0 errors，18个文件）**

| 文件 | 说明 |
|------|------|
| `lib/types/common.dart` | 基础类型 |
| `lib/types/api/product-types.dart` | 商品类型 |
| `lib/types/api/order-types.dart` | 订单类型 |
| `lib/types/api/member-types.dart` | 会员类型 |
| `lib/types/api/stock-types.dart` | 库存类型 |
| `lib/types/api/stocktaking-types.dart` | 盘库类型 |
| `lib/types/api/serial-types.dart` | 序列号类型 |
| `lib/types/api/dashboard-types.dart` | 仪表盘类型 |
| `lib/types/api/task-types.dart` | 任务类型 |
| ... 其他 9 个类型文件 |

---

## 页面状态

### 已完成模块

- ✅ 登录/首页
- ✅ 零售开单（6页 + 优惠券）
- ✅ 订单列表/详情
- ✅ 会员中心（5页）
- ✅ 盘库（3页）
- ✅ 调拨（3页，占位符）
- ✅ 采购（3页，占位符）
- ✅ 序列号查询

### 待开发模块

- 🔵 工作台/任务/我的（部分完成）
- 🔵 审批中心
