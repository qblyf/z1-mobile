import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../data/models/service_model.dart';
import '../../data/models/cart_item_model.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();
  @override
  List<Object?> get props => [];
}

class ServiceLoadRequested extends ServiceEvent {
  const ServiceLoadRequested();
}

class ServiceCategoryChanged extends ServiceEvent {
  final String? category;
  const ServiceCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
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
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final List<ServiceCategoryModel> categories;
  final String? currentCategory;
  final String searchKeyword;
  final List<CartItem> cartItems;

  const ServiceLoaded({
    required this.services,
    required this.filteredServices,
    this.categories = const [],
    this.currentCategory,
    this.searchKeyword = '',
    this.cartItems = const [],
  });

  int get cartTotalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  ServiceLoaded copyWith({
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    List<ServiceCategoryModel>? categories,
    String? currentCategory,
    String? searchKeyword,
    List<CartItem>? cartItems,
  }) {
    return ServiceLoaded(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      categories: categories ?? this.categories,
      currentCategory: currentCategory ?? this.currentCategory,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  @override
  List<Object?> get props => [services, filteredServices, categories, currentCategory, searchKeyword, cartItems];
}

class ServiceError extends ServiceState {
  final String message;
  const ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRemoteDataSource _remoteDataSource;
  final LocalServiceDataSource _localDataSource;

  ServiceBloc({
    required ServiceRemoteDataSource dataSource,
    required LocalServiceDataSource localDataSource,
  })  : _remoteDataSource = dataSource,
        _localDataSource = localDataSource,
        super(const ServiceInitial()) {
    on<ServiceLoadRequested>(_onLoadRequested);
    on<ServiceCategoryChanged>(_onCategoryChanged);
    on<ServiceSearchChanged>(_onSearchChanged);
    on<ServiceAddedToCart>(_onServiceAdded);
    on<ServiceRemovedFromCart>(_onServiceRemoved);
    on<ServiceCartCleared>(_onCartCleared);
  }

  Future<void> _onLoadRequested(
    ServiceLoadRequested event,
    Emitter<ServiceState> emit,
  ) async {
    // 优先使用缓存
    final cachedData = _localDataSource.getServiceSelectBaseCache();
    if (cachedData != null && _localDataSource.isCacheValid()) {
      emit(ServiceLoaded(
        services: cachedData.services,
        filteredServices: cachedData.services,
        categories: cachedData.categories,
      ));
      return;
    }

    // 缓存无效或不存在，从远程加载
    emit(const ServiceLoading());

    final result = await _remoteDataSource.getServiceSelectBase();

    if (result.isFailure) {
      // 远程加载失败，尝试使用过期缓存
      final staleCache = _localDataSource.getServiceSelectBaseCache();
      if (staleCache != null) {
        emit(ServiceLoaded(
          services: staleCache.services,
          filteredServices: staleCache.services,
          categories: staleCache.categories,
        ));
        return;
      }
      emit(ServiceError(result.failure!.message));
      return;
    }

    final data = result.value!;
    // 缓存成功的数据
    await _localDataSource.cacheServiceSelectBase(data);
    emit(ServiceLoaded(
      services: data.services,
      filteredServices: data.services,
      categories: data.categories,
    ));
  }

  void _onCategoryChanged(
    ServiceCategoryChanged event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceLoaded) {
      final filtered = _filterServices(
        currentState.services,
        event.category,
        currentState.searchKeyword,
      );
      emit(currentState.copyWith(
        filteredServices: filtered,
        currentCategory: event.category,
      ));
    }
  }

  void _onSearchChanged(
    ServiceSearchChanged event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceLoaded) {
      final filtered = _filterServices(
        currentState.services,
        currentState.currentCategory,
        event.keyword,
      );
      emit(currentState.copyWith(
        filteredServices: filtered,
        searchKeyword: event.keyword,
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

  List<ServiceModel> _filterServices(
    List<ServiceModel> services,
    String? category,
    String keyword,
  ) {
    return services.where((s) {
      final matchCategory = category == null || category == '全部' || s.categoryName == category;
      final matchKeyword = keyword.isEmpty ||
          s.name.toLowerCase().contains(keyword.toLowerCase()) ||
          (s.shortName?.toLowerCase().contains(keyword.toLowerCase()) ?? false);
      return matchCategory && matchKeyword;
    }).toList();
  }
}