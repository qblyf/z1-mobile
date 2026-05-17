import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/stocktaking_remote_datasource.dart';
import '../../data/models/stocktaking_model.dart';

abstract class StocktakingAddEvent extends Equatable {
  const StocktakingAddEvent();
  @override
  List<Object?> get props => [];
}

class StocktakingLoadWarehousesRequested extends StocktakingAddEvent {
  const StocktakingLoadWarehousesRequested();
}

class StocktakingAddSubmitted extends StocktakingAddEvent {
  final int warehouseID;
  final String? remarks;

  const StocktakingAddSubmitted({required this.warehouseID, this.remarks});

  @override
  List<Object?> get props => [warehouseID, remarks];
}

abstract class StocktakingAddState extends Equatable {
  const StocktakingAddState();
  @override
  List<Object?> get props => [];
}

class StocktakingAddInitial extends StocktakingAddState {
  const StocktakingAddInitial();
}

class StocktakingAddLoading extends StocktakingAddState {
  const StocktakingAddLoading();
}

class StocktakingAddWarehouseLoaded extends StocktakingAddState {
  final List<WarehouseModel> warehouses;
  const StocktakingAddWarehouseLoaded(this.warehouses);
  @override
  List<Object?> get props => [warehouses];
}

class StocktakingAddSubmitting extends StocktakingAddState {
  final List<WarehouseModel> warehouses;
  const StocktakingAddSubmitting(this.warehouses);
  @override
  List<Object?> get props => [warehouses];
}

class StocktakingAddSuccess extends StocktakingAddState {
  final int stocktakingId;
  const StocktakingAddSuccess(this.stocktakingId);
  @override
  List<Object?> get props => [stocktakingId];
}

class StocktakingAddError extends StocktakingAddState {
  final String message;
  final List<WarehouseModel> warehouses;
  const StocktakingAddError(this.message, [this.warehouses = const []]);
  @override
  List<Object?> get props => [message, warehouses];
}

class StocktakingAddBloc extends Bloc<StocktakingAddEvent, StocktakingAddState> {
  final StocktakingRemoteDataSource _dataSource;

  StocktakingAddBloc({required StocktakingRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const StocktakingAddInitial()) {
    on<StocktakingLoadWarehousesRequested>(_onLoadWarehouses);
    on<StocktakingAddSubmitted>(_onSubmit);
  }

  Future<void> _onLoadWarehouses(
    StocktakingLoadWarehousesRequested event,
    Emitter<StocktakingAddState> emit,
  ) async {
    emit(const StocktakingAddLoading());

    final result = await _dataSource.getWarehouseList();

    if (result.isFailure) {
      emit(StocktakingAddError(result.failure!.message));
      return;
    }

    emit(StocktakingAddWarehouseLoaded(result.value!));
  }

  Future<void> _onSubmit(
    StocktakingAddSubmitted event,
    Emitter<StocktakingAddState> emit,
  ) async {
    final currentState = state;
    final warehouses = currentState is StocktakingAddWarehouseLoaded
        ? currentState.warehouses
        : <WarehouseModel>[];

    emit(StocktakingAddSubmitting(warehouses));

    final result = await _dataSource.addStocktaking(
      warehouseID: event.warehouseID,
      remarks: event.remarks,
    );

    if (result.isFailure) {
      emit(StocktakingAddError(result.failure!.message, warehouses));
      return;
    }

    emit(StocktakingAddSuccess(result.value!));
  }
}

abstract class StocktakingDetailEvent extends Equatable {
  const StocktakingDetailEvent();
  @override
  List<Object?> get props => [];
}

class StocktakingDetailLoadRequested extends StocktakingDetailEvent {
  final int id;
  const StocktakingDetailLoadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class StocktakingDetailEndRequested extends StocktakingDetailEvent {
  final int id;
  const StocktakingDetailEndRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class StocktakingDetailRestartRequested extends StocktakingDetailEvent {
  final int id;
  const StocktakingDetailRestartRequested(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class StocktakingDetailState extends Equatable {
  const StocktakingDetailState();
  @override
  List<Object?> get props => [];
}

class StocktakingDetailInitial extends StocktakingDetailState {
  const StocktakingDetailInitial();
}

class StocktakingDetailLoading extends StocktakingDetailState {
  const StocktakingDetailLoading();
}

class StocktakingDetailLoaded extends StocktakingDetailState {
  final StocktakingModel stocktaking;
  final List<StocktakingProductModel> products;
  const StocktakingDetailLoaded({required this.stocktaking, required this.products});
  @override
  List<Object?> get props => [stocktaking, products];
}

class StocktakingDetailError extends StocktakingDetailState {
  final String message;
  const StocktakingDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class StocktakingDetailOperating extends StocktakingDetailState {
  final StocktakingModel stocktaking;
  final List<StocktakingProductModel> products;
  const StocktakingDetailOperating({required this.stocktaking, required this.products});
  @override
  List<Object?> get props => [stocktaking, products];
}

class StocktakingDetailOperationSuccess extends StocktakingDetailState {
  final String message;
  const StocktakingDetailOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class StocktakingDetailBloc extends Bloc<StocktakingDetailEvent, StocktakingDetailState> {
  final StocktakingRemoteDataSource _dataSource;

  StocktakingDetailBloc({required StocktakingRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const StocktakingDetailInitial()) {
    on<StocktakingDetailLoadRequested>(_onLoad);
    on<StocktakingDetailEndRequested>(_onEnd);
    on<StocktakingDetailRestartRequested>(_onRestart);
  }

  Future<void> _onLoad(
    StocktakingDetailLoadRequested event,
    Emitter<StocktakingDetailState> emit,
  ) async {
    emit(const StocktakingDetailLoading());

    final detailResult = await _dataSource.getStocktakingDetail(event.id);
    if (detailResult.isFailure) {
      emit(StocktakingDetailError(detailResult.failure!.message));
      return;
    }

    final productsResult = await _dataSource.getStocktakingProducts(event.id);
    if (productsResult.isFailure) {
      emit(StocktakingDetailError(productsResult.failure!.message));
      return;
    }

    emit(StocktakingDetailLoaded(
      stocktaking: detailResult.value!,
      products: productsResult.value!,
    ));
  }

  Future<void> _onEnd(
    StocktakingDetailEndRequested event,
    Emitter<StocktakingDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StocktakingDetailLoaded) return;

    emit(StocktakingDetailOperating(
      stocktaking: currentState.stocktaking,
      products: currentState.products,
    ));

    final result = await _dataSource.endStocktaking(event.id);
    if (result.isFailure) {
      emit(StocktakingDetailLoaded(
        stocktaking: currentState.stocktaking,
        products: currentState.products,
      ));
      return;
    }

    emit(const StocktakingDetailOperationSuccess('盘库已完成'));
    add(StocktakingDetailLoadRequested(event.id));
  }

  Future<void> _onRestart(
    StocktakingDetailRestartRequested event,
    Emitter<StocktakingDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StocktakingDetailLoaded) return;

    emit(StocktakingDetailOperating(
      stocktaking: currentState.stocktaking,
      products: currentState.products,
    ));

    final result = await _dataSource.restartStocktaking(event.id);
    if (result.isFailure) {
      emit(StocktakingDetailLoaded(
        stocktaking: currentState.stocktaking,
        products: currentState.products,
      ));
      return;
    }

    emit(const StocktakingDetailOperationSuccess('盘库已重新开始'));
    add(StocktakingDetailLoadRequested(event.id));
  }
}