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

class ProductGenreChanged extends ProductEvent {
  final String? genre;
  const ProductGenreChanged(this.genre);
  @override
  List<Object?> get props => [genre];
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
  final List<CategoryModel> categories;
  final String? currentCategory;
  final String? currentGenre;
  final String? searchKeyword;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    this.categories = const [],
    this.currentCategory,
    this.currentGenre,
    this.searchKeyword,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<CategoryModel>? categories,
    String? currentCategory,
    String? currentGenre,
    String? searchKeyword,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      currentCategory: currentCategory ?? this.currentCategory,
      currentGenre: currentGenre ?? this.currentGenre,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  @override
  List<Object?> get props => [products, filteredProducts, categories, currentCategory, currentGenre, searchKeyword];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductSearching extends ProductState {
  final List<ProductModel> allProducts;
  final List<CategoryModel> categories;
  final String? currentGenre;

  const ProductSearching(this.allProducts, {this.categories = const [], this.currentGenre});

  @override
  List<Object?> get props => [allProducts, categories, currentGenre];
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDataSource _dataSource;

  ProductBloc({required ProductRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductSearchRequested>(_onSearchRequested);
    on<ProductCategoryChanged>(_onCategoryChanged);
    on<ProductGenreChanged>(_onGenreChanged);
    on<ProductSearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _dataSource.getProductSelectBase();

    if (result.isFailure) {
      emit(ProductError(result.failure!.message));
      return;
    }

    final data = result.value!;
    emit(ProductLoaded(
      products: data.products,
      filteredProducts: data.products,
      categories: data.categories,
    ));
  }

  Future<void> _onSearchRequested(
    ProductSearchRequested event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    List<ProductModel> allProducts = [];
    List<CategoryModel> categories = [];
    String? currentCategory;
    String? currentGenre;

    if (currentState is ProductLoaded) {
      allProducts = currentState.products;
      categories = currentState.categories;
      currentCategory = currentState.currentCategory;
      currentGenre = currentState.currentGenre;
    } else if (currentState is ProductSearching) {
      allProducts = currentState.allProducts;
      categories = currentState.categories;
      currentGenre = currentState.currentGenre;
    }

    if (event.keyword.isEmpty) {
      final filtered = _filterProducts(allProducts, null, currentCategory, currentGenre);
      emit(ProductLoaded(
        products: allProducts,
        filteredProducts: filtered,
        categories: categories,
        currentCategory: currentCategory,
        currentGenre: currentGenre,
        searchKeyword: null,
      ));
      return;
    }

    emit(ProductSearching(allProducts, categories: categories, currentGenre: currentGenre));

    final result = await _dataSource.searchProducts(event.keyword);

    if (result.isFailure) {
      emit(ProductLoaded(
        products: allProducts,
        filteredProducts: _filterProducts(allProducts, null, currentCategory, currentGenre),
        categories: categories,
        currentCategory: currentCategory,
        currentGenre: currentGenre,
      ));
      return;
    }

    final searchResults = result.value!;
    final filtered = _filterProducts(searchResults, event.keyword, currentCategory, currentGenre);

    emit(ProductLoaded(
      products: allProducts,
      filteredProducts: filtered,
      categories: categories,
      currentCategory: currentCategory,
      currentGenre: currentGenre,
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
        currentState.currentGenre,
      );
      emit(currentState.copyWith(
        filteredProducts: filtered,
        currentCategory: event.category == '全部' ? null : event.category,
      ));
    }
  }

  void _onGenreChanged(
    ProductGenreChanged event,
    Emitter<ProductState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      final filtered = _filterProducts(
        currentState.products,
        currentState.searchKeyword,
        null,
        event.genre,
      );
      emit(currentState.copyWith(
        filteredProducts: filtered,
        currentGenre: event.genre,
        currentCategory: null,
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
        currentState.currentGenre,
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
    String? genre,
  ) {
    return products.where((p) {
      final matchKeyword = keyword == null ||
          keyword.isEmpty ||
          p.productName.contains(keyword) ||
          (p.code?.contains(keyword) ?? false) ||
          (p.barcode?.contains(keyword) ?? false);
      final matchCategory = category == null || p.category == category;
      final matchGenre = genre == null || p.genre == genre;
      return matchKeyword && matchCategory && matchGenre;
    }).toList();
  }
}