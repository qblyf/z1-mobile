# 变更日志

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