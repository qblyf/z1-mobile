import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../data/models/transfer_model.dart';

abstract class TransferListEvent extends Equatable {
  const TransferListEvent();
  @override
  List<Object?> get props => [];
}

class TransferListLoadRequested extends TransferListEvent {
  final List<int>? states;
  const TransferListLoadRequested({this.states});
}

class TransferListLoadMoreRequested extends TransferListEvent {
  const TransferListLoadMoreRequested();
}

class TransferListRefreshRequested extends TransferListEvent {
  const TransferListRefreshRequested();
}

class TransferListFilterChanged extends TransferListEvent {
  final int? stateIndex;
  const TransferListFilterChanged(this.stateIndex);
}

abstract class TransferListState extends Equatable {
  const TransferListState();
  @override
  List<Object?> get props => [];
}

class TransferListInitial extends TransferListState {
  const TransferListInitial();
}

class TransferListLoading extends TransferListState {
  const TransferListLoading();
}

class TransferListLoaded extends TransferListState {
  final List<TransferModel> items;
  final bool hasReachedMax;
  final int currentPage;
  final int? filterStateIndex;

  const TransferListLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.filterStateIndex,
  });

  TransferListLoaded copyWith({
    List<TransferModel>? items,
    bool? hasReachedMax,
    int? currentPage,
    int? filterStateIndex,
  }) {
    return TransferListLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      filterStateIndex: filterStateIndex ?? this.filterStateIndex,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, currentPage, filterStateIndex];
}

class TransferListError extends TransferListState {
  final String message;
  const TransferListError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransferListLoadingMore extends TransferListState {
  final List<TransferModel> items;
  final int currentPage;
  final int? filterStateIndex;

  const TransferListLoadingMore({
    required this.items,
    required this.currentPage,
    this.filterStateIndex,
  });

  @override
  List<Object?> get props => [items, currentPage, filterStateIndex];
}

class TransferListBloc extends Bloc<TransferListEvent, TransferListState> {
  final TransferRemoteDataSource _dataSource;
  List<int>? _currentStates;

  TransferListBloc({required TransferRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const TransferListInitial()) {
    on<TransferListLoadRequested>(_onLoadRequested);
    on<TransferListLoadMoreRequested>(_onLoadMoreRequested);
    on<TransferListRefreshRequested>(_onRefreshRequested);
    on<TransferListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    TransferListLoadRequested event,
    Emitter<TransferListState> emit,
  ) async {
    emit(const TransferListLoading());
    _currentStates = event.states;

    final params = TransferListParams(page: 1, pageSize: 20, states: _currentStates);
    final result = await _dataSource.getTransferList(params);

    if (result.isFailure) {
      emit(TransferListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(TransferListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
    ));
  }

  Future<void> _onLoadMoreRequested(
    TransferListLoadMoreRequested event,
    Emitter<TransferListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransferListLoaded) return;

    if (currentState.hasReachedMax) return;

    emit(TransferListLoadingMore(
      items: currentState.items,
      currentPage: currentState.currentPage,
      filterStateIndex: currentState.filterStateIndex,
    ));

    final params = TransferListParams(
      page: currentState.currentPage + 1,
      pageSize: 20,
      states: _currentStates,
    );
    final result = await _dataSource.getTransferList(params);

    if (result.isFailure) {
      emit(TransferListLoaded(
        items: currentState.items,
        hasReachedMax: false,
        currentPage: currentState.currentPage,
        filterStateIndex: currentState.filterStateIndex,
      ));
      return;
    }

    final newItems = result.value!;
    emit(TransferListLoaded(
      items: [...currentState.items, ...newItems],
      hasReachedMax: newItems.length < 20,
      currentPage: currentState.currentPage + 1,
      filterStateIndex: currentState.filterStateIndex,
    ));
  }

  Future<void> _onRefreshRequested(
    TransferListRefreshRequested event,
    Emitter<TransferListState> emit,
  ) async {
    final params = TransferListParams(page: 1, pageSize: 20, states: _currentStates);
    final result = await _dataSource.getTransferList(params);

    if (result.isFailure) {
      emit(TransferListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(TransferListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
    ));
  }

  Future<void> _onFilterChanged(
    TransferListFilterChanged event,
    Emitter<TransferListState> emit,
  ) async {
    if (event.stateIndex == null) {
      _currentStates = null;
    } else {
      _currentStates = [event.stateIndex!];
    }
    add(TransferListLoadRequested(states: _currentStates));
  }
}