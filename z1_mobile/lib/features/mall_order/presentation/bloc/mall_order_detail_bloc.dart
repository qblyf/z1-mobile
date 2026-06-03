import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/mall_order_remote_datasource.dart';
import '../../data/models/mall_order_detail_model.dart';

// ============================================================================
// Events
// ============================================================================

abstract class MallOrderDetailEvent extends Equatable {
  const MallOrderDetailEvent();
  @override
  List<Object?> get props => [];
}

class MallOrderDetailLoadRequested extends MallOrderDetailEvent {
  final String number;
  const MallOrderDetailLoadRequested(this.number);
  @override
  List<Object?> get props => [number];
}

/// 重新加载当前订单（下拉刷新 / 错误重试）
class MallOrderDetailRefreshRequested extends MallOrderDetailEvent {
  const MallOrderDetailRefreshRequested();
}

// ============================================================================
// States
// ============================================================================

/// 详情 state 全部携带 number；这样 BLoC 不必持有可变字段，
/// 测试快照能完整对比。
abstract class MallOrderDetailState extends Equatable {
  /// 当前关注的订单号；Initial 时为空串。
  final String number;
  const MallOrderDetailState(this.number);
  @override
  List<Object?> get props => [number];
}

class MallOrderDetailInitial extends MallOrderDetailState {
  const MallOrderDetailInitial() : super('');
}

class MallOrderDetailLoading extends MallOrderDetailState {
  const MallOrderDetailLoading(super.number);
}

class MallOrderDetailLoaded extends MallOrderDetailState {
  final MallOrderDetailModel detail;
  MallOrderDetailLoaded(this.detail) : super(detail.summary.number);
  @override
  List<Object?> get props => [number, detail];
}

class MallOrderDetailError extends MallOrderDetailState {
  final String message;
  const MallOrderDetailError(super.number, this.message);
  @override
  List<Object?> get props => [number, message];
}

// ============================================================================
// BLoC
// ============================================================================

class MallOrderDetailBloc
    extends Bloc<MallOrderDetailEvent, MallOrderDetailState> {
  final MallOrderRemoteDataSource _dataSource;

  MallOrderDetailBloc({required MallOrderRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const MallOrderDetailInitial()) {
    on<MallOrderDetailLoadRequested>(_onLoadRequested);
    on<MallOrderDetailRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    MallOrderDetailLoadRequested event,
    Emitter<MallOrderDetailState> emit,
  ) =>
      _fetch(emit, event.number);

  Future<void> _onRefreshRequested(
    MallOrderDetailRefreshRequested event,
    Emitter<MallOrderDetailState> emit,
  ) async {
    final number = state.number;
    if (number.isEmpty) return;
    await _fetch(emit, number);
  }

  Future<void> _fetch(
    Emitter<MallOrderDetailState> emit,
    String number,
  ) async {
    emit(MallOrderDetailLoading(number));
    final result = await _dataSource.getMallOrderDetail(number);
    if (result.isFailure) {
      emit(MallOrderDetailError(number, result.failure!.message));
      return;
    }
    emit(MallOrderDetailLoaded(result.value!));
  }
}
