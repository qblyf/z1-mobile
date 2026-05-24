import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';

/// 分类面板状态枚举
/// 用于描述左侧分类面板的当前层级
enum CategoryPanelState {
  loading, // 加载中
  topLevel, // 显示顶级分类（第1级：品类）
  secondLevel, // 显示第2级分类（品牌）
  thirdLevel, // 显示第3级分类（系列/叶子节点）
}

abstract class ProductSelectEvent extends Equatable {
  const ProductSelectEvent();
  @override
  List<Object?> get props => [];
}

class ProductSelectLoadRequested extends ProductSelectEvent {
  const ProductSelectLoadRequested();
}

class ProductSelectCategoryTapped extends ProductSelectEvent {
  final int categoryId;
  const ProductSelectCategoryTapped(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class ProductSelectBackPressed extends ProductSelectEvent {
  const ProductSelectBackPressed();
}

class ProductSelectSpuSelected extends ProductSelectEvent {
  final SpuModel spu;
  const ProductSelectSpuSelected(this.spu);
  @override
  List<Object?> get props => [spu];
}

class ProductSelectSkuAdded extends ProductSelectEvent {
  final SkuModel sku;
  final int quantity;
  const ProductSelectSkuAdded({required this.sku, this.quantity = 1});
  @override
  List<Object?> get props => [sku, quantity];
}

class ProductSelectSearchChanged extends ProductSelectEvent {
  final String keyword;
  const ProductSelectSearchChanged(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class ProductSelectClearCart extends ProductSelectEvent {
  const ProductSelectClearCart();
}

class CartSkuItem extends Equatable {
  final SkuModel sku;
  final int quantity;

  const CartSkuItem({required this.sku, this.quantity = 1});

  int get subtotal => sku.price * quantity;

  CartSkuItem copyWith({SkuModel? sku, int? quantity}) {
    return CartSkuItem(
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [sku, quantity];
}

abstract class ProductSelectState extends Equatable {
  const ProductSelectState();
  @override
  List<Object?> get props => [];
}

class ProductSelectInitial extends ProductSelectState {
  const ProductSelectInitial();
}

class ProductSelectLoading extends ProductSelectState {
  const ProductSelectLoading();
}

class ProductSelectError extends ProductSelectState {
  final String message;
  const ProductSelectError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductSelectLoaded extends ProductSelectState {
  final List<CategoryModel> allCategories;
  final Map<int, List<CategoryModel>> categoryChildrenMap;
  final List<CategoryModel> currentSidebarCategories;
  final List<SpuModel> currentSpus;
  final List<CartSkuItem> cartItems;
  final List<int> navigationStack;
  final String searchKeyword;
  final SpuModel? selectedSpu;
  final bool isLoadingSpus;

  const ProductSelectLoaded({
    required this.allCategories,
    required this.categoryChildrenMap,
    required this.currentSidebarCategories,
    this.currentSpus = const [],
    this.cartItems = const [],
    this.navigationStack = const [],
    this.searchKeyword = '',
    this.selectedSpu,
    this.isLoadingSpus = false,
  });

  int get cartTotalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  bool get canGoBack => navigationStack.isNotEmpty;

  List<CategoryModel> get currentPathCategories {
    return navigationStack.map((id) {
      return allCategories.firstWhere(
        (c) => c.id == id,
        orElse: () => CategoryModel(id: id, name: ''),
      );
    }).toList();
  }

  String get breadcrumbTitle {
    if (navigationStack.isEmpty) {
      return '全部商品';
    }
    final path = currentPathCategories;
    return path.map((c) => c.name).join(' · ');
  }

  int? get currentCategoryId => navigationStack.isNotEmpty ? navigationStack.last : null;

  ProductSelectLoaded copyWith({
    List<CategoryModel>? allCategories,
    Map<int, List<CategoryModel>>? categoryChildrenMap,
    List<CategoryModel>? currentSidebarCategories,
    List<SpuModel>? currentSpus,
    List<CartSkuItem>? cartItems,
    List<int>? navigationStack,
    String? searchKeyword,
    SpuModel? selectedSpu,
    bool? isLoadingSpus,
  }) {
    return ProductSelectLoaded(
      allCategories: allCategories ?? this.allCategories,
      categoryChildrenMap: categoryChildrenMap ?? this.categoryChildrenMap,
      currentSidebarCategories: currentSidebarCategories ?? this.currentSidebarCategories,
      currentSpus: currentSpus ?? this.currentSpus,
      cartItems: cartItems ?? this.cartItems,
      navigationStack: navigationStack ?? this.navigationStack,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      selectedSpu: selectedSpu,
      isLoadingSpus: isLoadingSpus ?? this.isLoadingSpus,
    );
  }

  @override
  List<Object?> get props => [
    allCategories,
    categoryChildrenMap,
    currentSidebarCategories,
    currentSpus,
    cartItems,
    navigationStack,
    searchKeyword,
    selectedSpu,
    isLoadingSpus,
  ];
}

class ProductSelectBloc extends Bloc<ProductSelectEvent, ProductSelectState> {
  final ProductRemoteDataSource _dataSource;

  ProductSelectBloc({required ProductRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProductSelectInitial()) {
    on<ProductSelectLoadRequested>(_onLoadRequested);
    on<ProductSelectCategoryTapped>(_onCategoryTapped);
    on<ProductSelectBackPressed>(_onBackPressed);
    on<ProductSelectSpuSelected>(_onSpuSelected);
    on<ProductSelectSkuAdded>(_onSkuAdded);
    on<ProductSelectSearchChanged>(_onSearchChanged);
    on<ProductSelectClearCart>(_onClearCart);
  }

  Future<void> _onLoadRequested(
    ProductSelectLoadRequested event,
    Emitter<ProductSelectState> emit,
  ) async {
    emit(const ProductSelectLoading());

    final result = await _dataSource.getCategoryList(type: 1);

    if (result.isFailure) {
      emit(ProductSelectError(result.failure!.message));
      return;
    }

    final categories = result.value!;

    final topLevelCategories = categories.where((c) => c.pid == 0 || c.pid == null).toList()
      ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));

    final childrenMap = <int, List<CategoryModel>>{};
    for (final cat in categories) {
      final pid = cat.pid ?? 0;
      if (pid != 0) {
        childrenMap.putIfAbsent(pid, () => []);
        childrenMap[pid]!.add(cat);
      }
    }

    for (final children in childrenMap.values) {
      children.sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));
    }

    emit(ProductSelectLoaded(
      allCategories: categories,
      categoryChildrenMap: childrenMap,
      currentSidebarCategories: topLevelCategories,
      currentSpus: const [],
      navigationStack: const [],
    ));
  }

  Future<void> _onCategoryTapped(
    ProductSelectCategoryTapped event,
    Emitter<ProductSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductSelectLoaded) return;

    final categoryId = event.categoryId;
    final children = currentState.categoryChildrenMap[categoryId] ?? [];
    final hasChildren = children.isNotEmpty;

    final newStack = [...currentState.navigationStack, categoryId];
    final newSidebarCategories = hasChildren ? children : currentState.currentSidebarCategories;

    emit(currentState.copyWith(
      currentSidebarCategories: newSidebarCategories,
      navigationStack: newStack,
      isLoadingSpus: true,
    ));

    if (!hasChildren) {
      final spuResult = await _dataSource.getSpuListByCategory(categoryId);

      if (spuResult.isSuccess) {
        final newState = state;
        if (newState is ProductSelectLoaded) {
          emit(newState.copyWith(
            currentSpus: spuResult.value!,
            isLoadingSpus: false,
          ));
        }
      } else {
        final newState = state;
        if (newState is ProductSelectLoaded) {
          emit(newState.copyWith(
            currentSpus: const [],
            isLoadingSpus: false,
          ));
        }
      }
    } else {
      final newState = state;
      if (newState is ProductSelectLoaded) {
        emit(newState.copyWith(isLoadingSpus: false));
      }
    }
  }

  void _onBackPressed(
    ProductSelectBackPressed event,
    Emitter<ProductSelectState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProductSelectLoaded) return;
    if (currentState.navigationStack.isEmpty) return;

    final newStack = [...currentState.navigationStack]..removeLast();

    List<CategoryModel> sidebarCategories;
    List<SpuModel> spus = currentState.currentSpus;

    if (newStack.isEmpty) {
      sidebarCategories = currentState.allCategories.where((c) => c.pid == 0 || c.pid == null).toList()
        ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));
      spus = const [];
    } else {
      final parentId = newStack.last;
      sidebarCategories = currentState.categoryChildrenMap[parentId] ?? [];

      if (sidebarCategories.isEmpty) {
        spus = const [];
      }
    }

    emit(currentState.copyWith(
      currentSidebarCategories: sidebarCategories,
      navigationStack: newStack,
      currentSpus: spus,
    ));
  }

  void _onSpuSelected(
    ProductSelectSpuSelected event,
    Emitter<ProductSelectState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductSelectLoaded) {
      emit(currentState.copyWith(selectedSpu: event.spu));
    }
  }

  void _onSkuAdded(
    ProductSelectSkuAdded event,
    Emitter<ProductSelectState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductSelectLoaded) {
      final existingIndex = currentState.cartItems.indexWhere((item) => item.sku.skuId == event.sku.skuId);
      List<CartSkuItem> updatedCart;
      if (existingIndex >= 0) {
        updatedCart = List<CartSkuItem>.from(currentState.cartItems);
        updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
          quantity: updatedCart[existingIndex].quantity + event.quantity,
        );
      } else {
        updatedCart = List<CartSkuItem>.from(currentState.cartItems)
          ..add(CartSkuItem(sku: event.sku, quantity: event.quantity));
      }
      emit(currentState.copyWith(cartItems: updatedCart));
    }
  }

  void _onSearchChanged(
    ProductSelectSearchChanged event,
    Emitter<ProductSelectState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductSelectLoaded) {
      emit(currentState.copyWith(searchKeyword: event.keyword));
    }
  }

  void _onClearCart(
    ProductSelectClearCart event,
    Emitter<ProductSelectState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductSelectLoaded) {
      emit(currentState.copyWith(cartItems: const []));
    }
  }
}