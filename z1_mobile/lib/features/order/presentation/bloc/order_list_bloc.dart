import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/order_list_remote_datasource.dart';
import '../../data/models/order_model.dart';

abstract class OrderListEvent extends Equatable {
  const OrderListEvent();
  @override
  List<Object?> get props => [];
}

class OrderListLoadRequested extends OrderListEvent {
  final DateRange dateRange;
  const OrderListLoadRequested({this.dateRange = DateRange.today});
  @override
  List<Object?> get props => [dateRange];
}

class OrderListLoadMoreRequested extends OrderListEvent {
  const OrderListLoadMoreRequested();
}

class OrderListRefreshRequested extends OrderListEvent {
  const OrderListRefreshRequested();
}

class OrderListDateRangeChanged extends OrderListEvent {
  final DateRange dateRange;
  const OrderListDateRangeChanged(this.dateRange);
  @override
  List<Object?> get props => [dateRange];
}

abstract class OrderListState extends Equatable {
  const OrderListState();
  @override
  List<Object?> get props => [];
}

class OrderListInitial extends OrderListState {
  const OrderListInitial();
}

class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

class OrderListLoaded extends OrderListState {
  final List<OrderModel> orders;
  final DateRange dateRange;
  final bool hasReachedMax;
  final int currentPage;

  const OrderListLoaded({
    required this.orders,
    required this.dateRange,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  OrderListLoaded copyWith({
    List<OrderModel>? orders,
    DateRange? dateRange,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return OrderListLoaded(
      orders: orders ?? this.orders,
      dateRange: dateRange ?? this.dateRange,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [orders, dateRange, hasReachedMax, currentPage];
}

class OrderListError extends OrderListState {
  final String message;
  const OrderListError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderListLoadingMore extends OrderListState {
  final List<OrderModel> orders;
  final DateRange dateRange;
  final int currentPage;

  const OrderListLoadingMore({
    required this.orders,
    required this.dateRange,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [orders, dateRange, currentPage];
}

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final OrderListRemoteDataSource _dataSource;

  OrderListBloc({required OrderListRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const OrderListInitial()) {
    on<OrderListLoadRequested>(_onLoadRequested);
    on<OrderListLoadMoreRequested>(_onLoadMoreRequested);
    on<OrderListRefreshRequested>(_onRefreshRequested);
    on<OrderListDateRangeChanged>(_onDateRangeChanged);
  }

  Future<void> _onLoadRequested(
    OrderListLoadRequested event,
    Emitter<OrderListState> emit,
  ) async {
    emit(const OrderListLoading());

    final params = OrderListParams(
      page: 1,
      pageSize: 20,
      dateRange: event.dateRange,
    );

    final result = await _dataSource.getOrderList(params);

    if (result.isFailure) {
      emit(OrderListError(result.failure!.message));
      return;
    }

    final orders = result.value!;
    emit(OrderListLoaded(
      orders: orders,
      dateRange: event.dateRange,
      hasReachedMax: orders.length < 20,
      currentPage: 1,
    ));
  }

  Future<void> _onLoadMoreRequested(
    OrderListLoadMoreRequested event,
    Emitter<OrderListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrderListLoaded && currentState is! OrderListLoadingMore) {
      return;
    }

    final orders = currentState is OrderListLoaded
        ? currentState.orders
        : (currentState as OrderListLoadingMore).orders;
    final dateRange = currentState is OrderListLoaded
        ? currentState.dateRange
        : (currentState as OrderListLoadingMore).dateRange;
    final currentPage = currentState is OrderListLoaded
        ? currentState.currentPage
        : (currentState as OrderListLoadingMore).currentPage;

    if (currentState is OrderListLoaded && currentState.hasReachedMax) {
      return;
    }
    if (currentState is OrderListLoadingMore) {
      return;
    }

    emit(OrderListLoadingMore(
      orders: orders,
      dateRange: dateRange,
      currentPage: currentPage,
    ));

    final params = OrderListParams(
      page: currentPage + 1,
      pageSize: 20,
      dateRange: dateRange,
    );

    final result = await _dataSource.getOrderList(params);

    if (result.isFailure) {
      emit(OrderListLoaded(
        orders: orders,
        dateRange: dateRange,
        hasReachedMax: false,
        currentPage: currentPage,
      ));
      return;
    }

    final newOrders = result.value!;
    emit(OrderListLoaded(
      orders: [...orders, ...newOrders],
      dateRange: dateRange,
      hasReachedMax: newOrders.length < 20,
      currentPage: currentPage + 1,
    ));
  }

Future<void> _onRefreshRequested(
    OrderListRefreshRequested event,
    Emitter<OrderListState> emit,
  ) async {
    final currentState = state;
    final dateRange = currentState is OrderListLoaded
        ? currentState.dateRange
        : currentState is OrderListLoadingMore
            ? currentState.dateRange
            : DateRange.today;
    await _loadOrders(emit, 1, 20, dateRange);
  }

  Future<void> _onDateRangeChanged(
    OrderListDateRangeChanged event,
    Emitter<OrderListState> emit,
  ) async {
    await _loadOrders(emit, 1, 20, event.dateRange);
  }

  Future<void> _loadOrders(
    Emitter<OrderListState> emit,
    int page,
    int pageSize,
    DateRange dateRange,
  ) async {
    emit(const OrderListLoading());

    final params = OrderListParams(
      page: page,
      pageSize: pageSize,
      dateRange: dateRange,
    );

    final result = await _dataSource.getOrderList(params);

    if (result.isFailure) {
      emit(OrderListError(result.failure!.message));
      return;
    }

    final orders = result.value!;
    emit(OrderListLoaded(
      orders: orders,
      dateRange: dateRange,
      hasReachedMax: orders.length < pageSize,
      currentPage: page,
    ));
  }
}