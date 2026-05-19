# 文档错误报告：api-spec.md 接口路径问题汇总

> **报告编号**：DOC-ERR-2026-0516-001
> **报告日期**：2026-05-16
> **涉及文件**：`docs/design/api-spec.md`
> **状态**：待修正
> **发现问题**：测试 agent 逐一验证接口后发现，原始接口文档存在大量路径/方法错误

---

## 一、错误汇总

### 1. 认证模块

| 文档路径 | 文档方法 | 实际路径 | 实际方法 | 备注 |
|---------|---------|---------|---------|------|
| `/user/self` | GET | `/members/self` | GET | 路径名不一致 |

### 2. 会员模块

| 文档路径 | 文档方法 | 实际路径 | 实际方法 | 备注 |
|---------|---------|---------|---------|------|
| POST /members/search-by-phones | POST | GET /members/list-phones | GET | 方法错误 |
| GET /members/experience/:ident | GET | POST /members/experience | POST | 方法错误，且为积分调整接口非查询 |
| GET /members/coupon-list/:ident | GET | GET /coupons/self | GET | 路径和方法都不同 |

### 3. 商品模块

| 文档路径 | 文档方法 | 实际路径 | 实际方法 | 备注 |
|---------|---------|---------|---------|------|
| POST /product/search | POST | GET /product/list | GET | 方法错误 |
| GET /product/barcode/:code | GET | GET /product-stock-by-code | GET | 路径错误 |

### 4. 库存/仓库模块

| 文档路径 | 文档方法 | 实际路径 | 实际方法 | 备注 |
|---------|---------|---------|---------|------|
| GET /warehouse/list | GET | GET /warehouse/list-base | GET | 路径错误 |
| GET /stock-taking/list | GET | 超时（后端性能问题）| — | 需后端优化 |

### 5. 订单模块

| 文档路径 | 文档方法 | 实际路径 | 实际方法 | 备注 |
|---------|---------|---------|---------|------|
| — | — | GET /order/shop-sale-list | GET | 文档未记录此高频接口 |
| — | — | GET /order-product/list?orderID=xxx | GET | 订单详情获取方式，文档未记录 |
| — | — | GET /order/list | GET | 订单列表，文档未记录 |

---

## 二、错误类型分析

| 错误类型 | 数量 | 说明 |
|---------|------|------|
| HTTP 方法错误 | 3 | 文档写 POST 实际 GET，或反之 |
| 路径名错误 | 4 | 接口名不一致 |
| 功能误解 | 2 | 文档将调整接口当作查询接口 |
| 缺失接口 | 3 | 高频接口未写入文档 |
| 性能问题 | 1 | 后端接口超时 |

---

## 三、根因分析

**api-spec.md 文档来源为推测性内容，未经过实际接口验证。**

文档助手根据 PRDM 和 feature-list.md 中的功能描述反推接口路径和方法，但：

1. 后端接口命名习惯与文档预期不一致（如 `list-phones` vs `search-by-phones`）
2. HTTP 方法由后端定义，文档无法推测（GET vs POST）
3. 部分接口（如 `/order-product/list`）是后端特有的嵌套结构，文档编写时未覆盖

---

## 四、修正建议

### 建议 1：更新 api-spec.md

将上述错误路径全部修正为实际路径，并标注：
- 接口来源：测试 agent 验证
- 验证日期：2026-05-16

### 建议 2：建立接口文档验证机制

**所有新增接口必须经过测试 agent 验证后，才能写入 api-spec.md。**

### 建议 3：与后端对齐

联系后端团队获取一份权威的接口列表，作为文档的唯一数据源，避免反复猜测。

---

## 五、修正后的正确接口清单

### 认证

| 接口 | 方法 | 说明 |
|------|------|------|
| POST /members/phone-login | POST | 手机号登录 |
| GET /members/self | GET | 获取用户信息（包含积分） |

### 会员

| 接口 | 方法 | 说明 |
|------|------|------|
| GET /members/list-phones | GET | 手机号查找会员 |
| POST /members/experience | POST | 积分调整（不是查询）|
| GET /coupons/self | GET | 用户优惠券列表 |

### 商品

| 接口 | 方法 | 说明 |
|------|------|------|
| GET /product/list | GET | 商品列表（支持分类筛选）|
| GET /product-stock-by-code | GET | 条码查商品 |

### 订单

| 接口 | 方法 | 说明 |
|------|------|------|
| POST /order/sale-shop-add | POST | 创建零售单 |
| GET /order/shop-sale-list | GET | 零售单列表 |
| GET /order-product/list?orderID=xxx | GET | 订单商品明细 |
| GET /order/list | GET | 订单列表（通用）|

### 库存

| 接口 | 方法 | 说明 |
|------|------|------|
| GET /warehouse/list-base | GET | 仓库列表 |
| GET /stock-taking/list | GET | 盘库列表（⚠️ 有性能问题）|
| POST /stock-taking/add | POST | 新建盘库 |

---

> **后续行动**：请文档助手根据本报告修正 `api-spec.md`