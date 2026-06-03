# 文档索引

> z1-nextapp 项目文档结构说明
> 最后更新：2026-05-28

---

## 项目核心规则

> ⚠️ 阅读 `/AGENTS.md` 了解开发流程与分工。
> ⚠️ **类型唯一真实源**：API 字段以 `z1_mobile/lib/types/api/*.dart` 为准，PRD 文档**禁止**复制具体字段名/类型。

---

## 目录结构

```
docs/
├── README.md                  # 本文件
├── prd.md                     # ⚠️ 已废弃（旧版总 PRD，路由已过时，仅留作历史参考）
│
├── features/                  # 模块 PRD（按业务模块拆分）
│   ├── feature-list.md        # 总功能清单
│   ├── roadmap.md             # 长期规划
│   ├── *-detail-prd.md        # 各模块详细 PRD（21 份）
│   └── *-design-learning.md   # 设计调研笔记
│
├── guides/                    # 开发规范（必读）
│   ├── ai-doc-type-workflow.md       # 文档-类型工作流
│   └── flutter-agent-type-guide.md   # Flutter Agent 类型使用指南
│
├── api/                       # 接口文档
│   ├── order-api-reference.md
│   ├── order-api-examples.md
│   └── api-product-closure-check.md
│
├── prototypes/                # 可交互 HTML 原型
│   ├── home/  profile/  retail/  workbench/
│   ├── prototype_backup/
│   ├── category-select-prototype.html
│   └── service-select-prototype.html
│
├── status/                    # 实现状态、变更记录、审计报告
│   ├── implementation.md
│   ├── changelog.md
│   ├── api-audit-report-*.md
│   ├── page-audit-*.md
│   └── ...
│
├── phase/                     # 阶段进度
│   └── phase-progress-report.md
│
└── tasks/                     # 待办任务清单
    └── order-detail-fix-task.md
```

---

## 文档编写规范

### 命名规则

- 文件名全小写，中划线分隔：`retail-detail-prd.md`
- 模块 PRD 命名：`{模块}-detail-prd.md`
- 时间相关文档加日期后缀：`api-audit-report-2026-0528.md`

### 编写原则

1. **类型唯一真实源**：PRD 不写具体字段名/类型，只引用类型文件路径
   - ❌ 错误：`userId: string  // 用户 ID`
   - ✅ 正确：`参数/响应见 lib/types/api/member-types.dart 的 MemberData`
2. **单一事实来源**：同一信息只在一处维护
3. **状态可追溯**：变更记录到 `status/changelog.md`
4. **PRD 先行**：开发新模块前，必须先有对应 PRD

### 模块 PRD 结构（推荐）

```markdown
# {模块名} · 详细 PRD

> 模块、版本、日期、状态
> 依据：lib/types/api/xxx-types.dart（类型文件）+ 接口路径

## 一、页面路径
## 二、页面布局（ASCII 草图）
## 三、核心交互逻辑
## 四、接口清单（路径 + 方法 + 类型文件路径）
## 五、状态流转
## 六、异常/边界
## 七、模块关联
```

---

## 维护责任

| 文档 | 负责人 | 更新时机 |
|------|--------|----------|
| `AGENTS.md` | 项目经理 | 流程或模块状态变化 |
| `features/*-prd.md` | 文档助手 | 需求变更时 |
| `guides/*` | 技术负责人 | 规范调整时 |
| `status/*` | 开发/测试团队 | 每个里程碑或审计后 |
| `api/*` | 后端联调时 | 接口变更时 |

---

## 历史归档

| 文件 | 状态 | 说明 |
|------|------|------|
| `docs/prd.md` | ⚠️ 废弃 | 路由已过时，被 `features/*-detail-prd.md` 拆分替代 |
| docs/features/serial-search-detail-prd.md | 已删除 | 与 `serial-query-detail-prd.md` 重复 |
| `docs/features/*.html` | 已迁移 | 移到 `docs/prototypes/` |
