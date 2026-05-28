# 商品/服务选购页面接口测试结果

**测试日期**: 2026-05-23
**Base URL**: https://z1-fun.zsqk.com.cn/deno

---

## 测试结果总览

| Tab | 接口 | 方法 | 状态 | 备注 |
|-----|------|------|------|------|
| 商品 | `/category/list` | GET | ✅ 可用 | 不需要 type 参数，返回 9293 条分类 |
| 商品 | `/spu/list` | GET | ✅ 可用 | 支持 cateId, limit 参数 |
| 商品 | `/product/spu-list` | GET | ❌ 不存在 | 404 |
| 商品 | `/product/list-by-condition` | GET | ❌ 不存在 | 404 |
| 商品 | `/product/stock-by-spu` | GET | ❌ 不存在 | 无响应/超时 |
| 商品 | `/product/stock-by-sku` | GET | ❌ 不存在 | 无响应/超时 |
| 服务 | `/category/list` | GET | ✅ 可用 | 同上 |
| 服务 | `/serve/list` | GET | ✅ 可用 | 无需认证 |
| 服务 | `/serve/count` | GET | ✅ 可用 | 需认证 |
| 非标品 | `/category/list` | GET | ✅ 可用 | 同上 |
| 非标品 | `/item/all` | GET | ❌ 需认证 | 90000 权限不足 |
| 非标品 | `/item/list` | GET | ❌ 不存在 | 404 |

---

## 实际可用的接口

### 1. 分类列表
```
GET /category/list
响应: {"code":10000,"list":[...]}
```
- 返回全部分类数据（9293 条）
- 字段: id, name, spell, pid, order, type, state, chain 等
- **注意**: 不需要 type 参数

### 2. SPU 列表
```
GET /spu/list?cateId={id}&limit={num}
响应: {"code":10000,"list":[...]}
```
- 支持按分类筛选和分页
- 额外可用: GET /spu/count (返回 8755)

---

## 文档路径错误汇总

| 文档路径 | 实际路径 |
|---------|---------|
| `/category/list?type=spu` | `/category/list` |
| `/category/list?type=service` | `/category/list` |
| `/product/spu-list` | `/spu/list` |
| `/product/list-by-condition` | ❌ 不存在 |
| `/product/stock-by-spu` | ❌ 不存在 |
| `/product/stock-by-sku` | ❌ 不存在 |
| `/serve/list` | ✅ 可用 |
| `/serve/count` | ✅ 可用 |
| `/item/all` | ❌ 需认证/不存在 |

---

## 建议

1. **分类接口**: 统一使用 `/category/list`，不需要 type 参数
2. **SPU 列表**: 使用 `/spu/list?cateId=&limit=`
3. **服务/非标品**: 这些接口不存在，需确认是否由后端提供
