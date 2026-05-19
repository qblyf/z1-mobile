# 文档索引

> 本目录规范是 z1-mobile 项目文档管理的标准。
> 所有新增文档必须遵循此结构。
> 更新于 2026-05-15

---

## 目录结构

```
docs/
├── prd.md                    # 主产品需求文档（包含核心功能需求）
├── design/                   # 技术设计文档
│   ├── project-design.md    # 技术架构、目录结构、技术选型
│   ├── api-spec.md          # 接口规范（按模块拆分）
│   └── data-model.md        # 数据模型（实体定义、关系）
├── features/                 # 功能文档
│   ├── feature-list.md      # 功能清单（聚焦 Phase 4-5）
│   └── roadmap.md           # 长期规划（P2/P3 粗略版本）
├── prototypes/               # 可交互 HTML 原型
│   ├── home/
│   ├── profile/
│   ├── workbench/
│   └── retail/
├── status/                   # 状态跟踪
│   ├── implementation.md    # 当前实现状态（页面/模块完成度）
│   └── changelog.md         # 变更记录（按版本）
└── README.md                # 本文件，文档索引
```

---

## 文档规范

### 命名规则

- 文件名全小写，中划线分隔：`feature-list.md`
- 目录名全小写，中划线分隔：`design/`
- 原型目录按模块名：`retail/`、`home/`

### 文档编写原则

1. **单一事实来源**：每份内容只出现在一个文件中，避免重复维护
2. **主 PRD 为核心**：`prd.md` 是所有需求的源头，子功能不应复制主 PRD 内容
3. **Phase 聚焦**：feature-list.md 只记录当前 Phase（4-5）功能，P2/P3 移至 roadmap.md
4. **变更可追溯**：所有文档修改记录到 `status/changelog.md`

### 禁止事项

- 不创建孤立的子功能 PRD（如 `sales-list-prd.md`、`retail-prd.md`）
- 不在根目录放置分散的文档文件
- 不保留过时的 `prototype/` 目录（统一到 `docs/prototypes/`）

---

## 现有文档归属

| 原文件 | 新位置 | 说明 |
|--------|--------|------|
| `docs/prd.md` | `docs/prd.md` | 保留 |
| `docs/project-design.md` | `docs/design/project-design.md` | 已移动 |
| `docs/feature-list.md` | `docs/features/feature-list.md` | 已移动 |
| `docs/phase1-implementation.md` | `docs/status/implementation.md` | 已移动+重命名 |
| `docs/api-spec.md` | `docs/design/api-spec.md` | ✅ 新增 |
| `docs/data-model.md` | `docs/design/data-model.md` | ✅ 新增 |
| `docs/sales-list-prd.md` | - | ❌ 废弃 |
| `docs/retail-prd.md` | - | ❌ 废弃 |
| `prototype/` | `docs/prototypes/prototype_backup/` | 已移动 |

---

## 维护责任

| 文档 | 负责人 | 更新时机 |
|------|--------|----------|
| prd.md | 产品/文档助手 | 需求变更时 |
| design/* | 技术负责人 | 技术方案确定时 |
| features/* | 产品/文档助手 | 功能规划迭代时 |
| status/* | 开发团队 | 每个里程碑完成时 |

---

> 后续所有文档操作必须遵循此结构。