# 服务选择 · 产品文档

> **模块**：零售开单 - 服务选择
> **版本**：v1.0
> **日期**：2026-05-24
> **状态**：待开发
> **依据**：z1-pwa SelectService 组件分析

---

## 一、产品概述

### 1.1 业务背景

门店零售开单时，除了销售商品，还可能涉及服务项目（如：刻字、清洗、保养、维修等）。服务选择模块提供服务的快速查找和选择。

### 1.2 核心价值

| 价值 | 说明 |
|------|------|
| **快速定位** | 通过分类快速找到目标服务 |
| **支持搜索** | 支持服务名称关键词搜索 |
| **灵活选择** | 支持单选和多选模式 |

---

## 二、用户场景

### 场景1：按分类选择服务

**用户**：门店店员
**场景**：顾客需要刻字服务
**流程**：
1. 点击「服务」Tab
2. 选择「刻字」分类
3. 查看该分类下的服务列表
4. 选择具体服务

### 场景2：搜索服务

**用户**：门店店员
**场景**：知道服务名称
**流程**：
1. 在搜索框输入服务名称
2. 系统返回匹配的服务列表
3. 选择服务

### 场景3：多选服务

**用户**：门店店员
**场景**：顾客需要多个服务（刻字+清洗）
**流程**：
1. 开启多选模式
2. 依次选择多个服务
3. 确认提交

---

## 三、页面结构

### 3.1 布局

```
┌──────────────────────────────────┐
│ ← 选择服务              [确定]   │
├──────────────────────────────────┤
│ [商品] [服务] [非标品]           │ ← Tab 切换
├──────────────────────────────────┤
│ [🔍 搜索服务名称]     [📷]      │ ← 搜索栏
├──────────────────────────────────┤
│ ┌──────┬─────────────────────┐  │
│ │ 分类  │                     │  │
│ │      │     服务列表          │  │
│ │ 刻字  │                     │  │
│ │ 清洗  │  ┌────────────────┐ │  │
│ │ 保养  │  │ 黄金刻字       │ │  │
│ │ 维修  │  │ ¥88           │ │  │
│ │      │  └────────────────┘ │  │
│ │      │  ┌────────────────┐ │  │
│ │      │  │ 银饰刻字       │ │  │
│ │      │  │ ¥58           │ │  │
│ │      │  └────────────────┘ │  │
│ └──────┴─────────────────────┘  │
└──────────────────────────────────┘
```

---

## 四、接口实现

### 4.1 获取服务分类

> ⚠️ 服务使用**进销存分类**（不是商城分类）

```dart
// 分类类型
CategoryType.服务 = 7

// 获取服务分类
GET /category/list?type=7
```

**分类过滤**：
```dart
// 根据 pid 筛选子分类
List<Category> getChildren(List<Category> all, int parentId) {
  return all.where((c) => c.pid == parentId).toList();
}
```

### 4.2 获取服务列表

```dart
// 获取服务列表
GET /serve/list

// 参数
{
  cateID: number,        // 分类ID
  includeChild: boolean,  // 是否包含子分类
  states: [1],          // 状态：1=正常
  isGoods: 1 | 2,       // 1=绑定 2=不绑定
  keyWord: string,       // 搜索关键词
  limit: number,
  offset: number,
}

// 获取服务数量
GET /serve/count
```

### 4.3 服务数据结构

```dart
// 服务字段（ServeType）
Service {
  id: number,           // 服务ID
  number: string,       // 服务编号
  name: string,         // 服务名称
  shortName: string,    // 简称
  cate: number,         // 所属分类ID
  cent: number,         // 服务价格（分）
  costCent: number,     // 服务成本（分）
  limitCent: number,    // 大盘价格（分）
  state: 1 | 2,        // 状态：1=正常 2=禁用
  isGoods: 1 | 2,      // 是否绑定序列号
  isCoin: boolean,      // 是否使用积分
  departments: number[], // 适用部门
  listingStatus: string, // 上架状态 (listing/de-listing)
  detailImage: string,  // 详情图
  mainImages: string[], // 主图列表
  description: string,  // 服务描述
}
```

---

## 五、组件设计

### 5.1 组件清单

| 组件 | 说明 |
|------|------|
| `ServiceSelectPanel` | 服务选择面板 |
| `ServiceCategorySidebar` | 服务分类侧边栏 |
| `ServiceList` | 服务列表 |
| `ServiceSearchBar` | 服务搜索栏 |

### 5.2 组件状态

```dart
// ServiceSelectPanel 状态
enum ServicePanelState {
  loading,      // 加载中
  categories,   // 显示分类
  services,     // 显示服务列表
  search,      // 搜索结果
}

// 多选状态
class ServiceSelectionState {
  List<Service> selectedServices;  // 已选服务
  bool isMultiSelect;              // 是否多选模式
  int? maxSelection;               // 最大选择数量
}
```

### 5.3 交互逻辑

```dart
// 点击分类
onCategoryTap(cateID) {
  // 1. 更新面包屑
  setBreadcrumbs([...breadcrumbs, cateID]);
  
  // 2. 获取该分类下的服务
  final services = await serveList(cateID: cateID);
  setServiceList(services);
}

// 搜索服务
onSearch(keyWord) {
  // 1. 获取匹配的服务
  final services = await serveList(keyWord: keyWord);
  setServiceList(services);
  
  // 2. 清空面包屑
  setBreadcrumbs([]);
}

// 选择服务
onServiceTap(service) {
  if (!isMultiSelect) {
    // 单选：直接返回
    onSelect(service);
  } else {
    // 多选：添加到已选列表
    final newSelected = [...selectedServices, service];
    setSelectedServices(newSelected);
  }
}
```

---

## 六、Flutter 实现建议

### 6.1 API 调用

```dart
import 'package:dio/dio.dart';

// 获取服务列表
Future<List<Service>> getServiceList({
  int? cateID,
  String? keyWord,
  bool includeChild = false,
}) async {
  final response = await dio.get('/serve/list', queryParameters: {
    if (cateID != null) 'cateID': cateID,
    if (keyWord != null) 'keyWord': keyWord,
    'includeChild': includeChild,
    'states': [1],
    'limit': 100,
  });
  return (response.data['list'] as List)
      .map((e) => Service.fromJson(e))
      .toList();
}

// 获取服务分类
Future<List<Category>> getServiceCategories() async {
  final response = await dio.get('/category/list', queryParameters: {
    'type': 7,  // CategoryType.服务
  });
  return (response.data['list'] as List)
      .map((e) => Category.fromJson(e))
      .toList();
}
```

### 6.2 状态管理

```dart
class ServiceSelectState {
  List<Category> categories;       // 服务分类
  List<Service> services;         // 服务列表
  List<int> breadcrumbs;          // 面包屑
  List<Service> selectedServices;  // 已选服务
  bool isMultiSelect;             // 多选模式
  String? searchText;             // 搜索关键词
}
```

---

## 七、待验证接口

| 接口 | 说明 | 状态 |
|------|------|------|
| `GET /serve/list` | 服务列表 | ✅ 已验证 |
| `GET /serve/count` | 服务数量 | ✅ 已验证 |
| `GET /category/list?type=7` | 服务分类 | ✅ 已验证 |

---

## 八、注意事项

1. **分类体系**：服务使用进销存分类（`type=7`），不是商城分类
2. **过滤有序列号的服务**：通过 `isGoods` 参数过滤
3. **搜索支持关键词匹配**
4. **多选模式**：需设置 `maxSelection` 限制最大选择数

---

> 上次更新：2026-05-24