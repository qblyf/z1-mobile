import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/recycle_order_remote_datasource.dart';
import '../../data/models/recycle_order_model.dart';

/// 回收单事件
abstract class RecycleOrderEvent extends Equatable {
  const RecycleOrderEvent();
  @override
  List<Object?> get props => [];
}

/// 加载可绑定回收单列表
class RecycleOrderLoadRequested extends RecycleOrderEvent {
  const RecycleOrderLoadRequested();
}

/// 切换选择
class RecycleOrderSelectionToggled extends RecycleOrderEvent {
  final RecycleOrderModel order;
  const RecycleOrderSelectionToggled(this.order);
  @override
  List<Object?> get props => [order];
}

/// 确认选择
class RecycleOrderConfirmSelection extends RecycleOrderEvent {
  const RecycleOrderConfirmSelection();
}

/// 回收单状态
abstract class RecycleOrderState extends Equatable {
  const RecycleOrderState();
  @override
  List<Object?> get props => [];
}

class RecycleOrderInitial extends RecycleOrderState {
  const RecycleOrderInitial();
}

class RecycleOrderLoading extends RecycleOrderState {
  const RecycleOrderLoading();
}

class RecycleOrderLoaded extends RecycleOrderState {
  final List<RecycleOrderModel> orders;
  final RecycleOrderModel? selectedOrder;

  const RecycleOrderLoaded({
    required this.orders,
    this.selectedOrder,
  });

  /// 可绑定的回收单（未过期且状态正确）
  List<RecycleOrderModel> get bindableOrders =>
      orders.where((o) => o.canBind).toList();

  /// 总补贴金额
  int get totalSubsidyAmount {
    if (selectedOrder == null) return 0;
    return selectedOrder!.subsidyAmount;
  }

  RecycleOrderLoaded copyWith({
    List<RecycleOrderModel>? orders,
    RecycleOrderModel? selectedOrder,
    bool clearSelection = false,
  }) {
    return RecycleOrderLoaded(
      orders: orders ?? this.orders,
      selectedOrder: clearSelection ? null : (selectedOrder ?? this.selectedOrder),
    );
  }

  @override
  List<Object?> get props => [orders, selectedOrder];
}

class RecycleOrderError extends RecycleOrderState {
  final String message;
  const RecycleOrderError(this.message);
  @override
  List<Object?> get props => [message];
}

/// 回收单 BLoC
class RecycleOrderBloc extends Bloc<RecycleOrderEvent, RecycleOrderState> {
  final RecycleOrderRemoteDataSource _dataSource;

  RecycleOrderBloc({required RecycleOrderRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const RecycleOrderInitial()) {
    on<RecycleOrderLoadRequested>(_onLoadRequested);
    on<RecycleOrderSelectionToggled>(_onSelectionToggled);
  }

  Future<void> _onLoadRequested(
    RecycleOrderLoadRequested event,
    Emitter<RecycleOrderState> emit,
  ) async {
    emit(const RecycleOrderLoading());

    final result = await _dataSource.getAllowBindList();

    if (result.isFailure) {
      emit(RecycleOrderError(result.failure!.message));
      return;
    }

    final orders = result.value!;
    emit(RecycleOrderLoaded(orders: orders));
  }

  void _onSelectionToggled(
    RecycleOrderSelectionToggled event,
    Emitter<RecycleOrderState> emit,
  ) {
    final currentState = state;
    if (currentState is! RecycleOrderLoaded) return;

    final selectedOrder = currentState.selectedOrder;

    // 如果已选择当前订单，则取消选择；否则选择新订单
    if (selectedOrder != null && selectedOrder.id == event.order.id) {
      emit(currentState.copyWith(clearSelection: true));
    } else {
      emit(currentState.copyWith(selectedOrder: event.order));
    }
  }
}
