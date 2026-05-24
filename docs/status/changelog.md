# 变更日志

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