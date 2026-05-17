# Z1-NextApp 开发规范

> **最后更新**：2026-05-17

---

## 核心规则

### 文档先行（必须遵守）

**所有功能开发必须先有 PRD 才能开工。**

流程：
1. 收到开发需求 → 检查是否有对应 PRD
2. 没有 PRD → 派给文档助手补全
3. 有 PRD 且测试 agent 验证通过 → 才能派给开发 agent

例外：占位符页面开发可以先做框架，后续补全文档。

### 分工规则

| 工作类型 | 执行人 |
|---------|-------|
| 代码改动 | flutter开发（agent-b73177f0db09）|
| 测试执行 | flutt项目测试（agent-c29355ba65db）|
| 文档编写 | 文档助手（agent-b16e31f79989）|
| 调度协调 | 项目经理（不直接写代码）|

### 代码规范

1. 所有代码修改在 worktree 中进行，不直接修改 master
2. 完成后合并到 master 并推送
3. 运行 `flutter analyze` 确认无错误后再合并

---

## 项目信息

- **baseUrl**：`https://z1-fun.zsqk.com.cn/deno`
- **金额单位**：分（cent），显示需除以 100
- **飞书文件夹**：flutter-app（token: VO7PfutLZl674vd6oWacWrw1nYe）

---

## 页面状态

详细状态见：`docs/status/page-access-verification-2026-0517.md`

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

- 🔵 工作台/任务/我的（占位符）
- 🔵 审批中心

---

## 文档位置

- PRD 文档：`docs/features/`
- 状态报告：`docs/status/`
- 接口文档：`docs/design/api-spec.md`
- 功能清单：`docs/features/feature-list.md`