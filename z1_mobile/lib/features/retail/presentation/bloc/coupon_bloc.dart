import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/coupon_remote_datasource.dart';
import '../../data/models/coupon_model.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();
  @override
  List<Object?> get props => [];
}

class CouponLoadRequested extends CouponEvent {
  const CouponLoadRequested();
}

class CouponSelectionToggled extends CouponEvent {
  final CouponModel coupon;
  const CouponSelectionToggled(this.coupon);
  @override
  List<Object?> get props => [coupon];
}

class CouponConfirmSelection extends CouponEvent {
  const CouponConfirmSelection();
}

abstract class CouponState extends Equatable {
  const CouponState();
  @override
  List<Object?> get props => [];
}

class CouponInitial extends CouponState {
  const CouponInitial();
}

class CouponLoading extends CouponState {
  const CouponLoading();
}

class CouponLoaded extends CouponState {
  final List<CouponModel> coupons;
  final Set<int> selectedIds;

  const CouponLoaded({
    required this.coupons,
    this.selectedIds = const {},
  });

  List<CouponModel> get availableCoupons =>
      coupons.where((c) => c.isAvailable && !c.isExpired && !c.isNotStarted).toList();

  int get totalDiscount {
    return selectedIds
        .map((id) => coupons.firstWhere((c) => c.couponId == id, orElse: () => coupons.first))
        .where((c) => c.type == CouponType.fixed)
        .fold<int>(0, (sum, c) => sum + c.discountValue);
  }

  int get selectedCount => selectedIds.length;

  CouponLoaded copyWith({
    List<CouponModel>? coupons,
    Set<int>? selectedIds,
  }) {
    return CouponLoaded(
      coupons: coupons ?? this.coupons,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [coupons, selectedIds];
}

class CouponError extends CouponState {
  final String message;
  const CouponError(this.message);
  @override
  List<Object?> get props => [message];
}

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRemoteDataSource _dataSource;

  CouponBloc({required CouponRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const CouponInitial()) {
    on<CouponLoadRequested>(_onLoadRequested);
    on<CouponSelectionToggled>(_onSelectionToggled);
  }

  Future<void> _onLoadRequested(
    CouponLoadRequested event,
    Emitter<CouponState> emit,
  ) async {
    emit(const CouponLoading());

    final result = await _dataSource.getCoupons();

    if (result.isFailure) {
      emit(CouponError(result.failure!.message));
      return;
    }

    emit(CouponLoaded(coupons: result.value!));
  }

  void _onSelectionToggled(
    CouponSelectionToggled event,
    Emitter<CouponState> emit,
  ) {
    final currentState = state;
    if (currentState is! CouponLoaded) return;

    final newSelectedIds = Set<int>.from(currentState.selectedIds);
    if (newSelectedIds.contains(event.coupon.couponId)) {
      newSelectedIds.remove(event.coupon.couponId);
    } else {
      newSelectedIds.add(event.coupon.couponId);
    }

    emit(currentState.copyWith(selectedIds: newSelectedIds));
  }
}