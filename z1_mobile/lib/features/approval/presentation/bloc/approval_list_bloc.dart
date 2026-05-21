import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/approval_remote_datasource.dart';
import '../../data/models/approval_model.dart';

abstract class ApprovalListEvent extends Equatable {
  const ApprovalListEvent();
  @override
  List<Object?> get props => [];
}

class ApprovalListLoadRequested extends ApprovalListEvent {
  final ApprovalTab tab;
  const ApprovalListLoadRequested({this.tab = ApprovalTab.all});
  @override
  List<Object?> get props => [tab];
}

class ApprovalListLoadMoreRequested extends ApprovalListEvent {
  const ApprovalListLoadMoreRequested();
}

class ApprovalListRefreshRequested extends ApprovalListEvent {
  const ApprovalListRefreshRequested();
}

class ApprovalListTabChanged extends ApprovalListEvent {
  final ApprovalTab tab;
  const ApprovalListTabChanged(this.tab);
  @override
  List<Object?> get props => [tab];
}

abstract class ApprovalListState extends Equatable {
  const ApprovalListState();
  @override
  List<Object?> get props => [];
}

class ApprovalListInitial extends ApprovalListState {
  const ApprovalListInitial();
}

class ApprovalListLoading extends ApprovalListState {
  const ApprovalListLoading();
}

class ApprovalListLoaded extends ApprovalListState {
  final List<ApprovalModel> approvals;
  final ApprovalTab currentTab;
  final bool hasReachedMax;
  final int currentPage;

  const ApprovalListLoaded({
    required this.approvals,
    required this.currentTab,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  ApprovalListLoaded copyWith({
    List<ApprovalModel>? approvals,
    ApprovalTab? currentTab,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ApprovalListLoaded(
      approvals: approvals ?? this.approvals,
      currentTab: currentTab ?? this.currentTab,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [approvals, currentTab, hasReachedMax, currentPage];
}

class ApprovalListError extends ApprovalListState {
  final String message;
  const ApprovalListError(this.message);
  @override
  List<Object?> get props => [message];
}

class ApprovalListLoadingMore extends ApprovalListState {
  final List<ApprovalModel> approvals;
  final ApprovalTab currentTab;
  final int currentPage;

  const ApprovalListLoadingMore({
    required this.approvals,
    required this.currentTab,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [approvals, currentTab, currentPage];
}

class ApprovalListBloc extends Bloc<ApprovalListEvent, ApprovalListState> {
  final ApprovalRemoteDataSource _dataSource;

  ApprovalListBloc({required ApprovalRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ApprovalListInitial()) {
    on<ApprovalListLoadRequested>(_onLoadRequested);
    on<ApprovalListLoadMoreRequested>(_onLoadMoreRequested);
    on<ApprovalListRefreshRequested>(_onRefreshRequested);
    on<ApprovalListTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    ApprovalListLoadRequested event,
    Emitter<ApprovalListState> emit,
  ) async {
    emit(const ApprovalListLoading());
    await _loadApprovals(emit, event.tab, 1, 20);
  }

  Future<void> _onLoadMoreRequested(
    ApprovalListLoadMoreRequested event,
    Emitter<ApprovalListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ApprovalListLoaded) return;
    if (currentState.hasReachedMax) return;
    if (currentState is ApprovalListLoadingMore) return;

    emit(ApprovalListLoadingMore(
      approvals: currentState.approvals,
      currentTab: currentState.currentTab,
      currentPage: currentState.currentPage,
    ));

    final result = await _dataSource.getApprovalList(
      ApprovalListParams(
        tab: currentState.currentTab,
        page: currentState.currentPage + 1,
        pageSize: 20,
      ),
    );

    if (result.isFailure) {
      emit(currentState);
      return;
    }

    final newApprovals = result.value!;
    emit(ApprovalListLoaded(
      approvals: [...currentState.approvals, ...newApprovals],
      currentTab: currentState.currentTab,
      hasReachedMax: newApprovals.length < 20,
      currentPage: currentState.currentPage + 1,
    ));
  }

  Future<void> _onRefreshRequested(
    ApprovalListRefreshRequested event,
    Emitter<ApprovalListState> emit,
  ) async {
    final currentTab = state is ApprovalListLoaded
        ? (state as ApprovalListLoaded).currentTab
        : state is ApprovalListLoadingMore
            ? (state as ApprovalListLoadingMore).currentTab
            : ApprovalTab.all;
    await _loadApprovals(emit, currentTab, 1, 20);
  }

  Future<void> _onTabChanged(
    ApprovalListTabChanged event,
    Emitter<ApprovalListState> emit,
  ) async {
    await _loadApprovals(emit, event.tab, 1, 20);
  }

  Future<void> _loadApprovals(
    Emitter<ApprovalListState> emit,
    ApprovalTab tab,
    int page,
    int pageSize,
  ) async {
    emit(const ApprovalListLoading());

    final result = await _dataSource.getApprovalList(
      ApprovalListParams(tab: tab, page: page, pageSize: pageSize),
    );

    if (result.isFailure) {
      emit(ApprovalListError(result.failure!.message));
      return;
    }

    final approvals = result.value!;
    emit(ApprovalListLoaded(
      approvals: approvals,
      currentTab: tab,
      hasReachedMax: approvals.length < pageSize,
      currentPage: 1,
    ));
  }
}