# Agent A 开发说明
## 分支：feature/product-select-a
## 风格：简洁高效

### 任务
开发商品/服务选择页面（ProductSelectPage），包含：
- 商品 Tab：分类 → SPU → SKU → 加入购物车
- 服务 Tab：分类 → 服务列表 → 加入购物车
- 购物车弹窗分类展示

### 接口
- `GET /sku/select-base` - 商品选择
- `GET /serve/list` - 服务列表

### 基础路径
`lib/features/retail/product_select/`

### 优先保证
功能覆盖，无需过度容错。代码简洁直接。

### 完成后
汇报代码改动路径和行数。