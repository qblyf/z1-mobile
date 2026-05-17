import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  const ProductLoadRequested();
}

class ProductSearchRequested extends ProductEvent {
  final String keyword;
  const ProductSearchRequested(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class ProductCategoryChanged extends ProductEvent {
  final String category;
  const ProductCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class ProductSearchCleared extends ProductEvent {
  const ProductSearchCleared();
}

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final String? currentCategory;
  final String? searchKeyword;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    this.currentCategory,
    this.searchKeyword,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    String? currentCategory,
    String? searchKeyword,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      currentCategory: currentCategory ?? this.currentCategory,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  @override
  List<Object?> get props => [products, filteredProducts, currentCategory, searchKeyword];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductSearching extends ProductState {
  final List<ProductModel> allProducts;
  const ProductSearching(this.allProducts);
  @override
  List<Object?> get props => [allProducts];
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDataSource _dataSource;

  ProductBloc({required ProductRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductSearchRequested>(_onSearchRequested);
    on<ProductCategoryChanged>(_onCategoryChanged);
    on<ProductSearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _dataSource.getProductList(const ProductListParams());

    if (result.isFailure) {
      emit(ProductError(result.failure!.message));
      return;
    }

    final products = result.value!;
    emit(ProductLoaded(
      products: products,
      filteredProducts: products,
    ));
  }

  Future<void> _onSearchRequested(
    ProductSearchRequested event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    List<ProductModel> allProducts = [];
    String? currentCategory;

    if (currentState is ProductLoaded) {
      allProducts = currentState.products;
      currentCategory = currentState.currentCategory;
    }

    if (event.keyword.isEmpty) {
      final filtered = _filterProducts(allProducts, null, currentCategory);
      emit(ProductLoaded(
        products: allProducts,
        filteredProducts: filtered,
        currentCategory: currentCategory,
        searchKeyword: null,
      ));
      return;
    }

    emit(ProductSearching(allProducts));

    final result = await _dataSource.searchProducts(event.keyword);

    if (result.isFailure) {
      emit(ProductLoaded(
        products: allProducts,
        filteredProducts: _filterProducts(allProducts, null, currentCategory),
        currentCategory: currentCategory,
      ));
      return;
    }

    final searchResults = result.value!;
    final filtered = _filterProducts(searchResults, event.keyword, currentCategory);

    emit(ProductLoaded(
      products: allProducts,
      filteredProducts: filtered,
      currentCategory: currentCategory,
      searchKeyword: event.keyword,
    ));
  }

  void _onCategoryChanged(
    ProductCategoryChanged event,
    Emitter<ProductState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      final filtered = _filterProducts(
        currentState.products,
        currentState.searchKeyword,
        event.category == '全部' ? null : event.category,
      );
      emit(currentState.copyWith(
        filteredProducts: filtered,
        currentCategory: event.category == '全部' ? null : event.category,
      ));
    }
  }

  void _onSearchCleared(
    ProductSearchCleared event,
    Emitter<ProductState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      final filtered = _filterProducts(
        currentState.products,
        null,
        currentState.currentCategory,
      );
      emit(currentState.copyWith(
        filteredProducts: filtered,
        searchKeyword: null,
      ));
    }
  }

  List<ProductModel> _filterProducts(
    List<ProductModel> products,
    String? keyword,
    String? category,
  ) {
    return products.where((p) {
      final matchKeyword = keyword == null ||
          keyword.isEmpty ||
          p.productName.contains(keyword) ||
          (p.code?.contains(keyword) ?? false);
      final matchCategory = category == null ||
          p.category == category;
      return matchKeyword && matchCategory;
    }).toList();
  }
}