import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/serial_search_remote_datasource.dart';
import '../../data/models/serial_search_model.dart';
import '../../data/models/stocktaking_model.dart';

abstract class SerialSearchEvent extends Equatable {
  const SerialSearchEvent();
  @override
  List<Object?> get props => [];
}

class SerialSearchCodeSubmitted extends SerialSearchEvent {
  final String serial;
  final int? warehouseId;

  const SerialSearchCodeSubmitted({required this.serial, this.warehouseId});

  @override
  List<Object?> get props => [serial, warehouseId];
}

class SerialSearchWarehousesRequested extends SerialSearchEvent {
  const SerialSearchWarehousesRequested();
}

class SerialSearchWarehouseChanged extends SerialSearchEvent {
  final int warehouseId;

  const SerialSearchWarehouseChanged(this.warehouseId);

  @override
  List<Object?> get props => [warehouseId];
}

class SerialSearchCleared extends SerialSearchEvent {
  const SerialSearchCleared();
}

abstract class SerialSearchState extends Equatable {
  const SerialSearchState();
  @override
  List<Object?> get props => [];
}

class SerialSearchInitial extends SerialSearchState {
  final List<WarehouseModel> warehouses;
  final int? selectedWarehouseId;

  const SerialSearchInitial({
    this.warehouses = const [],
    this.selectedWarehouseId,
  });

  @override
  List<Object?> get props => [warehouses, selectedWarehouseId];

  SerialSearchInitial copyWith({
    List<WarehouseModel>? warehouses,
    int? selectedWarehouseId,
  }) {
    return SerialSearchInitial(
      warehouses: warehouses ?? this.warehouses,
      selectedWarehouseId: selectedWarehouseId ?? this.selectedWarehouseId,
    );
  }
}

class SerialSearchLoading extends SerialSearchState {
  final List<WarehouseModel> warehouses;
  final int? selectedWarehouseId;
  final String queryCode;

  const SerialSearchLoading({
    this.warehouses = const [],
    this.selectedWarehouseId,
    required this.queryCode,
  });

  @override
  List<Object?> get props => [warehouses, selectedWarehouseId, queryCode];
}

class SerialSearchLoaded extends SerialSearchState {
  final SerialSearchResultModel result;
  final List<WarehouseModel> warehouses;
  final int? selectedWarehouseId;

  const SerialSearchLoaded({
    required this.result,
    this.warehouses = const [],
    this.selectedWarehouseId,
  });

  @override
  List<Object?> get props => [result, warehouses, selectedWarehouseId];
}

class SerialSearchError extends SerialSearchState {
  final String message;
  final List<WarehouseModel> warehouses;
  final int? selectedWarehouseId;
  final String queryCode;

  const SerialSearchError({
    required this.message,
    this.warehouses = const [],
    this.selectedWarehouseId,
    required this.queryCode,
  });

  @override
  List<Object?> get props => [message, warehouses, selectedWarehouseId, queryCode];
}

class SerialSearchBloc extends Bloc<SerialSearchEvent, SerialSearchState> {
  final SerialSearchRemoteDataSource _dataSource;

  SerialSearchBloc({required SerialSearchRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const SerialSearchInitial()) {
    on<SerialSearchWarehousesRequested>(_onLoadWarehouses);
    on<SerialSearchCodeSubmitted>(_onSearch);
    on<SerialSearchWarehouseChanged>(_onWarehouseChanged);
    on<SerialSearchCleared>(_onCleared);
  }

  Future<void> _onLoadWarehouses(
    SerialSearchWarehousesRequested event,
    Emitter<SerialSearchState> emit,
  ) async {
    final result = await _dataSource.getWarehouseList();
    if (result.isFailure) return;

    final warehouses = result.value!;
    final currentState = state;
    final selectedId = currentState is SerialSearchInitial
        ? currentState.selectedWarehouseId
        : null;

    emit(SerialSearchInitial(
      warehouses: warehouses,
      selectedWarehouseId: selectedId ?? (warehouses.isNotEmpty ? warehouses.first.id : null),
    ));
  }

  Future<void> _onSearch(
    SerialSearchCodeSubmitted event,
    Emitter<SerialSearchState> emit,
  ) async {
    final currentState = state;
    final warehouses = currentState is SerialSearchInitial
        ? currentState.warehouses
        : <WarehouseModel>[];
    final selectedWarehouseId = currentState is SerialSearchInitial
        ? currentState.selectedWarehouseId
        : null;

    emit(SerialSearchLoading(
      warehouses: warehouses,
      selectedWarehouseId: selectedWarehouseId,
      queryCode: event.serial,
    ));

    final result = await _dataSource.searchSerial(
      SerialSearchParams(
        serial: event.serial,
        warehouseId: event.warehouseId ?? selectedWarehouseId,
      ),
    );

    if (result.isFailure) {
      emit(SerialSearchError(
        message: result.failure!.message,
        warehouses: warehouses,
        selectedWarehouseId: selectedWarehouseId,
        queryCode: event.serial,
      ));
      return;
    }

    emit(SerialSearchLoaded(
      result: result.value!,
      warehouses: warehouses,
      selectedWarehouseId: selectedWarehouseId,
    ));
  }

  void _onWarehouseChanged(
    SerialSearchWarehouseChanged event,
    Emitter<SerialSearchState> emit,
  ) {
    final currentState = state;
    if (currentState is SerialSearchLoaded) {
      emit(SerialSearchLoaded(
        result: currentState.result,
        warehouses: currentState.warehouses,
        selectedWarehouseId: event.warehouseId,
      ));
    } else if (currentState is SerialSearchInitial) {
      emit(currentState.copyWith(selectedWarehouseId: event.warehouseId));
    }
  }

  void _onCleared(
    SerialSearchCleared event,
    Emitter<SerialSearchState> emit,
  ) {
    final currentState = state;
    if (currentState is SerialSearchLoaded) {
      emit(SerialSearchInitial(
        warehouses: currentState.warehouses,
        selectedWarehouseId: currentState.selectedWarehouseId,
      ));
    } else if (currentState is SerialSearchError) {
      emit(SerialSearchInitial(
        warehouses: currentState.warehouses,
        selectedWarehouseId: currentState.selectedWarehouseId,
      ));
    }
  }
}