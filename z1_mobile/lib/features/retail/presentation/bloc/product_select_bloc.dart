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

class ProductSelectCategoryChanged extends ProductSelectEvent {
  final int categoryIndex;
  const ProductSelectCategoryChanged(this.categoryIndex);
  @override
  List<Object?> get props => [categoryIndex];
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

class ProductSelectLoaded extends ProductSelectState {
  final List<CategoryWithSpu> categories;
  final List<CategoryWithSpu> filteredCategories;
  final List<CartSkuItem> cartItems;
  final int selectedCategoryIndex;
  final SpuModel? selectedSpu;
  final String searchKeyword;

  const ProductSelectLoaded({
    required this.categories,
    required this.filteredCategories,
    this.cartItems = const [],
    this.selectedCategoryIndex = 0,
    this.selectedSpu,
    this.searchKeyword = '',
  });

  int get cartTotalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  ProductSelectLoaded copyWith({
    List<CategoryWithSpu>? categories,
    List<CategoryWithSpu>? filteredCategories,
    List<CartSkuItem>? cartItems,
    int? selectedCategoryIndex,
    SpuModel? selectedSpu,
    String? searchKeyword,
  }) {
    return ProductSelectLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      cartItems: cartItems ?? this.cartItems,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedSpu: selectedSpu,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  @override
  List<Object?> get props => [categories, filteredCategories, cartItems, selectedCategoryIndex, selectedSpu, searchKeyword];
}

class ProductSelectError extends ProductSelectState {
  final String message;
  const ProductSelectError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductSelectBloc extends Bloc<ProductSelectEvent, ProductSelectState> {
  final ProductRemoteDataSource _dataSource;

  ProductSelectBloc({required ProductRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProductSelectInitial()) {
    on<ProductSelectLoadRequested>(_onLoadRequested);
    on<ProductSelectCategoryChanged>(_onCategoryChanged);
    on<ProductSelectSpuSelected>(_onSpuSelected);
    on<ProductSelectSkuAdded>(_onSkuAdded);
    on<ProductSelectSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadRequested(
    ProductSelectLoadRequested event,
    Emitter<ProductSelectState> emit,
  ) async {
    emit(const ProductSelectLoading());

    final result = await _dataSource.getSkuSelectBase();

    if (result.isFailure) {
      emit(ProductSelectError(result.failure!.message));
      return;
    }

    final data = result.value!;
    emit(ProductSelectLoaded(
      categories: data.categories,
      filteredCategories: data.categories,
    ));
  }

  void _onCategoryChanged(
    ProductSelectCategoryChanged event,
    Emitter<ProductSelectState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductSelectLoaded) {
      emit(currentState.copyWith(
        selectedCategoryIndex: event.categoryIndex,
        selectedSpu: null,
      ));
    }
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
      final keyword = event.keyword.toLowerCase();
      if (keyword.isEmpty) {
        emit(currentState.copyWith(
          filteredCategories: currentState.categories,
          searchKeyword: '',
        ));
      } else {
        final filtered = currentState.categories.map((cat) {
          final filteredSpus = cat.spus.where((spu) {
            return spu.spuName.toLowerCase().contains(keyword) ||
                spu.skus.any((sku) => sku.skuName.toLowerCase().contains(keyword));
          }).toList();
          return CategoryWithSpu(id: cat.id, name: cat.name, spus: filteredSpus);
        }).where((cat) => cat.spus.isNotEmpty).toList();

        emit(currentState.copyWith(
          filteredCategories: filtered,
          searchKeyword: keyword,
        ));
      }
    }
  }
}