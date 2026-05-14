# Z1 全网连锁系统 - Flutter App 项目设计

> 项目代号：z1-mobile
> 版本：v1.0.0
> 日期：2026-05-14

---

## 一、项目概述

### 1.1 项目背景

将现有的 Z1 全网连锁系统 PWA 手机端重构为原生 Flutter App，提升性能、用户体验和离线扫码能力。

### 1.2 项目规模

| 指标 | 数量 |
|------|------|
| PWA 页面数 | 100+ |
| 功能模块 | 6 大类 |
| z1-mid API 模型 | 300+ |
| z1-deno API 路由 | 11000+ |

### 1.3 核心依赖项目

```
z1-pwa     → 前端 PWA（React + Ionic）
    ↓ 复用 SDK
z1-mid     → 中间层 SDK（TypeScript，浏览器/Deno 双运行）
    ↓ 调用接口
z1-deno    → 后端服务（Deno + PostgreSQL）
```

---

## 二、技术架构

### 2.1 技术栈

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 跨平台框架 | Flutter 3.x | iOS/Android 双平台 |
| 状态管理 | flutter_bloc | 事件驱动，成熟稳定 |
| 路由 | go_router | 官方推荐，类型安全 |
| 网络层 | dio + retrofit | RESTful API 调用 |
| 扫码 | mobile_scanner | 原生扫码（商品/序列号） |
| 本地存储 | hive / shared_preferences | Token 持久化 |
| 依赖注入 | get_it + injectable | 服务定位器模式 |
| 代码生成 | build_runner | 自动化生成 |

### 2.2 项目目录结构

```
z1_mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/                          # 核心模块
│   │   ├── api/                       # API 客户端
│   │   │   ├── api_client.dart
│   │   │   ├── api_interceptor.dart
│   │   │   └── api_error.dart
│   │   ├── constants/                 # 常量
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── errors/                    # 错误处理
│   │   │   └── exceptions.dart
│   │   ├── router/                    # 路由配置
│   │   │   └── app_router.dart
│   │   ├── theme/                     # 主题
│   │   │   └── app_theme.dart
│   │   └── utils/                     # 工具类
│   │       └── extensions.dart
│   │
│   ├── features/                     # 功能模块（Feature-First）
│   │   ├── auth/                      # 认证模块
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   ├── presentation/
│   │   │   │   ├── bloc/
│   │   │   │   ├── pages/
│   │   │   │   └── widgets/
│   │   │   └── auth.dart
│   │   │
│   │   ├── order/                    # 订单模块
│   │   │   ├── retail/               # 零售单
│   │   │   ├── mall_order/           # 商城订单
│   │   │   ├── pre_sale/             # 预订单
│   │   │   └── ...
│   │   │
│   │   ├── inventory/               # 库存模块
│   │   │   ├── stocktaking/          # 盘库
│   │   │   ├── transfer/            # 调拨
│   │   │   ├── purchase/            # 采购
│   │   │   └── ...
│   │   │
│   │   ├── member/                  # 会员模块
│   │   │   ├── home/                # 会员中心
│   │   │   └── ...
│   │   │
│   │   ├── task/                    # 任务模块
│   │   │   ├── calendar/            # 行事历
│   │   │   ├── task_management/     # 任务管理
│   │   │   └── ...
│   │   │
│   │   ├── approval/                # 审批模块
│   │   ├── finance/                 # 财务模块
│   │   ├── inspection/              # 巡店模块
│   │   └── ...
│   │
│   ├── shared/                      # 共享模块
│   │   ├── widgets/                 # 公共组件
│   │   │   ├── app_button.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_list_tile.dart
│   │   │   ├── app_empty.dart
│   │   │   ├── app_loading.dart
│   │   │   ├── app_error.dart
│   │   │   └── scanner_button.dart  # 扫码按钮
│   │   ├── models/                  # 共享模型
│   │   └── services/                # 公共服务
│   │       └── scanner_service.dart # 扫码服务
│   │
│   └── injection.dart               # 依赖注入配置
│
├── test/                            # 测试
│   ├── unit/
│   ├── widget/
│   └── integration/
│
└── pubspec.yaml
```

---

## 三、功能模块设计

### 3.1 模块优先级

| 优先级 | 模块 | 功能点 | 预计工作量 |
|--------|------|--------|-----------|
| P0 | 认证 | 登录、Token 刷新、退出 | 1 周 |
| P0 | 首页/菜单 | 菜单展示、路由跳转 | 1 周 |
| P0 | 零售开单 | 商品选择、扫码、收款 | 2 周 |
| P0 | 订单列表 | 列表查询、详情查看 | 1 周 |
| P1 | 会员中心 | 会员查询、信息编辑 | 1 周 |
| P1 | 盘库 | 扫码盘库、提交 | 2 周 |
| P1 | 调拨出库 | 扫码调拨 | 1 周 |
| P2 | 行事历 | 日历展示、新建任务 | 1 周 |
| P2 | 任务管理 | 任务列表、详情 | 1 周 |
| P2 | 审批中心 | 审批列表、处理 | 1 周 |
| P3 | 其他功能 | 采购、发票、统计等 | 按需 |

### 3.2 核心页面清单

#### 认证模块
| 页面 | 路由 | 功能 |
|------|------|------|
| 登录页 | `/login` | 账号密码登录 |

#### 首页/菜单
| 页面 | 路由 | 功能 |
|------|------|------|
| 首页 | `/home` | 菜单展示、快捷入口 |
| 菜单分类页 | `/menu/:category` | 按分类展示菜单项 |

#### 订单及会员
| 页面 | 路由 | 功能 |
|------|------|------|
| 零售开单 | `/order/retail/entry` | 开单入口 |
| 零售单编辑 | `/order/retail/edit` | 商品选择、扫码、收款 |
| 销售订单列表 | `/order/sales-list` | 订单列表 |
| 订单详情 | `/order/:orderNumber` | 订单详情 |
| 预订单处理 | `/order/pre-sale` | 预订单列表 |
| 会员中心 | `/member/home` | 会员首页 |
| 会员详情 | `/member/:memberId` | 会员信息 |

#### 商品及库存
| 页面 | 路由 | 功能 |
|------|------|------|
| 采购订单列表 | `/inventory/purchase-list` | 采购单列表 |
| 采购入库 | `/inventory/purchase-inbound` | 入库操作 |
| 盘库 | `/inventory/stocktaking` | 盘库列表 |
| 盘库详情 | `/inventory/stocktaking/:id` | 盘库操作 |
| 调拨出库 | `/inventory/transfer` | 调拨列表 |
| 序列号搜索 | `/inventory/serial-search` | 扫码搜索 |

#### 任务及审批
| 页面 | 路由 | 功能 |
|------|------|------|
| 行事历 | `/task/calendar` | 日历首页 |
| 行事历详情 | `/task/calendar/:id` | 日历详情 |
| 任务管理 | `/task/management` | 任务列表 |
| 任务详情 | `/task/management/:id` | 任务详情 |
| 审批中心 | `/approval/center` | 审批列表 |
| 审批详情 | `/approval/:id` | 审批处理 |

---

## 四、API 层设计

### 4.1 API 来源

基于 `z1-mid` SDK 和 `z1-deno` 后端，需要从 TypeScript 转换为 Dart。

### 4.2 API 分类

#### 认证类
```dart
// 登录
POST /auth/login
POST /auth/dingtalk-login
POST /auth/refresh-token

// 用户信息
GET /user/self
```

#### 订单类
```dart
// 零售订单
GET  /order/shop-sale-list
POST /order/shop-sale/add
GET  /order/:orderNumber
GET  /order/:orderNumber/print

// 商城订单
GET  /order/list
GET  /order/count

// 预订单
GET  /pre-sale/list
POST /pre-sale/add
```

#### 会员类
```dart
// 会员查询
GET  /members/list
GET  /members/specified
POST /members/add
POST /members/edit

// 会员积分
GET  /members/experience
POST /members/experience/edit
```

#### 库存类
```dart
// 盘库
GET  /stock-taking/list
POST /stock-taking/add
POST /stock-taking/end

// 调拨
GET  /transfer/list
POST /transfer/add
POST /transfer/confirm

// 采购
GET  /purchase/list
POST /purchase/add
POST /purchase/into-warehouse
```

#### 商品类
```dart
// 商品
GET  /product/list
GET  /product/detail/:id
GET  /product/select-data

// 序列号
GET  /goods/serial-trace
GET  /goods/search
```

### 4.3 API 客户端封装

```dart
// lib/core/api/api_client.dart
class ApiClient {
  final Dio _dio;
  final TokenRepository _tokenRepository;

  ApiClient({
    required Dio dio,
    required TokenRepository tokenRepository,
  })  : _dio = dio,
        _tokenRepository = tokenRepository;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async { ... }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async { ... }
}

// lib/core/api/api_interceptor.dart
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加 Token
    options.headers['authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token 过期，刷新 Token
    }
    handler.next(err);
  }
}
```

---

## 五、扫码能力设计

### 5.1 扫码场景

| 场景 | 扫码类型 | 用途 |
|------|----------|------|
| 商品选择 | 扫条码/EAN | 添加商品到订单 |
| 序列号查询 | 扫序列号 | 查询商品信息 |
| 盘库 | 扫条码 | 盘点商品数量 |
| 调拨出库 | 扫条码 | 选择调拨商品 |

### 5.2 扫码组件封装

```dart
// lib/shared/widgets/scanner_button.dart
class ScannerButton extends StatelessWidget {
  final Function(String) onScanned;

  const ScannerButton({
    super.key,
    required this.onScanned,
  });
}

// lib/shared/services/scanner_service.dart
class ScannerService {
  Future<String?> scan({
    required BuildContext context,
    ScanType type,
  }) async {
    // 调用 mobile_scanner
    // 返回扫描结果
  }
}

enum ScanType {
  barcode,    // 条码
  qrcode,     // 二维码
  serial,     // 序列号
}
```

---

## 六、状态管理设计

### 6.1 BLoC 结构

```
每个功能模块包含：
├── presentation/
│   ├── bloc/
│   │   ├── {feature}_bloc.dart
│   │   ├── {feature}_event.dart
│   │   └── {feature}_state.dart
```

### 6.2 全局状态

```dart
// Auth 状态（全局）
AuthBloc
├── AuthInitial
├── AuthLoading
├── Authenticated(user)
└── Unauthenticated

// 门店/部门选择（全局）
DepartmentBloc
├── DepartmentState(selectedDeptId)
```

---

## 七、依赖注入设计

```dart
// lib/injection.dart
@Injectable()
class ApiClient {
  // ...
}

@Injectable()
class AuthRepository {
  // ...
}

@Injectable()
class OrderRepository {
  // ...
}

Future<void> configureDependencies() async {
  final getIt = GetIt.instance;
  await GetItAsync.init(getIt);
}
```

---

## 八、开发计划

### Phase 1：基础架构（第 1-2 周）

| 任务 | 产出 |
|------|------|
| 项目脚手架 | Flutter 项目创建、目录结构 |
| 依赖配置 | pubspec.yaml、代码生成配置 |
| API 层 | Dio 配置、API 客户端、认证拦截器 |
| 路由 | GoRouter 配置、权限守卫 |
| 主题 | Material 3 主题、深浅色 |
| DI | GetIt + Injectable 配置 |

### Phase 2：认证模块（第 2-3 周）

| 任务 | 产出 |
|------|------|
| 登录页 | UI + BLoC |
| Token 管理 | 存储、刷新、拦截器 |
| 退出登录 | 清理 Token |

### Phase 3：首页菜单（第 3-4 周）

| 任务 | 产出 |
|------|------|
| 首页布局 | 菜单展示 |
| 菜单分类 | 6 大类菜单 |
| 路由配置 | 页面跳转 |

### Phase 4：核心功能 MVP（第 4-8 周）

| 任务 | 优先级 | 产出 |
|------|--------|------|
| 零售开单 | P0 | 商品选择、扫码、收款 |
| 订单列表/详情 | P0 | 列表查询、详情查看 |
| 会员中心 | P1 | 会员查询 |
| 盘库 | P1 | 扫码盘库 |
| 调拨出库 | P1 | 扫码调拨 |

### Phase 5：扩展功能（第 8-12 周）

| 任务 | 优先级 |
|------|--------|
| 行事历 | P2 |
| 任务管理 | P2 |
| 审批中心 | P2 |
| 采购入库 | P3 |
| 发票申请 | P3 |

### Phase 6：测试与优化（第 12-14 周）

| 任务 | 产出 |
|------|------|
| 单元测试 | BLoC 测试、Repository 测试 |
| Widget 测试 | 关键页面测试 |
| 集成测试 | 核心流程 E2E |
| 性能优化 | 列表懒加载、内存优化 |
| iOS/Android 构建 | 发布包 |

---

## 九、测试策略

### 9.1 测试覆盖率目标

| 模块 | 覆盖率目标 |
|------|-----------|
| BLoC | ≥ 90% |
| Repository | ≥ 80% |
| 公共组件 | ≥ 70% |
| 整体 | ≥ 60% |

### 9.2 测试分层

```
test/
├── unit/                    # 单元测试
│   ├── bloc/
│   ├── repository/
│   └── usecase/
├── widget/                  # Widget 测试
│   └── pages/
└── integration/             # 集成测试
    └── features/
```

---

## 十、风险管理

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| API 转换工作量 | 高 | 优先转换高频 API，批量生成代码 |
| 扫码兼容性 | 中 | 使用 mobile_scanner，多设备测试 |
| 性能问题 | 中 | 及时 Profiling，优化列表渲染 |
| 需求变更 | 中 | 敏捷迭代，每两周验收 |

---

## 十一、参考文档

- [z1-pwa 项目](../z1-pwa/)
- [z1-mid SDK](../z1-mid/)
- [z1-deno 后端](../z1-deno/)
- [Flutter Testing Agent](../skills/flutter-testing-agent/)
