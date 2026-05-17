import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/order_detail_remote_datasource.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_product_model.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();
  @override
  List<Object?> get props => [];
}

class OrderDetailLoadRequested extends OrderDetailEvent {
  final String orderNumber;
  const OrderDetailLoadRequested(this.orderNumber);
  @override
  List<Object?> get props => [orderNumber];
}

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();
  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final OrderModel order;
  final List<OrderProductModel> products;
  final int totalQuantity;

  const OrderDetailLoaded({
    required this.order,
    required this.products,
    required this.totalQuantity,
  });

  @override
  List<Object?> get props => [order, products, totalQuantity];
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderDetailRemoteDataSource _dataSource;

  OrderDetailBloc({required OrderDetailRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const OrderDetailInitial()) {
    on<OrderDetailLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    OrderDetailLoadRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(const OrderDetailLoading());

    final orderResult = await _dataSource.getOrderByNumber(event.orderNumber);

    if (orderResult.isFailure) {
      emit(OrderDetailError(orderResult.failure!.message));
      return;
    }

    final order = orderResult.value!;
    final productsResult = await _dataSource.getOrderProducts(order.id);

    if (productsResult.isFailure) {
      emit(OrderDetailError(productsResult.failure!.message));
      return;
    }

    final products = productsResult.value!;
    final totalQuantity = products.fold(0, (sum, p) => sum + p.quantity);

    emit(OrderDetailLoaded(
      order: order,
      products: products,
      totalQuantity: totalQuantity,
    ));
  }
}