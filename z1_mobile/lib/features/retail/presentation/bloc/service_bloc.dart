import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../data/models/service_model.dart';
import '../../data/models/cart_item_model.dart';

/// 服务选择视图模式
enum ServiceViewMode {
  category,  // 显示分类列表
  service,   // 显示服务列表
  search,    // 显示搜索结果
}

/// 面包屑项
class BreadcrumbItem extends Equatable {
  final int id;       // 分类ID（0表示"全部"）
  final String name;  // 显示名称

  const BreadcrumbItem({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();
  @override
  List<Object?> get props => [];
}

class ServiceLoadRequested extends ServiceEvent {
  const ServiceLoadRequested();
}

class ServiceCategoryTapped extends ServiceEvent {
  final int categoryId;
  const ServiceCategoryTapped(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class ServiceBreadcrumbTapped extends ServiceEvent {
  final int index; // 面包屑索引
  const ServiceBreadcrumbTapped(this.index);
  @override
  List<Object?> get props => [index];
}

class ServiceSearchChanged extends ServiceEvent {
  final String keyword;
  const ServiceSearchChanged(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class ServiceAddedToCart extends ServiceEvent {
  final ServiceModel service;
  final int quantity;
  const ServiceAddedToCart({required this.service, this.quantity = 1});
  @override
  List<Object?> get props => [service, quantity];
}

class ServiceRemovedFromCart extends ServiceEvent {
  final int serviceId;
  final int quantity;
  const ServiceRemovedFromCart({required this.serviceId, this.quantity = 1});
  @override
  List<Object?> get props => [serviceId, quantity];
}

class ServiceCartCleared extends ServiceEvent {
  const ServiceCartCleared();
}

abstract class ServiceState extends Equatable {
  const ServiceState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final List<ServiceCategoryModel> allCategories;           // 所有分类
  final Map<int, List<ServiceCategoryModel>> categoryChildrenMap; // 分类ID -> 子分类列表
  final List<ServiceCategoryModel> currentCategories;      // 当前显示的分类列表
  final List<ServiceModel> currentServices;                // 当前显示的服务列表
  final List<BreadcrumbItem> breadcrumbs;                 // 面包屑
  final ServiceViewMode viewMode;                          // 当前视图模式
  final String searchKeyword;                               // 搜索关键词
  final List<CartItem> cartItems;
  final bool isLoadingServices;

  const ServiceLoaded({
    required this.allCategories,
    required this.categoryChildrenMap,
    required this.currentCategories,
    this.currentServices = const [],
    this.breadcrumbs = const [],
    this.viewMode = ServiceViewMode.category,
    this.searchKeyword = '',
    this.cartItems = const [],
    this.isLoadingServices = false,
  });

  int get cartTotalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  /// 当前分类ID（叶子节点的父分类）
  int? get currentCategoryId => breadcrumbs.isNotEmpty ? breadcrumbs.last.id : null;

  /// 当前分类名称（用于标题）
  String get currentCategoryName {
    if (breadcrumbs.isEmpty) return '全部';
    return breadcrumbs.last.name;
  }

  /// 是否在根级别（显示顶级分类）
  bool get isRootLevel => breadcrumbs.isEmpty || (breadcrumbs.length == 1 && breadcrumbs.first.id == 0);

  ServiceLoaded copyWith({
    List<ServiceCategoryModel>? allCategories,
    Map<int, List<ServiceCategoryModel>>? categoryChildrenMap,
    List<ServiceCategoryModel>? currentCategories,
    List<ServiceModel>? currentServices,
    List<BreadcrumbItem>? breadcrumbs,
    ServiceViewMode? viewMode,
    String? searchKeyword,
    List<CartItem>? cartItems,
    bool? isLoadingServices,
  }) {
    return ServiceLoaded(
      allCategories: allCategories ?? this.allCategories,
      categoryChildrenMap: categoryChildrenMap ?? this.categoryChildrenMap,
      currentCategories: currentCategories ?? this.currentCategories,
      currentServices: currentServices ?? this.currentServices,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      viewMode: viewMode ?? this.viewMode,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      cartItems: cartItems ?? this.cartItems,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
    );
  }

  @override
  List<Object?> get props => [
    allCategories,
    categoryChildrenMap,
    currentCategories,
    currentServices,
    breadcrumbs,
    viewMode,
    searchKeyword,
    cartItems,
    isLoadingServices,
  ];
}

class ServiceError extends ServiceState {
  final String message;
  const ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRemoteDataSource _dataSource;

  ServiceBloc({required ServiceRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ServiceInitial()) {
    on<ServiceLoadRequested>(_onLoadRequested);
    on<ServiceCategoryTapped>(_onCategoryTapped);
    on<ServiceBreadcrumbTapped>(_onBreadcrumbTapped);
    on<ServiceSearchChanged>(_onSearchChanged);
    on<ServiceAddedToCart>(_onServiceAdded);
    on<ServiceRemovedFromCart>(_onServiceRemoved);
    on<ServiceCartCleared>(_onCartCleared);
  }

  Future<void> _onLoadRequested(
    ServiceLoadRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());

    final result = await _dataSource.getServiceCategories();

    if (result.isFailure) {
      emit(ServiceError(result.failure!.message));
      return;
    }

    final categories = result.value!;

    // 构建分类树（parentId -> children）
    final childrenMap = <int, List<ServiceCategoryModel>>{};
    for (final cat in categories) {
      final parentId = cat.parentId ?? 0;
      if (parentId != 0) {
        childrenMap.putIfAbsent(parentId, () => []);
        childrenMap[parentId]!.add(cat);
      }
    }

    // 排序子分类
    for (final children in childrenMap.values) {
      children.sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));
    }

    // 获取顶级分类（parentId 为 null 或 0）
    final topLevelCategories = categories.where((c) => c.parentId == null || c.parentId == 0).toList()
      ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));

    emit(ServiceLoaded(
      allCategories: categories,
      categoryChildrenMap: childrenMap,
      currentCategories: topLevelCategories,
      breadcrumbs: const [BreadcrumbItem(id: 0, name: '全部')],
      viewMode: ServiceViewMode.category,
    ));
  }

  Future<void> _onCategoryTapped(
    ServiceCategoryTapped event,
    Emitter<ServiceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ServiceLoaded) return;

    // 查找分类信息
    final category = currentState.allCategories.firstWhere(
      (c) => c.id == event.categoryId,
      orElse: () => ServiceCategoryModel(id: event.categoryId, name: '未知分类'),
    );

    // 检查是否有子分类
    final children = currentState.categoryChildrenMap[event.categoryId] ?? [];

    if (children.isNotEmpty) {
      // 有子分类 -> 进入下一级分类
      final newBreadcrumbs = [
        ...currentState.breadcrumbs,
        BreadcrumbItem(id: category.id, name: category.name),
      ];

      emit(currentState.copyWith(
        currentCategories: children,
        currentServices: const [],
        breadcrumbs: newBreadcrumbs,
        viewMode: ServiceViewMode.category,
        isLoadingServices: false,
      ));
    } else {
      // 没有子分类 -> 显示服务列表
      final newBreadcrumbs = [
        ...currentState.breadcrumbs,
        BreadcrumbItem(id: category.id, name: category.name),
      ];

      emit(currentState.copyWith(
        currentCategories: const [],
        currentServices: const [],
        breadcrumbs: newBreadcrumbs,
        viewMode: ServiceViewMode.service,
        isLoadingServices: true,
      ));

      // 加载服务列表
      final serviceResult = await _dataSource.getServeList(cateID: event.categoryId);

      final newState = state;
      if (newState is ServiceLoaded) {
        emit(newState.copyWith(
          currentServices: serviceResult.value ?? [],
          isLoadingServices: false,
        ));
      }
    }
  }

  Future<void> _onBreadcrumbTapped(
    ServiceBreadcrumbTapped event,
    Emitter<ServiceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ServiceLoaded) return;

    if (event.index < 0 || event.index >= currentState.breadcrumbs.length) return;

    final newBreadcrumbs = currentState.breadcrumbs.sublist(0, event.index + 1);
    final tappedBreadcrumb = newBreadcrumbs.last;

    if (tappedBreadcrumb.id == 0) {
      // 点击"全部" -> 显示顶级分类
      final topLevelCategories = currentState.allCategories
          .where((c) => c.parentId == null || c.parentId == 0)
          .toList()
        ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));

      emit(currentState.copyWith(
        currentCategories: topLevelCategories,
        currentServices: const [],
        breadcrumbs: newBreadcrumbs,
        viewMode: ServiceViewMode.category,
        isLoadingServices: false,
      ));
    } else {
      // 点击中间面包屑 -> 显示该分类的子分类
      final children = currentState.categoryChildrenMap[tappedBreadcrumb.id] ?? [];

      if (children.isNotEmpty) {
        // 有子分类 -> 显示子分类列表
        emit(currentState.copyWith(
          currentCategories: children,
          currentServices: const [],
          breadcrumbs: newBreadcrumbs,
          viewMode: ServiceViewMode.category,
          isLoadingServices: false,
        ));
      } else {
        // 没有子分类 -> 加载服务列表
        emit(currentState.copyWith(
          currentCategories: const [],
          currentServices: const [],
          breadcrumbs: newBreadcrumbs,
          viewMode: ServiceViewMode.service,
          isLoadingServices: true,
        ));

        final serviceResult = await _dataSource.getServeList(cateID: tappedBreadcrumb.id);

        final newState = state;
        if (newState is ServiceLoaded) {
          emit(newState.copyWith(
            currentServices: serviceResult.value ?? [],
            isLoadingServices: false,
          ));
        }
      }
    }
  }

  Future<void> _onSearchChanged(
    ServiceSearchChanged event,
    Emitter<ServiceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ServiceLoaded) return;

    if (event.keyword.isEmpty) {
      // 清空搜索 -> 返回分类浏览模式
      final topLevelCategories = currentState.allCategories
          .where((c) => c.parentId == null || c.parentId == 0)
          .toList()
        ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));

      emit(currentState.copyWith(
        currentCategories: topLevelCategories,
        currentServices: const [],
        breadcrumbs: const [BreadcrumbItem(id: 0, name: '全部')],
        viewMode: ServiceViewMode.category,
        searchKeyword: '',
        isLoadingServices: false,
      ));
      return;
    }

    // 搜索模式
    emit(currentState.copyWith(
      currentCategories: const [],
      currentServices: const [],
      breadcrumbs: const [],
      viewMode: ServiceViewMode.search,
      searchKeyword: event.keyword,
      isLoadingServices: true,
    ));

    // 搜索服务
    final serviceResult = await _dataSource.getServeList(keyWord: event.keyword);

    final newState = state;
    if (newState is ServiceLoaded) {
      emit(newState.copyWith(
        currentServices: serviceResult.value ?? [],
        isLoadingServices: false,
      ));
    }
  }

  void _onServiceAdded(
    ServiceAddedToCart event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceLoaded) {
      final existingIndex = currentState.cartItems.indexWhere(
        (item) => item.id == event.service.id && item.type == CartItemType.service,
      );
      List<CartItem> updatedCart;
      if (existingIndex >= 0) {
        updatedCart = List<CartItem>.from(currentState.cartItems);
        final existing = updatedCart[existingIndex];
        updatedCart[existingIndex] = existing.copyWith(
          quantity: existing.quantity + event.quantity,
        );
      } else {
        updatedCart = List<CartItem>.from(currentState.cartItems)
          ..add(CartItem.fromService(event.service, quantity: event.quantity));
      }
      emit(currentState.copyWith(cartItems: updatedCart));
    }
  }

  void _onServiceRemoved(
    ServiceRemovedFromCart event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceLoaded) {
      final existingIndex = currentState.cartItems.indexWhere(
        (item) => item.id == event.serviceId && item.type == CartItemType.service,
      );
      if (existingIndex < 0) return;

      final existing = currentState.cartItems[existingIndex];
      List<CartItem> updatedCart;
      if (existing.quantity <= event.quantity) {
        updatedCart = List<CartItem>.from(currentState.cartItems)
          ..removeAt(existingIndex);
      } else {
        updatedCart = List<CartItem>.from(currentState.cartItems);
        updatedCart[existingIndex] = existing.copyWith(
          quantity: existing.quantity - event.quantity,
        );
      }
      emit(currentState.copyWith(cartItems: updatedCart));
    }
  }

  void _onCartCleared(
    ServiceCartCleared event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceLoaded) {
      emit(currentState.copyWith(cartItems: []));
    }
  }
}
