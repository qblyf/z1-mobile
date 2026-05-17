import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/models/purchase_model.dart';

abstract class PurchaseInboundEvent extends Equatable {
  const PurchaseInboundEvent();
  @override
  List<Object?> get props => [];
}

class PurchaseInboundLoadRequested extends PurchaseInboundEvent {
  final int id;
  const PurchaseInboundLoadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class PurchaseInboundWarehouseSelected extends PurchaseInboundEvent {
  final WarehouseModel warehouse;
  const PurchaseInboundWarehouseSelected(this.warehouse);
  @override
  List<Object?> get props => [warehouse];
}

class PurchaseInboundProductCountUpdated extends PurchaseInboundEvent {
  final int productId;
  final int count;
  const PurchaseInboundProductCountUpdated({
    required this.productId,
    required this.count,
  });
  @override
  List<Object?> get props => [productId, count];
}

class PurchaseInboundRemarksChanged extends PurchaseInboundEvent {
  final String remarks;
  const PurchaseInboundRemarksChanged(this.remarks);
  @override
  List<Object?> get props => [remarks];
}

class PurchaseInboundSubmitRequested extends PurchaseInboundEvent {
  const PurchaseInboundSubmitRequested();
}

class PurchaseInboundWarehousesLoaded extends PurchaseInboundEvent {
  final List<WarehouseModel> warehouses;
  const PurchaseInboundWarehousesLoaded(this.warehouses);
  @override
  List<Object?> get props => [warehouses];
}

abstract class PurchaseInboundState extends Equatable {
  const PurchaseInboundState();
  @override
  List<Object?> get props => [];
}

class PurchaseInboundInitial extends PurchaseInboundState {
  const PurchaseInboundInitial();
}

class PurchaseInboundLoading extends PurchaseInboundState {
  const PurchaseInboundLoading();
}

class PurchaseInboundReady extends PurchaseInboundState {
  final PurchaseDetailModel purchase;
  final List<WarehouseModel> warehouses;
  final WarehouseModel? selectedWarehouse;
  final Map<int, int> productCounts;
  final String remarks;
  final bool isSubmitting;

  const PurchaseInboundReady({
    required this.purchase,
    required this.warehouses,
    this.selectedWarehouse,
    this.productCounts = const {},
    this.remarks = '',
    this.isSubmitting = false,
  });

  PurchaseInboundReady copyWith({
    PurchaseDetailModel? purchase,
    List<WarehouseModel>? warehouses,
    WarehouseModel? selectedWarehouse,
    Map<int, int>? productCounts,
    String? remarks,
    bool? isSubmitting,
  }) {
    return PurchaseInboundReady(
      purchase: purchase ?? this.purchase,
      warehouses: warehouses ?? this.warehouses,
      selectedWarehouse: selectedWarehouse ?? this.selectedWarehouse,
      productCounts: productCounts ?? this.productCounts,
      remarks: remarks ?? this.remarks,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        purchase,
        warehouses,
        selectedWarehouse,
        productCounts,
        remarks,
        isSubmitting,
      ];
}

class PurchaseInboundError extends PurchaseInboundState {
  final String message;
  const PurchaseInboundError(this.message);
  @override
  List<Object?> get props => [message];
}

class PurchaseInboundSuccess extends PurchaseInboundState {
  final String message;
  const PurchaseInboundSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PurchaseInboundBloc extends Bloc<PurchaseInboundEvent, PurchaseInboundState> {
  final PurchaseRemoteDataSource _dataSource;

  PurchaseInboundBloc({required PurchaseRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const PurchaseInboundInitial()) {
    on<PurchaseInboundLoadRequested>(_onLoadRequested);
    on<PurchaseInboundWarehouseSelected>(_onWarehouseSelected);
    on<PurchaseInboundProductCountUpdated>(_onProductCountUpdated);
    on<PurchaseInboundRemarksChanged>(_onRemarksChanged);
    on<PurchaseInboundSubmitRequested>(_onSubmitRequested);
    on<PurchaseInboundWarehousesLoaded>(_onWarehousesLoaded);
  }

  Future<void> _onLoadRequested(
    PurchaseInboundLoadRequested event,
    Emitter<PurchaseInboundState> emit,
  ) async {
    emit(const PurchaseInboundLoading());

    final purchaseResult = await _dataSource.getPurchaseDetail(event.id);
    final warehouseResult = await _dataSource.getWarehouseList();

    if (purchaseResult.isFailure) {
      emit(PurchaseInboundError(purchaseResult.failure!.message));
      return;
    }

    final warehouses = warehouseResult.value ?? [];
    final purchase = purchaseResult.value!;
    final productCounts = <int, int>{};
    for (final p in purchase.products) {
      productCounts[p.productId] = p.remainCount;
    }

    emit(PurchaseInboundReady(
      purchase: purchase,
      warehouses: warehouses,
      productCounts: productCounts,
    ));
  }

  void _onWarehouseSelected(
    PurchaseInboundWarehouseSelected event,
    Emitter<PurchaseInboundState> emit,
  ) {
    final currentState = state;
    if (currentState is PurchaseInboundReady) {
      emit(currentState.copyWith(selectedWarehouse: event.warehouse));
    }
  }

  void _onProductCountUpdated(
    PurchaseInboundProductCountUpdated event,
    Emitter<PurchaseInboundState> emit,
  ) {
    final currentState = state;
    if (currentState is PurchaseInboundReady) {
      final newCounts = Map<int, int>.from(currentState.productCounts);
      newCounts[event.productId] = event.count;
      emit(currentState.copyWith(productCounts: newCounts));
    }
  }

  void _onRemarksChanged(
    PurchaseInboundRemarksChanged event,
    Emitter<PurchaseInboundState> emit,
  ) {
    final currentState = state;
    if (currentState is PurchaseInboundReady) {
      emit(currentState.copyWith(remarks: event.remarks));
    }
  }

  void _onWarehousesLoaded(
    PurchaseInboundWarehousesLoaded event,
    Emitter<PurchaseInboundState> emit,
  ) {
    final currentState = state;
    if (currentState is PurchaseInboundReady) {
      emit(currentState.copyWith(warehouses: event.warehouses));
    }
  }

  Future<void> _onSubmitRequested(
    PurchaseInboundSubmitRequested event,
    Emitter<PurchaseInboundState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PurchaseInboundReady) return;
    if (currentState.selectedWarehouse == null) {
      emit(PurchaseInboundError('请选择仓库'));
      emit(currentState);
      return;
    }

    emit(currentState.copyWith(isSubmitting: true));

    final products = <Map<String, dynamic>>[];
    for (final p in currentState.purchase.products) {
      final count = currentState.productCounts[p.productId] ?? 0;
      if (count > 0) {
        products.add({
          'productID': p.productId,
          'count': count,
        });
      }
    }

    if (products.isEmpty) {
      emit(currentState.copyWith(isSubmitting: false));
      emit(const PurchaseInboundError('请输入入库数量'));
      emit(currentState);
      return;
    }

    final result = await _dataSource.purchaseIntoWarehouse(
      purchaseId: currentState.purchase.id,
      warehouseId: currentState.selectedWarehouse!.id,
      products: products,
      remarks: currentState.remarks.isNotEmpty ? currentState.remarks : null,
    );

    if (result.isFailure) {
      emit(currentState.copyWith(isSubmitting: false));
      emit(PurchaseInboundError(result.failure!.message));
      emit(currentState);
      return;
    }

    emit(const PurchaseInboundSuccess('入库成功'));
  }
}