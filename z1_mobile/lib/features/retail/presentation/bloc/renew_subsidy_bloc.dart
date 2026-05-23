import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/result.dart';
import '../../data/datasources/renew_subsidy_remote_datasource.dart';
import '../../data/models/renew_subsidy_model.dart';

/// 换新补贴事件
abstract class RenewSubsidyEvent extends Equatable {
  const RenewSubsidyEvent();
  @override
  List<Object?> get props => [];
}

/// 加载可用换新补贴
class RenewSubsidyLoadRequested extends RenewSubsidyEvent {
  final String? classId;
  const RenewSubsidyLoadRequested({this.classId});
  @override
  List<Object?> get props => [classId];
}

/// 加载券分类
class RenewSubsidyLoadClassRequested extends RenewSubsidyEvent {
  const RenewSubsidyLoadClassRequested();
}

/// 切换选择
class RenewSubsidySelectionToggled extends RenewSubsidyEvent {
  final RenewSubsidyModel subsidy;
  const RenewSubsidySelectionToggled(this.subsidy);
  @override
  List<Object?> get props => [subsidy];
}

/// 确认选择
class RenewSubsidyConfirmSelection extends RenewSubsidyEvent {
  const RenewSubsidyConfirmSelection();
}

/// 换新补贴状态
abstract class RenewSubsidyState extends Equatable {
  const RenewSubsidyState();
  @override
  List<Object?> get props => [];
}

class RenewSubsidyInitial extends RenewSubsidyState {
  const RenewSubsidyInitial();
}

class RenewSubsidyLoading extends RenewSubsidyState {
  const RenewSubsidyLoading();
}

class RenewSubsidyClassLoading extends RenewSubsidyState {
  const RenewSubsidyClassLoading();
}

class RenewSubsidyLoaded extends RenewSubsidyState {
  final List<RenewSubsidyModel> subsidies;
  final List<CouponClassModel> classes;
  final Set<int> selectedIds;
  final String? selectedClassId;

  const RenewSubsidyLoaded({
    required this.subsidies,
    this.classes = const [],
    this.selectedIds = const {},
    this.selectedClassId,
  });

  /// 可用的换新补贴（未过期）
  List<RenewSubsidyModel> get availableSubsidies =>
      subsidies.where((s) => s.isAvailable && !s.isExpired && !s.isNotStarted).toList();

  /// 总补贴金额
  int get totalDiscount {
    return selectedIds
        .map((id) => subsidies.firstWhere((s) => s.subsidyId == id, orElse: () => subsidies.first))
        .fold<int>(0, (sum, s) => sum + s.discountValue);
  }

  int get selectedCount => selectedIds.length;

  RenewSubsidyLoaded copyWith({
    List<RenewSubsidyModel>? subsidies,
    List<CouponClassModel>? classes,
    Set<int>? selectedIds,
    String? selectedClassId,
  }) {
    return RenewSubsidyLoaded(
      subsidies: subsidies ?? this.subsidies,
      classes: classes ?? this.classes,
      selectedIds: selectedIds ?? this.selectedIds,
      selectedClassId: selectedClassId ?? this.selectedClassId,
    );
  }

  @override
  List<Object?> get props => [subsidies, classes, selectedIds, selectedClassId];
}

class RenewSubsidyClassLoaded extends RenewSubsidyState {
  final List<CouponClassModel> classes;
  final List<RenewSubsidyModel> subsidies;

  const RenewSubsidyClassLoaded({
    required this.classes,
    this.subsidies = const [],
  });

  @override
  List<Object?> get props => [classes, subsidies];
}

class RenewSubsidyError extends RenewSubsidyState {
  final String message;
  const RenewSubsidyError(this.message);
  @override
  List<Object?> get props => [message];
}

/// 换新补贴 Bloc
class RenewSubsidyBloc extends Bloc<RenewSubsidyEvent, RenewSubsidyState> {
  final RenewSubsidyRemoteDataSource _dataSource;

  RenewSubsidyBloc({required RenewSubsidyRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const RenewSubsidyInitial()) {
    on<RenewSubsidyLoadRequested>(_onLoadRequested);
    on<RenewSubsidyLoadClassRequested>(_onLoadClassRequested);
    on<RenewSubsidySelectionToggled>(_onSelectionToggled);
  }

  Future<void> _onLoadRequested(
    RenewSubsidyLoadRequested event,
    Emitter<RenewSubsidyState> emit,
  ) async {
    emit(const RenewSubsidyLoading());

    Result<List<RenewSubsidyModel>> result;
    if (event.classId != null) {
      result = await _dataSource.getAvailableCouponClass(event.classId!);
    } else {
      result = await _dataSource.getAvailableRenewSubsidies();
    }

    if (result.isFailure) {
      emit(RenewSubsidyError(result.failure!.message));
      return;
    }

    emit(RenewSubsidyLoaded(subsidies: result.value!));
  }

  Future<void> _onLoadClassRequested(
    RenewSubsidyLoadClassRequested event,
    Emitter<RenewSubsidyState> emit,
  ) async {
    emit(const RenewSubsidyClassLoading());

    final classResult = await _dataSource.getCouponClassList();
    if (classResult.isFailure) {
      emit(RenewSubsidyError(classResult.failure!.message));
      return;
    }

    final classList = classResult.value!;

    // 加载第一个分类的补贴
    if (classList.isNotEmpty) {
      final subsidyResult = await _dataSource.getAvailableCouponClass(classList.first.classId.toString());
      final subsidies = subsidyResult.isSuccess ? subsidyResult.value! : <RenewSubsidyModel>[];
      emit(RenewSubsidyClassLoaded(classes: classList, subsidies: subsidies));
    } else {
      emit(RenewSubsidyClassLoaded(classes: classList));
    }
  }

  void _onSelectionToggled(
    RenewSubsidySelectionToggled event,
    Emitter<RenewSubsidyState> emit,
  ) {
    final currentState = state;
    if (currentState is! RenewSubsidyLoaded) return;

    final newSelectedIds = Set<int>.from(currentState.selectedIds);
    if (newSelectedIds.contains(event.subsidy.subsidyId)) {
      newSelectedIds.remove(event.subsidy.subsidyId);
    } else {
      newSelectedIds.add(event.subsidy.subsidyId);
    }

    emit(currentState.copyWith(selectedIds: newSelectedIds));
  }
}