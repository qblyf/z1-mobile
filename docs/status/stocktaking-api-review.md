# 盘库 API 审查报告

> **审查日期**：2026-05-16
> **审查依据**：z1-mid SDK 源码 vs stocktaking-detail-prd.md
> **输出文件**：docs/status/stocktaking-api-review.md

---

## 一、SDK 盘库相关 API 清单

### 1.1 盘库主接口

| 函数名 | API 路径 | 方法 | 说明 |
|--------|----------|------|------|
| `stocktakingList` | `/stock-taking/list` | GET | 盘库列表 |
| `stocktakingInfo` | `/stock-taking/detail` | GET | 盘库详情（需传 `ids` 参数）|
| `addStocktaking` | `/stock-taking/add` | POST | 新增盘库任务 |
| `stockTake` | `/stock-taking` | POST | 执行盘库（扫码后提交盘点）|
| `endStocktaking` | `/stock-taking/end` | POST | 完成盘库 |
| `reStocktaking` | `/stock-taking/restocktaking` | POST | 重新盘库 |
| `stocktakingDashboardList` | `/stock-taking/last-list` | GET | 盘库状态列表 |
| `stocktakingCount` | `/stock-taking/count` | GET | 盘库列表总数 |

### 1.2 盘库方案接口

| 函数名 | API 路径 | 方法 | 说明 |
|--------|----------|------|------|
| `stocktakingPlanList` | `/stock-taking-plan/list` | GET | 盘库方案列表 |
| `stocktakingPlanInfo` | `/stock-taking-plan/detail` | GET | 盘库方案详情 |
| `addStocktakingPlan` | `/stock-taking-plan/add` | POST | 新增盘库方案 |
| `updateStocktakingPlan` | `/stock-taking-plan/update` | POST | 修改盘库方案 |
| `editStocktakingPlanState` | `/stock-taking-plan/edit` | POST | 修改盘库方案状态 |

### 1.3 辅助接口

| 函数名 | API 路径 | 方法 | 说明 |
|--------|----------|------|------|
| `getProductStockByCode` | `/product-stock-by-code` | GET | 条码查商品 |
| `stockSYSData` | `/stock-taking/stock-sys` | GET | 系统库存快照 |
| `lockSYSData` | `/stock-taking/lock-sys` | GET | 锁货库存快照 |
| `getStockTakingInventory` | `/stock-taking/inventory` | GET | 盘库库存（分页排序）|
| `checkRoleStocktaking` | `/stock-taking/check-role` | POST | 校验盘库权限 |
| `stockTakingInventoryExport` | `/async-export/stock-taking-inventory-export` | GET | 盘库库存导出 |

### 1.4 盘库值班接口

| 函数名 | API 路径 | 方法 | 说明 |
|--------|----------|------|------|
| `stocktakingOnDutyClaim` | `/stock-taking-on-duty/claim` | POST | 认领盘库值班 |
| `stocktakingOnDutyDistribution` | `/stock-taking-on-duty/distribution` | POST | 分配盘库值班 |
| `stocktakingOnDutyRecive` | `/stock-taking-on-duty/recive` | POST | 确认接收值班 |
| `stocktakingOnDutyRefuse` | `/stock-taking-on-duty/refuse` | POST | 拒绝接收值班 |
| `stocktakingOnDutyHandover` | `/stock-taking-on-duty/handover` | POST | 移交盘库值班 |
| `stocktakingOnDutyInUseList` | `/stock-taking-on-duty/in-use-list` | GET | 值班一览表 |
| `stocktakingOnDutyList` | `/stock-taking-on-duty/list` | GET | 盘库值班列表 |
| `userStocktakingOnDutyList` | `/stock-taking-on-duty/user/list` | GET | 当前用户值班列表 |

---

## 二、与 PRD 文档的差异

### 2.1 接口路径差异

| PRD 描述 | SDK 实际路径 | 差异说明 |
|----------|--------------|----------|
| `POST /stock-taking/:id/submit` | 不存在 | SDK 中无 submit 接口，需用 `endStocktaking` |
| `GET /product-stock-by-code` | `/product-stock-by-code` | ✅ 一致 |

### 2.2 参数差异

| 字段 | PRD 描述 | SDK 定义 | 差异说明 |
|------|----------|----------|----------|
| `StocktakingList` params | `status` | `states[]` (数组) | PRD 写 status，SDK 用 states 数组 |
| `StocktakingInfo` params | `id` | `ids[]` (数组) | PRD 写单个 id，SDK 用 ids 数组 |
| `AddStocktaking` params | `warehouseId`, `items[]` | `warehouseID`, `planID`, `remarks` | PRD 缺少 planID，items 结构不同 |
| `stocktaking` params | `items[{productId,barcode,systemQty,actualQty}]` | `stockTake: StockTakeContent` | SDK 的 stockTake 是 `ProductStock & { createdBy, remarks }` 复杂类型 |

### 2.3 状态值差异

| 状态 | PRD 描述 | SDK 定义 | 说明 |
|------|----------|----------|------|
| `pending` | 待盘 | - | SDK 用数字 1/2 |
| `in_progress` | 进行中 | - | SDK 无此状态 |
| `submitted` | 已提交 | - | SDK 无此状态 |
| `approved` | 已完成 | - | SDK 用 `StocktakingState.进行中=1` / `已完成=2` |

**SDK StocktakingState:**
```typescript
export enum StocktakingState {
  进行中 = 1,
  已完成 = 2,
}
```

PRD 描述了 4 个状态（pending/in_progress/submitted/approved），但 SDK 只定义了 2 个。

### 2.4 字段差异

#### 盘库单（Stocktaking）vs PRD StockTakingSummary

| PRD 字段 | SDK 字段 | 备注 |
|----------|----------|------|
| `id` | ✅ `id: StocktakingID` | |
| `code` | ❌ 无 | SDK 未返回单号 |
| `warehouseId` | ✅ `warehouseID` | |
| `warehouseName` | ❌ 无 | SDK 未返回仓库名称 |
| `status` | ✅ `state` | 改名 |
| `totalItems` | ❌ 无 | SDK 无此字段 |
| `profitItems` | ❌ 无 | SDK 无此字段 |
| `lossItems` | ❌ 无 | SDK 无此字段 |
| `operatorId` | ✅ `createdBy` | |
| `startedAt` | ✅ `createdAt` | |
| `submittedAt` | ✅ `submittedAt` | |
| `approvedAt` | ❌ 无 | SDK 无此字段 |

#### 新建盘库 AddStocktaking

| PRD 字段 | SDK 定义 | 差异 |
|----------|----------|------|
| `warehouseId` | `warehouseID: WarehouseID` | 大小写 |
| `items` | `planID: StocktakingPlanID` | PRD 有 items，SDK 用 planID |
| - | `remarks?: string` | SDK 额外字段 |

---

## 三、需要后端确认的事项列表

### 高优先级

1. **提交审核接口不存在**
   - PRD: `POST /stock-taking/:id/submit`
   - SDK: 无此接口
   - 实际完成盘库用的是 `endStocktaking`，是否等同于提交审核？

2. **盘库单状态数量不匹配**
   - PRD: 4 个状态（pending/in_progress/submitted/approved）
   - SDK: 2 个状态（进行中=1/已完成=2）
   - 需确认：in_progress 和 submitted 是否合并？审核流程在哪处理？

3. **新建盘库接口参数差异**
   - PRD: 传 `items[{productId, barcode, systemQty, actualQty}]`
   - SDK: 传 `{warehouseID, planID, remarks}`
   - 需确认：新建盘库是否需要先选方案（planID）？items 在哪个接口提交？

4. **盘库列表筛选参数**
   - PRD: `status` 字符串
   - SDK: `states[]` 数字数组
   - 需确认：移动端筛选应传什么格式？

### 中优先级

5. **盘库单缺少统计字段**
   - PRD 需要: `code`, `warehouseName`, `totalItems`, `profitItems`, `lossItems`, `approvedAt`, `approvedBy`
   - SDK 返回: 无这些字段
   - 需确认：这些字段是否在其他接口获取？

6. **盘库详情接口参数**
   - PRD: `GET /stock-taking/:id` 用路径参数
   - SDK: `GET /stock-taking/detail?ids=[]` 用查询参数
   - 需确认：实际接口签名

7. **StockTakeContent 结构复杂**
   - PRD: `items[{productId, barcode, systemQty, actualQty}]`
   - SDK: `ProductStock & { createdBy, remarks }`
   - 需确认：扫码添加商品后实际盘点时传的完整参数结构

8. **仓库列表接口**
   - PRD: `/warehouse/list-base`
   - SDK: `/warehouse/list-base` ✅ 一致
   - 返回字段需确认：`id`, `name`, `number` 等

### 低优先级

9. **条码查询接口**
   - PRD: `/product/barcode/:code` 或 `/goods/serial-search`
   - SDK: `/product-stock-by-code?code=`
   - 需确认：实际使用哪个接口

10. **盘库方案（Plan）相关**
    - SDK 有完整的 `stock-taking-plan` 接口
    - PRD 未提及盘库方案
    - 需确认：新建盘库是否必须先选方案？

---

## 四、修正后的接口清单（建议）

| 页面 | 功能 | SDK 函数 | 建议 API | 方法 | 待确认 |
|------|------|----------|----------|------|--------|
| 盘库列表 | 获取列表 | `stocktakingList` | `/stock-taking/list` | GET | 1. `states` 参数格式 2. code/warehouseName 等字段 |
| 盘库列表 | 列表总数 | `stocktakingCount` | `/stock-taking/count` | GET | |
| 新建盘库 | 仓库列表 | `getSelectWarehouseData` | `/warehouse/list-base` | GET | 返回字段 |
| 新建盘库 | 盘库方案 | `stocktakingPlanList` | `/stock-taking-plan/list` | GET | 是否必须选方案 |
| 新建盘库 | 新建盘库 | `addStocktaking` | `/stock-taking/add` | POST | 参数缺少 items，需后端补充 |
| 新建盘库 | 条码查商品 | `getProductStockByCode` | `/product-stock-by-code` | GET | |
| 新建盘库 | 执行盘库 | `stockTake` | `/stock-taking` | POST | StockTakeContent 完整结构 |
| 盘库详情 | 盘库详情 | `stocktakingInfo` | `/stock-taking/detail` | GET | `ids` 参数，`approvedAt`/`approvedBy` 字段 |
| 盘库详情 | 系统库存 | `stockSYSData` | `/stock-taking/stock-sys` | GET | |
| 盘库详情 | 完成盘库 | `endStocktaking` | `/stock-taking/end` | POST | 是否等同于提交审核 |
| 盘库详情 | 重新盘库 | `reStocktaking` | `/stock-taking/restocktaking` | POST | |

---

## 五、结论

1. **PRD 状态机与 SDK 不匹配**：PRD 描述 4 状态，SDK 只有 2 状态，审核流程未体现在 SDK 中
2. **新建盘库流程不完整**：PRD 说提交 items，SDK 的 `addStocktaking` 只接受 `warehouseID + planID`，实际盘点用 `stockTake` 接口
3. **缺少 submit 接口**：`POST /stock-taking/:id/submit` 在 SDK 中不存在，需后端确认
4. **字段缺失严重**：code、warehouseName、totalItems、profitItems、lossItems 等字段 SDK 未返回

**建议**：找后端确认完整的盘库状态机、提交审核流程、以及盘点商品数据的提交时机。