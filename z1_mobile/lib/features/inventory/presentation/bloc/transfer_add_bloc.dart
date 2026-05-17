import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../data/models/transfer_model.dart';
import '../../data/models/stocktaking_model.dart';

abstract class TransferAddEvent extends Equatable {
  const TransferAddEvent();
  @override
  List<Object?> get props => [];
}

class TransferAddLoadWarehousesRequested extends TransferAddEvent {
  const TransferAddLoadWarehousesRequested();
}

class TransferAddOutWarehouseSelected extends TransferAddEvent {
  final WarehouseModel warehouse;
  const TransferAddOutWarehouseSelected(this.warehouse);
  @override
  List<Object?> get props => [warehouse];
}

class TransferAddInWarehouseSelected extends TransferAddEvent {
  final WarehouseModel warehouse;
  const TransferAddInWarehouseSelected(this.warehouse);
  @override
  List<Object?> get props => [warehouse];
}

class TransferAddProductSelected extends TransferAddEvent {
  final TransferGoodsItem product;
  const TransferAddProductSelected(this.product);
  @override
  List<Object?> get props => [product];
}

class TransferAddProductRemoved extends TransferAddEvent {
  final int productID;
  const TransferAddProductRemoved(this.productID);
  @override
  List<Object?> get props => [productID];
}

class TransferAddProductCountChanged extends TransferAddEvent {
  final int productID;
  final int count;
  const TransferAddProductCountChanged({required this.productID, required this.count});
  @override
  List<Object?> get props => [productID, count];
}

class TransferAddSubmitted extends TransferAddEvent {
  const TransferAddSubmitted();
}

abstract class TransferAddState extends Equatable {
  const TransferAddState();
  @override
  List<Object?> get props => [];
}

class TransferAddInitial extends TransferAddState {
  const TransferAddInitial();
}

class TransferAddLoading extends TransferAddState {
  const TransferAddLoading();
}

class TransferAddLoaded extends TransferAddState {
  final List<WarehouseModel> warehouses;
  final WarehouseModel? outWarehouse;
  final WarehouseModel? inWarehouse;
  final List<TransferGoodsItem> products;

  const TransferAddLoaded({
    required this.warehouses,
    this.outWarehouse,
    this.inWarehouse,
    this.products = const [],
  });

  TransferAddLoaded copyWith({
    List<WarehouseModel>? warehouses,
    WarehouseModel? outWarehouse,
    WarehouseModel? inWarehouse,
    List<TransferGoodsItem>? products,
    bool clearOutWarehouse = false,
    bool clearInWarehouse = false,
  }) {
    return TransferAddLoaded(
      warehouses: warehouses ?? this.warehouses,
      outWarehouse: clearOutWarehouse ? null : (outWarehouse ?? this.outWarehouse),
      inWarehouse: clearInWarehouse ? null : (inWarehouse ?? this.inWarehouse),
      products: products ?? this.products,
    );
  }

  bool get canSubmit =>
      outWarehouse != null && inWarehouse != null && products.isNotEmpty && outWarehouse!.id != inWarehouse!.id;

  @override
  List<Object?> get props => [warehouses, outWarehouse, inWarehouse, products];
}

class TransferAddSubmitting extends TransferAddState {
  final List<WarehouseModel> warehouses;
  final WarehouseModel? outWarehouse;
  final WarehouseModel? inWarehouse;
  final List<TransferGoodsItem> products;

  const TransferAddSubmitting({
    required this.warehouses,
    this.outWarehouse,
    this.inWarehouse,
    required this.products,
  });

  @override
  List<Object?> get props => [warehouses, outWarehouse, inWarehouse, products];
}

class TransferAddSuccess extends TransferAddState {
  final int transferId;
  const TransferAddSuccess(this.transferId);
  @override
  List<Object?> get props => [transferId];
}

class TransferAddError extends TransferAddState {
  final String message;
  final List<WarehouseModel> warehouses;
  final WarehouseModel? outWarehouse;
  final WarehouseModel? inWarehouse;
  final List<TransferGoodsItem> products;

  const TransferAddError(
    this.message, {
    this.warehouses = const [],
    WarehouseModel? outWarehouse,
    WarehouseModel? inWarehouse,
    List<TransferGoodsItem>? products,
  })  : outWarehouse = outWarehouse,
        inWarehouse = inWarehouse,
        products = products ?? const [];

  @override
  List<Object?> get props => [message, warehouses, outWarehouse, inWarehouse, products];
}

class TransferAddBloc extends Bloc<TransferAddEvent, TransferAddState> {
  final TransferRemoteDataSource _transferDataSource;

  TransferAddBloc({required TransferRemoteDataSource dataSource})
      : _transferDataSource = dataSource,
        super(const TransferAddInitial()) {
    on<TransferAddLoadWarehousesRequested>(_onLoadWarehouses);
    on<TransferAddOutWarehouseSelected>(_onOutWarehouseSelected);
    on<TransferAddInWarehouseSelected>(_onInWarehouseSelected);
    on<TransferAddProductSelected>(_onProductSelected);
    on<TransferAddProductRemoved>(_onProductRemoved);
    on<TransferAddProductCountChanged>(_onProductCountChanged);
    on<TransferAddSubmitted>(_onSubmit);
  }

  Future<void> _onLoadWarehouses(
    TransferAddLoadWarehousesRequested event,
    Emitter<TransferAddState> emit,
  ) async {
    emit(const TransferAddLoading());

    final result = await _transferDataSource.getWarehouseList();

    if (result.isFailure) {
      emit(TransferAddError(result.failure!.message));
      return;
    }

    emit(TransferAddLoaded(warehouses: result.value!));
  }

  void _onOutWarehouseSelected(
    TransferAddOutWarehouseSelected event,
    Emitter<TransferAddState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferAddLoaded) {
      emit(currentState.copyWith(outWarehouse: event.warehouse));
    }
  }

  void _onInWarehouseSelected(
    TransferAddInWarehouseSelected event,
    Emitter<TransferAddState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferAddLoaded) {
      emit(currentState.copyWith(inWarehouse: event.warehouse));
    }
  }

  void _onProductSelected(
    TransferAddProductSelected event,
    Emitter<TransferAddState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferAddLoaded) {
      final existingIndex = currentState.products.indexWhere((p) => p.productID == event.product.productID);
      if (existingIndex >= 0) {
        return;
      }
      emit(currentState.copyWith(
        products: [...currentState.products, event.product],
      ));
    }
  }

  void _onProductRemoved(
    TransferAddProductRemoved event,
    Emitter<TransferAddState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferAddLoaded) {
      emit(currentState.copyWith(
        products: currentState.products.where((p) => p.productID != event.productID).toList(),
      ));
    }
  }

  void _onProductCountChanged(
    TransferAddProductCountChanged event,
    Emitter<TransferAddState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferAddLoaded) {
      final updatedProducts = currentState.products.map((p) {
        if (p.productID == event.productID) {
          return TransferGoodsItem(
            productID: p.productID,
            productName: p.productName,
            spec: p.spec,
            barcode: p.barcode,
            count: event.count,
          );
        }
        return p;
      }).toList();
      emit(currentState.copyWith(products: updatedProducts));
    }
  }

  Future<void> _onSubmit(
    TransferAddSubmitted event,
    Emitter<TransferAddState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransferAddLoaded) return;

    if (!currentState.canSubmit) return;

    emit(TransferAddSubmitting(
      warehouses: currentState.warehouses,
      outWarehouse: currentState.outWarehouse,
      inWarehouse: currentState.inWarehouse,
      products: currentState.products,
    ));

    final params = TransferCreateParams(
      outWarehouseID: currentState.outWarehouse!.id,
      inWarehouseID: currentState.inWarehouse!.id,
      items: currentState.products.map((p) => p.toJson()).toList(),
    );

    final result = await _transferDataSource.createTransfer(params);

    if (result.isFailure) {
      emit(TransferAddError(
        result.failure!.message,
        warehouses: currentState.warehouses,
        outWarehouse: currentState.outWarehouse,
        inWarehouse: currentState.inWarehouse,
        products: currentState.products,
      ));
      return;
    }

    emit(TransferAddSuccess(result.value!));
  }
}