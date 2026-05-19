# API 接口测试报告

> **测试日期**：2026-05-19
> **测试依据**：`docs/design/api-spec.md`
> **Base URL**：https://z1-fun.zsqk.com.cn/deno

---

## 测试结果总览

| 模块 | 接口数 | 可用 | 不可用 | 需确认 |
|------|--------|------|--------|--------|
| 会员 | 10 | 3 | 7 | 1 |
| 订单 | 5 | 2 | 3 | 0 |
| 库存（盘库/调拨/采购） | 9 | 3 | 6 | 0 |
| 商品 | 3 | 1 | 2 | 0 |
| 任务 | 4 | 1 | 3 | 1 |
| 审批 | 2 | 2 | 0 | 0 |
| 通用 | 3 | 1 | 2 | 0 |
| **合计** | **36** | **13** | **23** | **2** |

---

## 一、会员模块

### 1.1 测试结果

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/members/list` | GET | ✅ | 可用，返回会员列表 |
| `/members/list` | POST | ❌ | 方法无效 |
| `/members/specified` | GET | ⚠️ | 参数错误，需 `userIdents` 而非 `memberId` |
| `/members/add` | POST | ❌ | 参数错误，需 `user.mobilePhone` |
| `/members/edit` | POST | ❌ | 未测试 |
| `/members/experience` | GET | ❌ | 方法无效 |
| `/members/experience` | POST | ⚠️ | 参数错误，需 `member` 而非 `memberId` |
| `/members/experience/edit` | POST | ❌ | 资源不存在 |
| `/members/level/list` | GET | ❌ | 资源不存在 |
| `/members/benefit/list` | GET | ❌ | 资源不存在 |

### 1.2 实际可用的会员接口

#### GET /members/list
```json
GET /members/list
响应: {"code":10000,"list":[...],...}
```
- 返回字段：`userIdent`, `mobilePhone`, `realName`, `gender`, `experience`, `joinTime` 等

#### GET /members/specified?userIdents={id}
```json
GET /members/specified?userIdents=346279656
响应: {"code":10000,"list":[...]}
```
- 注意：参数是 `userIdents` 不是 `memberId`

#### POST /members/experience
```json
POST /members/experience
body: {"member": 346279656}
响应: {"code":90002, "message": "前端传入参数类型有误 member"}
```
- 参数需 `member`（会员 ident），不是 `memberId`

---

## 二、订单模块

### 2.1 测试结果

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/order/retail/entry` | GET | ❌ | 未测试 |
| `/order/shop-sale/add` | POST | ❌ | 资源不存在 |
| `/order/shop-sale-list` | GET | ✅ | 可用 |
| `/order/:orderNumber` | GET | ❌ | 未测试 |
| `/order/:orderNumber/print` | GET | ❌ | 未测试 |

### 2.2 实际可用的订单接口

#### GET /order/shop-sale-list
```json
GET /order/shop-sale-list?page=1&pageSize=5
响应: {"code":10000,"res":[...]}
```
- 返回字段：`orderID`, `orderNumber`, `orderAmount`, `status`, `createdAt` 等

---

## 三、库存模块

### 3.1 盘库

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/stock-taking/list` | GET | ⚠️ | 超时（6秒）|
| `/stock-taking/add` | POST | ❌ | 参数错误，需 `warehouseID` |
| `/stock-taking/:id` | GET | ❌ | 未测试 |
| `/stock-taking/:id/add-item` | POST | ❌ | 未测试 |
| `/stock-taking/:id/submit` | POST | ❌ | 未测试 |

### 3.2 调拨

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/transfer/list` | GET | ✅ | 可用 |
| `/transfer/add` | POST | ❌ | 参数错误，需 `outWarehouseID` |
| `/transfer/:id` | GET | ❌ | 未测试 |
| `/transfer/:id/confirm` | POST | ❌ | 未测试 |

### 3.3 采购

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/purchase/list` | GET | ✅ | 可用 |
| `/purchase/:id` | GET | ❌ | 资源不存在 |
| `/purchase/:id/inbound` | POST | ❌ | 资源不存在 |

### 3.4 查询

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/goods/serial-search` | GET | ❌ | 资源不存在 |
| `/goods/search` | GET | ❌ | 资源不存在 |
| `/inventory/stock-query` | GET | ❌ | 未测试 |

---

## 四、商品模块

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/product/list` | GET | ✅ | 可用 |
| `/product/detail/:id` | GET | ❌ | 未测试 |
| `/product/select-data` | GET | ❌ | 未测试 |
| `/product/barcode/:code` | GET | ❌ | 未测试 |

---

## 五、任务模块

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/task/calendar` | GET | ❌ | 资源不存在 |
| `/task/list` | GET | ✅ | 可用 |
| `/task/add` | POST | ❌ | 参数错误，需 `name` |
| `/task/:id` | GET | ❌ | 未测试 |
| `/task/:id/edit` | POST | ❌ | 未测试 |
| `/task/:id/complete` | POST | ❌ | 未测试 |
| `/task/:id/delete` | DELETE | ❌ | 未测试 |

---

## 六、审批模块

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/approval/list` | GET | ✅ | 可用 |
| `/approval/count` | GET | ✅ | 可用 |

---

## 七、通用模块

| 文档接口 | 方法 | 实际可用 | 测试结果 |
|---------|------|---------|---------|
| `/department/list` | GET | ✅ | 可用 |
| `/warehouse/list` | GET | ❌ | 资源不存在（但 `/warehouse/list-base` 可用）|
| `/payment/method/list` | GET | ❌ | 资源不存在 |

---

## 八、问题汇总

### 8.1 参数名称不一致

| 文档参数 | 实际参数 | 说明 |
|---------|---------|------|
| `memberId` | `member` 或 `userIdents` | 会员标识 |
| `warehouseId` | `warehouseID` | 仓库 ID |
| `phone` | `user.mobilePhone` | 手机号 |

### 8.2 缺失的接口

以下接口文档中有定义，但实际不存在：
- `/members/experience/edit`
- `/members/level/list`
- `/members/benefit/list`
- `/order/shop-sale/add`
- `/stock-taking/:id`
- `/stock-taking/:id/add-item`
- `/stock-taking/:id/submit`
- `/transfer/:id`
- `/transfer/:id/confirm`
- `/purchase/:id`
- `/purchase/:id/inbound`
- `/goods/serial-search`
- `/goods/search`
- `/inventory/stock-query`
- `/task/calendar`
- `/task/add`
- `/warehouse/list`
- `/payment/method/list`

### 8.3 性能问题

| 接口 | 问题 |
|------|------|
| `/stock-taking/list` | 超时（6秒），需要优化 |

---

## 九、建议

### 9.1 更新 API 文档

1. 将 `/members/specified` 参数从 `memberId` 改为 `userIdents`
2. 将 `/members/add` 参数结构改为 `user.mobilePhone`
3. 将 `/stock-taking/add` 参数从 `warehouseId` 改为 `warehouseID`
4. 标注缺失的接口

### 9.2 后端补充

建议后端补充以下接口：
- `/members/experience/edit`（积分调整）
- `/members/level/list`（会员等级列表）
- `/transfer/add`（创建调拨单）
- `/purchase/:id`（采购单详情）
- `/goods/serial-search`（序列号查询）
- `/task/add`（创建任务）

### 9.3 优化建议

- `/stock-taking/list` 接口超时，建议添加分页或索引优化

---

**测试人**：flutt项目测试
**测试时间**：2026-05-19 22:45