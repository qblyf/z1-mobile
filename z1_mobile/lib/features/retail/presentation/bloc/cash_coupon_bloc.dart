import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/cash_coupon_remote_datasource.dart';
import '../../data/models/cash_coupon_model.dart';

/// 代金券事件
abstract class CashCouponEvent extends Equatable {
  const CashCouponEvent();
  @override
  List<Object?> get props => [];
}

/// 加载可用代金券
class CashCouponLoadRequested extends CashCouponEvent {
  const CashCouponLoadRequested();
}

/// 切换代金券选择
class CashCouponSelectionToggled extends CashCouponEvent {
  final CashCouponModel coupon;
  const CashCouponSelectionToggled(this.coupon);
  @override
  List<Object?> get props => [coupon];
}

/// 确认选择
class CashCouponConfirmSelection extends CashCouponEvent {
  const CashCouponConfirmSelection();
}

/// 代金券状态
abstract class CashCouponState extends Equatable {
  const CashCouponState();
  @override
  List<Object?> get props => [];
}

class CashCouponInitial extends CashCouponState {
  const CashCouponInitial();
}

class CashCouponLoading extends CashCouponState {
  const CashCouponLoading();
}

class CashCouponLoaded extends CashCouponState {
  final List<CashCouponModel> coupons;
  final Set<int> selectedIds;

  const CashCouponLoaded({
    required this.coupons,
    this.selectedIds = const {},
  });

  /// 可用的代金券（未过期、未使用）
  List<CashCouponModel> get availableCoupons =>
      coupons.where((c) => c.isAvailable && !c.isExpired && !c.isNotStarted).toList();

  /// 总优惠金额
  int get totalDiscount {
    return selectedIds
        .map((id) => coupons.firstWhere((c) => c.couponId == id, orElse: () => coupons.first))
        .where((c) => c.type == CashCouponType.fixed)
        .fold<int>(0, (sum, c) => sum + c.discountValue);
  }

  int get selectedCount => selectedIds.length;

  CashCouponLoaded copyWith({
    List<CashCouponModel>? coupons,
    Set<int>? selectedIds,
  }) {
    return CashCouponLoaded(
      coupons: coupons ?? this.coupons,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [coupons, selectedIds];
}

class CashCouponError extends CashCouponState {
  final String message;
  const CashCouponError(this.message);
  @override
  List<Object?> get props => [message];
}

/// 代金券 Bloc
class CashCouponBloc extends Bloc<CashCouponEvent, CashCouponState> {
  final CashCouponRemoteDataSource _dataSource;

  CashCouponBloc({required CashCouponRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const CashCouponInitial()) {
    on<CashCouponLoadRequested>(_onLoadRequested);
    on<CashCouponSelectionToggled>(_onSelectionToggled);
  }

  Future<void> _onLoadRequested(
    CashCouponLoadRequested event,
    Emitter<CashCouponState> emit,
  ) async {
    emit(const CashCouponLoading());

    final result = await _dataSource.getAvailableCashCoupons();

    if (result.isFailure) {
      emit(CashCouponError(result.failure!.message));
      return;
    }

    emit(CashCouponLoaded(coupons: result.value!));
  }

  void _onSelectionToggled(
    CashCouponSelectionToggled event,
    Emitter<CashCouponState> emit,
  ) {
    final currentState = state;
    if (currentState is! CashCouponLoaded) return;

    final newSelectedIds = Set<int>.from(currentState.selectedIds);
    if (newSelectedIds.contains(event.coupon.couponId)) {
      newSelectedIds.remove(event.coupon.couponId);
    } else {
      newSelectedIds.add(event.coupon.couponId);
    }

    emit(currentState.copyWith(selectedIds: newSelectedIds));
  }
}