import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';

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

/// 直接加载指定分类的 SPU 列表（绕过子分类导航）
class ProductSelectCategorySpuRequested extends ProductSelectEvent {
  final int categoryId;
  const ProductSelectCategorySpuRequested(this.categoryId);
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

class ProductSelectSkuModalOpened extends ProductSelectEvent {
  /// 打开 SKU 弹窗时触发：获取 hasSerial 和库存
  final SpuModel spu;
  const ProductSelectSkuModalOpened(this.spu);
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
  final List<MallCategoryModel> allCategories;
  final Map<int, List<MallCategoryModel>> categoryChildrenMap;
  final List<MallCategoryModel> currentSidebarCategories;
  final List<SpuModel> currentSpus;
  final List<CartSkuItem> cartItems;
  final List<int> navigationStack;
  final String searchKeyword;
  final SpuModel? selectedSpu;
  final bool isLoadingSpus;
  /// SKU 弹窗内库存数据（SPU ID -> 库存值，null 表示加载中，-1 表示获取失败）
  final Map<int, int?> stockMap;

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
    this.stockMap = const {},
  });

  int get cartTotalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  bool get canGoBack => navigationStack.isNotEmpty;

  List<MallCategoryModel> get currentPathCategories {
    return navigationStack.map((id) {
      return allCategories.firstWhere(
        (c) => c.id == id,
        orElse: () => MallCategoryModel(id: id, title: '', level: 1),
      );
    }).toList();
  }

  String get breadcrumbTitle {
    if (navigationStack.isEmpty) {
      return '全部商品';
    }
    final path = currentPathCategories;
    return path.map((c) => c.title).join(' · ');
  }

  int? get currentCategoryId => navigationStack.isNotEmpty ? navigationStack.last : null;

  ProductSelectLoaded copyWith({
    List<MallCategoryModel>? allCategories,
    Map<int, List<MallCategoryModel>>? categoryChildrenMap,
    List<MallCategoryModel>? currentSidebarCategories,
    List<SpuModel>? currentSpus,
    List<CartSkuItem>? cartItems,
    List<int>? navigationStack,
    String? searchKeyword,
    SpuModel? selectedSpu,
    bool? isLoadingSpus,
    Map<int, int?>? stockMap,
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
      stockMap: stockMap ?? this.stockMap,
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
    stockMap,
  ];
}

class ProductSelectBloc extends Bloc<ProductSelectEvent, ProductSelectState> {
  final ProductRemoteDataSource _dataSource;

  ProductSelectBloc({required ProductRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProductSelectInitial()) {
    on<ProductSelectLoadRequested>(_onLoadRequested);
    on<ProductSelectCategoryTapped>(_onCategoryTapped);
    on<ProductSelectCategorySpuRequested>(_onCategorySpuRequested);
    on<ProductSelectBackPressed>(_onBackPressed);
    on<ProductSelectSpuSelected>(_onSpuSelected);
    on<ProductSelectSkuModalOpened>(_onSkuModalOpened);
    on<ProductSelectSkuAdded>(_onSkuAdded);
    on<ProductSelectSearchChanged>(_onSearchChanged);
    on<ProductSelectClearCart>(_onClearCart);
  }

  Future<void> _onLoadRequested(
    ProductSelectLoadRequested event,
    Emitter<ProductSelectState> emit,
  ) async {
    emit(const ProductSelectLoading());

    final result = await _dataSource.getMallCategoryList();

    if (result.isFailure) {
      emit(ProductSelectError(result.failure!.message));
      return;
    }

    final categories = result.value!;

    final topLevelCategories = categories.where((c) => c.level == 1).toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));

    final childrenMap = <int, List<MallCategoryModel>>{};
    for (final cat in categories) {
      final parentId = cat.pids.isNotEmpty ? cat.pids.last : 0;
      if (parentId != 0) {
        childrenMap.putIfAbsent(parentId, () => []);
        childrenMap[parentId]!.add(cat);
      }
    }

    for (final children in childrenMap.values) {
      children.sort((a, b) => b.weight.compareTo(a.weight));
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
      final spuResult = await _dataSource.getSpuListByMallCate(categoryId);

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

  /// 直接加载指定分类的 SPU 列表（绕过子分类导航）
  Future<void> _onCategorySpuRequested(
    ProductSelectCategorySpuRequested event,
    Emitter<ProductSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductSelectLoaded) return;

    final categoryId = event.categoryId;

    emit(currentState.copyWith(
      isLoadingSpus: true,
    ));

    final spuResult = await _dataSource.getSpuListByMallCate(categoryId);

    if (isClosed) return;
    final newState = state;
    if (newState is ProductSelectLoaded) {
      emit(newState.copyWith(
        currentSpus: spuResult.isSuccess ? spuResult.value! : const [],
        isLoadingSpus: false,
      ));
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

    List<MallCategoryModel> sidebarCategories;
    List<SpuModel> spus = currentState.currentSpus;

    if (newStack.isEmpty) {
      sidebarCategories = currentState.allCategories.where((c) => c.level == 1).toList()
        ..sort((a, b) => b.weight.compareTo(a.weight));
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

  /// 打开 SKU 弹窗时触发：获取 hasSerial 和库存数据
  Future<void> _onSkuModalOpened(
    ProductSelectSkuModalOpened event,
    Emitter<ProductSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductSelectLoaded) return;

    final spu = event.spu;
    final spuId = spu.spuId;

    // 并行获取 hasSerial 和库存
    final productFuture = _dataSource.getProductBySpuId(spuId);
    final stockFuture = _dataSource.getSpuStock(spuId);

    final productResult = await productFuture;
    final stockResult = await stockFuture;

    if (isClosed) return;
    final newState = state;
    if (newState is! ProductSelectLoaded) return;

    // 更新 stockMap
    final newStockMap = Map<int, int?>.from(newState.stockMap);
    if (stockResult.isSuccess) {
      newStockMap[spuId] = stockResult.value;
    } else {
      // 90000 错误或其他失败，标记为 -1（"获取失败"）
      newStockMap[spuId] = -1;
    }

    // 更新 hasSerial 到 SPU
    SpuModel? updatedSpu;
    if (productResult.isSuccess && productResult.value != null) {
      final product = productResult.value!;
      if (product.hasSerial != null) {
        final updatedSkus = spu.skus.map((sku) {
          return sku.copyWith(hasSerial: product.hasSerial);
        }).toList();
        updatedSpu = spu.copyWith(hasSerial: product.hasSerial, skus: updatedSkus);
      }
    }

    emit(newState.copyWith(
      selectedSpu: updatedSpu ?? newState.selectedSpu,
      stockMap: newStockMap,
    ));
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