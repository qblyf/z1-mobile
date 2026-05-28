import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/workbench_remote_datasource.dart';
import '../../data/models/workbench_models.dart';

abstract class WorkbenchEvent extends Equatable {
  const WorkbenchEvent();
  @override
  List<Object?> get props => [];
}

class WorkbenchLoadRequested extends WorkbenchEvent {
  const WorkbenchLoadRequested();
}

class WorkbenchRefreshRequested extends WorkbenchEvent {
  const WorkbenchRefreshRequested();
}

abstract class WorkbenchState extends Equatable {
  const WorkbenchState();
  @override
  List<Object?> get props => [];
}

class WorkbenchInitial extends WorkbenchState {
  const WorkbenchInitial();
}

class WorkbenchLoading extends WorkbenchState {
  const WorkbenchLoading();
}

class WorkbenchLoaded extends WorkbenchState {
  final WorkbenchStats stats;
  final List<WorkbenchApprovalItem> pendingApprovals;
  final List<WorkbenchTaskItem> pendingTasks;

  const WorkbenchLoaded({
    required this.stats,
    required this.pendingApprovals,
    required this.pendingTasks,
  });

  @override
  List<Object?> get props => [stats, pendingApprovals, pendingTasks];
}

class WorkbenchError extends WorkbenchState {
  final String message;
  const WorkbenchError(this.message);

  @override
  List<Object?> get props => [message];
}

class WorkbenchBloc extends Bloc<WorkbenchEvent, WorkbenchState> {
  final WorkbenchRemoteDataSource _dataSource;

  WorkbenchBloc({required WorkbenchRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const WorkbenchInitial()) {
    on<WorkbenchLoadRequested>(_onWorkbenchLoadRequested);
    on<WorkbenchRefreshRequested>(_onWorkbenchRefreshRequested);
  }

  Future<void> _onWorkbenchLoadRequested(
    WorkbenchLoadRequested event,
    Emitter<WorkbenchState> emit,
  ) async {
    emit(const WorkbenchLoading());
    await _loadData(emit);
  }

  Future<void> _onWorkbenchRefreshRequested(
    WorkbenchRefreshRequested event,
    Emitter<WorkbenchState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<WorkbenchState> emit) async {
    try {
      final todayStatResult = await _dataSource.getTodayStat();
      if (todayStatResult.isFailure) {
        emit(WorkbenchError(todayStatResult.failure!.message));
        return;
      }

      final approvalCountResult = await _dataSource.getApprovalCount();
      final approvalListResult = await _dataSource.getPendingApprovalList();
      final taskListResult = await _dataSource.getPendingTaskList();

      final todayStat = todayStatResult.value!;
      final approvalCount = approvalCountResult.value ?? 0;
      final pendingApprovals = approvalListResult.value ?? [];
      final pendingTasks = taskListResult.value ?? [];

      final stats = WorkbenchStats(
        todayStat: todayStat,
        pendingApprovalCount: approvalCount,
        pendingTaskCount: pendingTasks.length,
      );

      emit(WorkbenchLoaded(
        stats: stats,
        pendingApprovals: pendingApprovals,
        pendingTasks: pendingTasks,
      ));
    } catch (e) {
      emit(WorkbenchError('加载失败: $e'));
    }
  }
}