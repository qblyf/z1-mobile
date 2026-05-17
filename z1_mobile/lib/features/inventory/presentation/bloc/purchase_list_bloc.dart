import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/models/purchase_model.dart';

abstract class PurchaseListEvent extends Equatable {
  const PurchaseListEvent();
  @override
  List<Object?> get props => [];
}

class PurchaseListLoadRequested extends PurchaseListEvent {
  const PurchaseListLoadRequested();
}

class PurchaseListLoadMoreRequested extends PurchaseListEvent {
  const PurchaseListLoadMoreRequested();
}

class PurchaseListRefreshRequested extends PurchaseListEvent {
  const PurchaseListRefreshRequested();
}

class PurchaseListFilterChanged extends PurchaseListEvent {
  final PurchaseState? state;
  const PurchaseListFilterChanged(this.state);
  @override
  List<Object?> get props => [state];
}

abstract class PurchaseListState extends Equatable {
  const PurchaseListState();
  @override
  List<Object?> get props => [];
}

class PurchaseListInitial extends PurchaseListState {
  const PurchaseListInitial();
}

class PurchaseListLoading extends PurchaseListState {
  const PurchaseListLoading();
}

class PurchaseListLoaded extends PurchaseListState {
  final List<PurchaseModel> items;
  final bool hasReachedMax;
  final int currentPage;
  final PurchaseState? filterState;

  const PurchaseListLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.filterState,
  });

  PurchaseListLoaded copyWith({
    List<PurchaseModel>? items,
    bool? hasReachedMax,
    int? currentPage,
    PurchaseState? filterState,
  }) {
    return PurchaseListLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      filterState: filterState ?? this.filterState,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, currentPage, filterState];
}

class PurchaseListError extends PurchaseListState {
  final String message;
  const PurchaseListError(this.message);
  @override
  List<Object?> get props => [message];
}

class PurchaseListLoadingMore extends PurchaseListState {
  final List<PurchaseModel> items;
  final int currentPage;
  final PurchaseState? filterState;

  const PurchaseListLoadingMore({
    required this.items,
    required this.currentPage,
    this.filterState,
  });

  @override
  List<Object?> get props => [items, currentPage, filterState];
}

class PurchaseListBloc extends Bloc<PurchaseListEvent, PurchaseListState> {
  final PurchaseRemoteDataSource _dataSource;

  PurchaseListBloc({required PurchaseRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const PurchaseListInitial()) {
    on<PurchaseListLoadRequested>(_onLoadRequested);
    on<PurchaseListLoadMoreRequested>(_onLoadMoreRequested);
    on<PurchaseListRefreshRequested>(_onRefreshRequested);
    on<PurchaseListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    PurchaseListLoadRequested event,
    Emitter<PurchaseListState> emit,
  ) async {
    emit(const PurchaseListLoading());

    final currentState = state;
    final filterState = currentState is PurchaseListLoaded ? currentState.filterState : null;

    final params = PurchaseListParams(
      page: 1,
      pageSize: 20,
      states: filterState != null ? [filterState.value] : null,
    );
    final result = await _dataSource.getPurchaseList(params);

    if (result.isFailure) {
      emit(PurchaseListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(PurchaseListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
      filterState: filterState,
    ));
  }

  Future<void> _onLoadMoreRequested(
    PurchaseListLoadMoreRequested event,
    Emitter<PurchaseListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PurchaseListLoaded) return;

    if (currentState.hasReachedMax) return;

    emit(PurchaseListLoadingMore(
      items: currentState.items,
      currentPage: currentState.currentPage,
      filterState: currentState.filterState,
    ));

    final params = PurchaseListParams(
      page: currentState.currentPage + 1,
      pageSize: 20,
      states: currentState.filterState != null ? [currentState.filterState!.value] : null,
    );
    final result = await _dataSource.getPurchaseList(params);

    if (result.isFailure) {
      emit(PurchaseListLoaded(
        items: currentState.items,
        hasReachedMax: false,
        currentPage: currentState.currentPage,
        filterState: currentState.filterState,
      ));
      return;
    }

    final newItems = result.value!;
    emit(PurchaseListLoaded(
      items: [...currentState.items, ...newItems],
      hasReachedMax: newItems.length < 20,
      currentPage: currentState.currentPage + 1,
      filterState: currentState.filterState,
    ));
  }

  Future<void> _onRefreshRequested(
    PurchaseListRefreshRequested event,
    Emitter<PurchaseListState> emit,
  ) async {
    final currentState = state;
    final filterState = currentState is PurchaseListLoaded ? currentState.filterState : null;

    final params = PurchaseListParams(
      page: 1,
      pageSize: 20,
      states: filterState != null ? [filterState.value] : null,
    );
    final result = await _dataSource.getPurchaseList(params);

    if (result.isFailure) {
      emit(PurchaseListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(PurchaseListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
      filterState: filterState,
    ));
  }

  Future<void> _onFilterChanged(
    PurchaseListFilterChanged event,
    Emitter<PurchaseListState> emit,
  ) async {
    emit(const PurchaseListLoading());

    final params = PurchaseListParams(
      page: 1,
      pageSize: 20,
      states: event.state != null ? [event.state!.value] : null,
    );
    final result = await _dataSource.getPurchaseList(params);

    if (result.isFailure) {
      emit(PurchaseListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(PurchaseListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
      filterState: event.state,
    ));
  }
}