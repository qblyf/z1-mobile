import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/mall_order_remote_datasource.dart';
import '../../data/models/mall_order_model.dart';

// ============================================================================
// Events
// ============================================================================

abstract class MallOrderListEvent extends Equatable {
  const MallOrderListEvent();
  @override
  List<Object?> get props => [];
}

class MallOrderListLoadRequested extends MallOrderListEvent {
  final MallOrderDisplayStatus tab;
  const MallOrderListLoadRequested({this.tab = MallOrderDisplayStatus.all});
  @override
  List<Object?> get props => [tab];
}

class MallOrderListLoadMoreRequested extends MallOrderListEvent {
  const MallOrderListLoadMoreRequested();
}

class MallOrderListRefreshRequested extends MallOrderListEvent {
  const MallOrderListRefreshRequested();
}

class MallOrderListTabChanged extends MallOrderListEvent {
  final MallOrderDisplayStatus tab;
  const MallOrderListTabChanged(this.tab);
  @override
  List<Object?> get props => [tab];
}

// ============================================================================
// States
// ============================================================================

abstract class MallOrderListState extends Equatable {
  const MallOrderListState();
  @override
  List<Object?> get props => [];
}

class MallOrderListInitial extends MallOrderListState {
  const MallOrderListInitial();
}

class MallOrderListLoading extends MallOrderListState {
  final MallOrderDisplayStatus tab;
  const MallOrderListLoading({required this.tab});
  @override
  List<Object?> get props => [tab];
}

class MallOrderListLoaded extends MallOrderListState {
  final List<MallOrderModel> orders;
  final MallOrderDisplayStatus tab;
  final bool hasReachedMax;
  final int currentPage;

  const MallOrderListLoaded({
    required this.orders,
    required this.tab,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  MallOrderListLoaded copyWith({
    List<MallOrderModel>? orders,
    MallOrderDisplayStatus? tab,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return MallOrderListLoaded(
      orders: orders ?? this.orders,
      tab: tab ?? this.tab,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [orders, tab, hasReachedMax, currentPage];
}

class MallOrderListLoadingMore extends MallOrderListState {
  final List<MallOrderModel> orders;
  final MallOrderDisplayStatus tab;
  final int currentPage;

  const MallOrderListLoadingMore({
    required this.orders,
    required this.tab,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [orders, tab, currentPage];
}

class MallOrderListError extends MallOrderListState {
  final String message;
  final MallOrderDisplayStatus tab;
  const MallOrderListError({required this.message, required this.tab});
  @override
  List<Object?> get props => [message, tab];
}

// ============================================================================
// BLoC
// ============================================================================

class MallOrderListBloc extends Bloc<MallOrderListEvent, MallOrderListState> {
  static const int _pageSize = 20;

  final MallOrderRemoteDataSource _dataSource;

  MallOrderListBloc({required MallOrderRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const MallOrderListInitial()) {
    on<MallOrderListLoadRequested>(_onLoadRequested);
    on<MallOrderListLoadMoreRequested>(_onLoadMoreRequested);
    on<MallOrderListRefreshRequested>(_onRefreshRequested);
    on<MallOrderListTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    MallOrderListLoadRequested event,
    Emitter<MallOrderListState> emit,
  ) async {
    await _loadFirstPage(emit, event.tab);
  }

  Future<void> _onTabChanged(
    MallOrderListTabChanged event,
    Emitter<MallOrderListState> emit,
  ) async {
    final currentTab = _currentTab();
    if (currentTab == event.tab && state is MallOrderListLoaded) {
      return; // 同 tab 不重复加载
    }
    await _loadFirstPage(emit, event.tab);
  }

  Future<void> _onRefreshRequested(
    MallOrderListRefreshRequested event,
    Emitter<MallOrderListState> emit,
  ) async {
    await _loadFirstPage(emit, _currentTab());
  }

  Future<void> _loadFirstPage(
    Emitter<MallOrderListState> emit,
    MallOrderDisplayStatus tab,
  ) async {
    emit(MallOrderListLoading(tab: tab));

    final params = MallOrderListParams(
      page: 1,
      pageSize: _pageSize,
      status: tab.apiStatusValues,
    );
    final result = await _dataSource.getMallOrderList(params);

    if (result.isFailure) {
      emit(MallOrderListError(message: result.failure!.message, tab: tab));
      return;
    }

    final items = result.value!;
    emit(MallOrderListLoaded(
      orders: items,
      tab: tab,
      hasReachedMax: items.length < _pageSize,
      currentPage: 1,
    ));
  }

  Future<void> _onLoadMoreRequested(
    MallOrderListLoadMoreRequested event,
    Emitter<MallOrderListState> emit,
  ) async {
    final current = state;
    if (current is! MallOrderListLoaded) return;
    if (current.hasReachedMax) return;

    emit(MallOrderListLoadingMore(
      orders: current.orders,
      tab: current.tab,
      currentPage: current.currentPage,
    ));

    final params = MallOrderListParams(
      page: current.currentPage + 1,
      pageSize: _pageSize,
      status: current.tab.apiStatusValues,
    );
    final result = await _dataSource.getMallOrderList(params);

    if (result.isFailure) {
      // 加载更多失败：回到上一个 loaded 状态，UI 可重试
      emit(current);
      return;
    }

    final newItems = result.value!;
    emit(current.copyWith(
      orders: [...current.orders, ...newItems],
      hasReachedMax: newItems.length < _pageSize,
      currentPage: current.currentPage + 1,
    ));
  }

  MallOrderDisplayStatus _currentTab() {
    final s = state;
    if (s is MallOrderListLoaded) return s.tab;
    if (s is MallOrderListLoadingMore) return s.tab;
    if (s is MallOrderListLoading) return s.tab;
    if (s is MallOrderListError) return s.tab;
    return MallOrderDisplayStatus.all;
  }
}
