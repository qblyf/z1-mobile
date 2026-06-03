import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/stocktaking_remote_datasource.dart';
import '../../data/models/stocktaking_model.dart';

abstract class StocktakingListEvent extends Equatable {
  const StocktakingListEvent();
  @override
  List<Object?> get props => [];
}

class StocktakingListLoadRequested extends StocktakingListEvent {
  const StocktakingListLoadRequested();
}

class StocktakingListLoadMoreRequested extends StocktakingListEvent {
  const StocktakingListLoadMoreRequested();
}

class StocktakingListRefreshRequested extends StocktakingListEvent {
  const StocktakingListRefreshRequested();
}

abstract class StocktakingListState extends Equatable {
  const StocktakingListState();
  @override
  List<Object?> get props => [];
}

class StocktakingListInitial extends StocktakingListState {
  const StocktakingListInitial();
}

class StocktakingListLoading extends StocktakingListState {
  const StocktakingListLoading();
}

class StocktakingListLoaded extends StocktakingListState {
  final List<StocktakingModel> items;
  final bool hasReachedMax;
  final int currentPage;

  const StocktakingListLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  StocktakingListLoaded copyWith({
    List<StocktakingModel>? items,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return StocktakingListLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, currentPage];
}

class StocktakingListError extends StocktakingListState {
  final String message;
  const StocktakingListError(this.message);
  @override
  List<Object?> get props => [message];
}

class StocktakingListLoadingMore extends StocktakingListState {
  final List<StocktakingModel> items;
  final int currentPage;

  const StocktakingListLoadingMore({
    required this.items,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [items, currentPage];
}

class StocktakingListBloc extends Bloc<StocktakingListEvent, StocktakingListState> {
  final StocktakingRemoteDataSource _dataSource;

  StocktakingListBloc({required StocktakingRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const StocktakingListInitial()) {
    on<StocktakingListLoadRequested>(_onLoadRequested);
    on<StocktakingListLoadMoreRequested>(_onLoadMoreRequested);
    on<StocktakingListRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    StocktakingListLoadRequested event,
    Emitter<StocktakingListState> emit,
  ) async {
    emit(const StocktakingListLoading());

    const params = StocktakingListParams(page: 1, pageSize: 20);
    final result = await _dataSource.getStocktakingList(params);

    if (result.isFailure) {
      emit(StocktakingListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(StocktakingListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
    ));
  }

  Future<void> _onLoadMoreRequested(
    StocktakingListLoadMoreRequested event,
    Emitter<StocktakingListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StocktakingListLoaded) return;

    if (currentState.hasReachedMax) return;

    emit(StocktakingListLoadingMore(
      items: currentState.items,
      currentPage: currentState.currentPage,
    ));

    final params = StocktakingListParams(
      page: currentState.currentPage + 1,
      pageSize: 20,
    );
    final result = await _dataSource.getStocktakingList(params);

    if (result.isFailure) {
      emit(StocktakingListLoaded(
        items: currentState.items,
        hasReachedMax: false,
        currentPage: currentState.currentPage,
      ));
      return;
    }

    final newItems = result.value!;
    emit(StocktakingListLoaded(
      items: [...currentState.items, ...newItems],
      hasReachedMax: newItems.length < 20,
      currentPage: currentState.currentPage + 1,
    ));
  }

  Future<void> _onRefreshRequested(
    StocktakingListRefreshRequested event,
    Emitter<StocktakingListState> emit,
  ) async {
    const params = StocktakingListParams(page: 1, pageSize: 20);
    final result = await _dataSource.getStocktakingList(params);

    if (result.isFailure) {
      emit(StocktakingListError(result.failure!.message));
      return;
    }

    final items = result.value!;
    emit(StocktakingListLoaded(
      items: items,
      hasReachedMax: items.length < 20,
      currentPage: 1,
    ));
  }
}