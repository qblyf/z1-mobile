# Z1 全网连锁 · Flutter App 第一期产品文档（Phase 1）

> **文档版本**：v1.0
> **日期**：2026-05-15
> **状态**：进行中
> **范围**：零售开单 + 基础框架（登录/首页/TabBar）

---

## 一、产品概述

### 1.1 目标

将 PWA 版本的零售开单功能重构为 Flutter 原生 App，实现：
- 离线可用（门店网络不稳定仍可操作）
- 扫码原生（商品条码、序列号一扫即得）
- 性能流畅（原生体验比 PWA 更跟手）

### 1.2 范围

| 模块 | 说明 | 优先级 |
|------|------|--------|
| 认证 | 登录、Token 管理、退出 | P0 |
| 首页 | 数据概览、快捷操作、功能入口 | P0 |
| 零售开单 | 全流程（开单→选购→收款→订单） | P0 |
| 订单列表 | 今日/历史订单查询 | P0 |

---

## 二、技术架构

### 2.1 技术栈

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 框架 | Flutter 3.x | iOS/Android 双平台 |
| 状态管理 | flutter_bloc | BLoC 模式 |
| 路由 | go_router | 官方推荐 |
| 网络层 | dio + retrofit | RESTful API |
| 本地存储 | flutter_secure_storage | Token 持久化 |
| 扫码 | mobile_scanner | 原生扫码 |

### 2.2 依赖 z1-mid SDK

项目复用 `z1-mid` SDK（TypeScript），需要转换为 Dart：

```
z1-pwa（React） → z1-mid（TS） → z1-deno（后端）
                      ↓
              Flutter App（Dart）
```

### 2.3 项目结构

```
z1_mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/                          # 核心模块
│   │   ├── api/                       # API 客户端
│   │   │   ├── api_client.dart
│   │   │   └── api_interceptor.dart
│   │   ├── router/                   # 路由
│   │   ├── theme/                    # 主题
│   │   └── utils/                    # 工具类
│   │
│   ├── features/                      # 功能模块
│   │   ├── auth/                     # 认证
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── home/                     # 首页
│   │   ├── retail/                    # 零售开单
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   └── order/                    # 订单
│   │
│   └── shared/                        # 共享
│       ├── widgets/
│       └── services/
│           └── scanner_service.dart
```

---

## 三、零售开单功能实现

### 3.1 功能流程

```
┌──────────────────────────────────────────────────────────────┐
│                      零售开单全流程                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ① 开单入口（/order/retail/entry）                          │
│     ├── 选择销售类型（零售/批发/工程）                       │
│     ├── 绑定会员（扫码/手机号查找）                          │
│     └── 散客直接开单                                        │
│              ↓                                              │
│  ② 商品选购（/order/retail/product-list）                  │
│     ├── 分类筛选（黄金/钻石/银饰/翡翠等）                   │
│     ├── 搜索（商品名称/条码）                               │
│     ├── 扫码添加（mobile_scanner）                           │
│     ├── 购物车（数量修改/删除）                              │
│     └── 优惠券选择                                          │
│              ↓                                              │
│  ③ 订单确认（/order/retail/confirm）                        │
│     ├── 商品明细（名称/单价/数量/小计）                      │
│     ├── 会员信息（积分抵扣/优惠券）                         │
│     ├── 优惠合计                                            │
│     └── 应收金额                                            │
│              ↓                                              │
│  ④ 收款（/order/retail/payment）                           │
│     ├── 支付方式（现金/微信/支付宝/其他）                   │
│     ├── 找零计算                                            │
│     └── 确认收款 → 生成订单                                 │
│              ↓                                              │
│  ⑤ 订单详情（/order/:orderNumber）                         │
│     ├── 订单信息（订单号/时间/状态）                        │
│     ├── 商品明细                                            │
│     ├── 支付信息                                            │
│     └── 操作（打印小票/申请退款）                           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 API 接口对照（PWA → Flutter）

#### 3.2.1 零售单相关

| 功能 | PWA API | z1-mid 函数 | Flutter 实现 |
|------|---------|-------------|--------------|
| 创建零售单 | `POST /order/sale-shop-add` | `shopSaleAdd` | `ShopSaleRepository.create()` |
| 查询零售单列表 | `POST /order/shop-sale-list` | `getShopSaleOrderList` | `ShopSaleRepository.list()` |
| 查询零售单数量 | `GET /order/shop-sale-count` | `getShopSaleOrderCount` | `ShopSaleRepository.count()` |
| 零售单详情 | `GET /order/shop-sale-info/:number` | `getShopSaleInfo` | `ShopSaleRepository.detail()` |

#### 3.2.2 会员相关

| 功能 | PWA API | z1-mid 函数 | Flutter 实现 |
|------|---------|-------------|--------------|
| 手机号查会员 | `POST /members/search-by-phones` | `getMemberByPhones` | `MemberRepository.findByPhone()` |
| 会员详情 | `GET /members/:ident` | `getMemberDetail` | `MemberRepository.detail()` |
| 积分查询 | `GET /members/experience/:ident` | `getMemberExperience` | `MemberRepository.getPoints()` |
| 积分调整 | `POST /members/experience/edit` | `editMemberExperience` | `MemberRepository.adjustPoints()` |

#### 3.2.3 商品相关

| 功能 | PWA API | z1-mid 函数 | Flutter 实现 |
|------|---------|-------------|--------------|
| 商品搜索 | `POST /product/search` | `searchProduct` | `ProductRepository.search()` |
| 商品列表（分类） | `GET /product/list` | `getProductList` | `ProductRepository.list()` |
| 商品详情 | `GET /product/:id` | `getProductDetail` | `ProductRepository.detail()` |
| 序列号查询 | `POST /goods/serial-trace` | `getGoodsBySerial` | `GoodsRepository.searchBySerial()` |

#### 3.2.4 优惠券相关

| 功能 | PWA API | z1-mid 函数 | Flutter 实现 |
|------|---------|-------------|--------------|
| 会员优惠券列表 | `GET /coupon/list/:ident` | `couponList` | `CouponRepository.memberList()` |
| 优惠券详情 | `GET /coupon/:id` | `getCouponDetail` | `CouponRepository.detail()` |

---

## 四、数据模型

### 4.1 订单模型

根据 `z1-mid/src/types/order-sales-types.ts` 和 `z1-mid/src/types/order-types.ts`：

```dart
// 订单基础信息
class Order {
  final String orderNumber;     // 订单号，如 Z1-20260515-001
  final int sellerIdent;         // 销售员标识
  final int handlerIdent;       // 经办人标识
  final int departmentID;       // 部门/门店ID
  final OrderStatus status;      // 状态：进行中/已完成/已退款
  final SalesType type;         // 销售类型：零售/批发/工程
  final SalesMode genre;        // 销售模式
  final int createdAt;           // 创建时间（Unix timestamp）
  final RMBFen totalAmount;      // 订单总额（分）
  final String? remarks;        // 备注
}

// 店内零售单扩展
class ShopSale {
  final int shopSaleID;
  final int orderID;
  final int? incCoins;          // 增加积分
  final int? decCoins;          // 扣减积分
  final int? shoppingGuideIdent;// 导购标识
  final String? platformNumber; // 平台单号
}

// 订单商品
class OrderProduct {
  final int id;
  final String orderNumber;
  final int productID;           // SKU ID
  final RMBFen productPrice;    // 原价（分）
  final RMBFen discountAmount;  // 实付金额（分）
  final int quantity;           // 数量
  final int? goodsID;           // 货品ID（序列号商品）
  final OrderProductState state;// 状态：正常/已退
  final bool isGift;            // 是否赠品
}
```

### 4.2 会员模型

根据 `z1-mid/src/types/member-types.ts`：

```dart
class Member {
  final int ident;              // 会员标识
  final String realName;        // 姓名
  final String mobilePhone;     // 手机号（脱敏显示）
  final MemberLevel level;      // 会员等级
  final int coin;               // 当前积分
  final int? experience;        // 经验值
  final String? joinTime;       // 注册时间
  final int? lastBuyAt;         // 最后购买时间
  final MemberBuyStatus buyStatus;// 购买状态
}

// 会员等级
enum MemberLevel {
  普通 = 1,
  银卡 = 2,
  金卡 = 3,
  钻石 = 4,
}
```

### 4.3 商品模型

根据 `z1-mid/src/types/product-types.ts`：

```dart
class Product {
  final int id;                 // SPU ID
  final int skuID;              // SKU ID
  final String name;            // 商品名称
  final String? skuName;        // SKU 规格名
  final RMBFen price;           // 售价（分）
  final RMBFen? memberPrice;    // 会员价（分）
  final int stock;              // 库存数量
  final bool hasSN;             // 是否有序列号
  final int cateID;             // 分类ID
  final String? imageUrl;       // 图片URL
}

// 商品分类
class ProductCate {
  final int id;
  final String name;            // 分类名（黄金/钻石/银饰等）
  final int? parentID;         // 父分类ID
  final int sort;              // 排序
}
```

---

## 五、Flutter 实现要点

### 5.1 API 层实现

基于 `z1-mid/src/model/z1/order.ts` 转换为 Dart：

```dart
// lib/core/api/api_client.dart
class ApiClient {
  final Dio _dio;
  final TokenRepository _tokenRepository;

  Future<List<Order>> getShopSaleOrderList(ShopSaleParams params) async {
    final token = await _tokenRepository.getToken();
    final response = await _dio.post(
      '/order/shop-sale-list',
      data: params.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data['res'] as List)
        .map((e) => Order.fromJson(e))
        .toList();
  }

  Future<String> shopSaleAdd(AddShopSaleParams params) async {
    final token = await _tokenRepository.getToken();
    final response = await _dio.post(
      '/order/sale-shop-add',
      data: params.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['orderNumber'];
  }
}
```

### 5.2 BLoC 设计

```dart
// lib/features/retail/presentation/bloc/retail_bloc.dart
abstract class RetailEvent {}
class SelectSalesType extends RetailEvent {}
class BindMember extends RetailEvent {}
class UnbindMember extends RetailEvent {}
class AddProduct extends RetailEvent {}
class UpdateQuantity extends RetailEvent {}
class SelectCoupon extends RetailEvent {}
class SubmitOrder extends RetailEvent {}

abstract class RetailState {}
class RetailInitial extends RetailState {}
class RetailLoading extends RetailState {}
class RetailInProgress extends RetailState {
  final SalesType salesType;
  final Member? member;
  final List<CartItem> cartItems;
  final List<Coupon> availableCoupons;
  final RMBFen totalAmount;
}
class RetailSuccess extends RetailState {
  final String orderNumber;
}
class RetailError extends RetailState {
  final String message;
}
```

### 5.3 扫码服务

```dart
// lib/shared/services/scanner_service.dart
class ScannerService {
  Future<String?> scan(BuildContext context) async {
    final result = await ScannerButton.show(context);
    return result;
  }

  // 根据扫描结果查询商品
  Future<Product?> lookupByBarcode(String barcode) async {
    // 调用 ProductRepository.search()
  }

  // 根据序列号查询货品
  Future<Goods?> lookupBySerial(String serial) async {
    // 调用 GoodsRepository.searchBySerial()
  }
}
```

---

## 六、页面清单（Phase 1）

| 页面 | 路由 | 功能 | 状态 |
|------|------|------|------|
| 登录页 | `/login` | 手机号+密码登录 | TODO |
| 首页 | `/home` | 数据概览、功能入口、快捷操作 | TODO |
| 零售开单入口 | `/order/retail/entry` | 选择销售类型、绑定会员 | TODO |
| 商品选购 | `/order/retail/product-list` | 分类、搜索、购物车 | TODO |
| 商品详情弹窗 | — | SKU选择、数量 | TODO |
| 优惠券选择 | `/order/retail/coupon-select` | 会员优惠券列表 | TODO |
| 订单确认 | `/order/retail/confirm` | 订单明细、优惠合计 | TODO |
| 收款页 | `/order/retail/payment` | 支付方式、找零 | TODO |
| 订单详情 | `/order/:orderNumber` | 订单信息、操作按钮 | TODO |
| 订单列表 | `/order/sales-list` | 今日/历史订单 | TODO |

---

## 七、UI 原型位置

已完成的 HTML 原型存放于：`docs/prototypes/`

```
docs/prototypes/
├── home/
│   ├── index.html              # 首页
│   └── navigation-flow.html    # 页面跳转逻辑图
├── retail/
│   ├── index.html              # 零售开单入口
│   ├── product-list.html       # 商品选购
│   ├── product-detail.html     # 商品详情
│   ├── member-home.html        # 会员信息
│   ├── order-confirm.html      # 订单确认
│   ├── payment.html           # 收款页
│   ├── order-detail.html       # 订单详情
│   ├── order-list.html        # 订单列表
│   ├── coupon-select.html     # 优惠券选择
│   ├── sales-list.html         # 销售统计
│   └── return-list.html        # 退换货列表
├── workbench/
│   └── index.html             # 工作台
└── profile/
    └── index.html             # 我的页面
```

---

## 八、依赖项目

| 项目 | 路径 | 说明 |
|------|------|------|
| z1-pwa | `/Users/fan/www/AI/z1/z1-pwa/` | React PWA 实现（参考） |
| z1-mid | `/Users/fan/www/AI/z1/z1-mid/` | TypeScript SDK（需转换为 Dart） |
| z1-deno | `/Users/fan/www/AI/z1/z1-deno/` | 后端服务 |

### 8.1 z1-mid 关键函数（需转换为 Dart）

```
z1-mid/src/model/z1/order.ts:
- shopSaleAdd()        → 创建零售单
- getShopSaleOrderList() → 查询零售单列表
- getShopSaleOrderCount() → 查询零售单数量

z1-mid/src/model/z1/member.ts:
- getMemberByPhones()  → 手机号查会员
- getMemberDetail()    → 会员详情
- editMemberExperience() → 积分调整

z1-mid/src/model/z1/product.ts:
- searchProduct()      → 商品搜索
- getProductList()     → 商品列表

z1-mid/src/model/z1/goods.ts:
- getGoodsBySerial()   → 序列号查询
```

---

## 九、开发计划

| 阶段 | 时间 | 任务 | 产出 |
|------|------|------|------|
| Phase 1.1 | 第1周 | 项目脚手架、依赖配置、API层 | Flutter 项目基础结构 |
| Phase 1.2 | 第2周 | 认证模块（登录、Token） | 登录页、Token管理 |
| Phase 1.3 | 第3周 | 首页框架、TabBar | 首页 UI、功能入口 |
| Phase 1.4 | 第4-5周 | 零售开单核心流程 | 11个页面完成 |
| Phase 1.5 | 第6周 | 订单列表、订单详情 | 订单模块完成 |
| Phase 1.6 | 第7-8周 | 测试与优化 | 可测试版本 |

---

## 十、风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| API 参数转换 | 高 | 参考 z1-mid 的类型定义，确保参数一致 |
| 扫码兼容性 | 中 | 使用 mobile_scanner，多设备测试 |
| 离线数据同步 | 中 | 设计本地队列，网络恢复后自动上传 |
| UI 还原度 | 中 | 对照 HTML 原型逐页面验收 |

---

> 📌 **后续行动**
>
> 1. 确认 API 层实现方案（是否复用 SDK 或重写）
> 2. 确定扫码组件版本
> 3. 开始 Phase 1.1 项目脚手架