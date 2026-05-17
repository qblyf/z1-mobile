import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/member_remote_datasource.dart';
import '../../data/models/member_model.dart';
import '../../data/models/member_order_model.dart';

abstract class MemberDetailEvent extends Equatable {
  const MemberDetailEvent();
  @override
  List<Object?> get props => [];
}

class MemberDetailLoadRequested extends MemberDetailEvent {
  final int memberId;
  const MemberDetailLoadRequested(this.memberId);
  @override
  List<Object?> get props => [memberId];
}

class MemberDetailRefreshRequested extends MemberDetailEvent {
  const MemberDetailRefreshRequested();
}

abstract class MemberDetailState extends Equatable {
  const MemberDetailState();
  @override
  List<Object?> get props => [];
}

class MemberDetailInitial extends MemberDetailState {
  const MemberDetailInitial();
}

class MemberDetailLoading extends MemberDetailState {
  const MemberDetailLoading();
}

class MemberDetailLoaded extends MemberDetailState {
  final MemberModel member;
  final List<MemberOrderModel> orders;
  final bool hasReachedMaxOrders;

  const MemberDetailLoaded({
    required this.member,
    this.orders = const [],
    this.hasReachedMaxOrders = false,
  });

  MemberDetailLoaded copyWith({
    MemberModel? member,
    List<MemberOrderModel>? orders,
    bool? hasReachedMaxOrders,
  }) {
    return MemberDetailLoaded(
      member: member ?? this.member,
      orders: orders ?? this.orders,
      hasReachedMaxOrders: hasReachedMaxOrders ?? this.hasReachedMaxOrders,
    );
  }

  @override
  List<Object?> get props => [member, orders, hasReachedMaxOrders];
}

class MemberDetailError extends MemberDetailState {
  final String message;
  const MemberDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class MemberDetailNotFound extends MemberDetailState {
  const MemberDetailNotFound();
}

class MemberDetailBloc extends Bloc<MemberDetailEvent, MemberDetailState> {
  final MemberRemoteDataSource _dataSource;
  int? _currentMemberId;

  MemberDetailBloc({required MemberRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const MemberDetailInitial()) {
    on<MemberDetailLoadRequested>(_onLoadRequested);
    on<MemberDetailRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    MemberDetailLoadRequested event,
    Emitter<MemberDetailState> emit,
  ) async {
    emit(const MemberDetailLoading());
    _currentMemberId = event.memberId;

    final memberResult = await _dataSource.getMemberDetail(event.memberId);

    if (memberResult.isFailure) {
      final message = memberResult.failure!.message;
      if (message.contains('404') || message.contains('不存在')) {
        emit(const MemberDetailNotFound());
      } else {
        emit(MemberDetailError(message));
      }
      return;
    }

    final member = memberResult.value!;
    final ordersResult = await _dataSource.getMemberOrders(event.memberId);

    List<MemberOrderModel> orders = [];
    bool hasReachedMax = false;

    if (ordersResult.isSuccess) {
      orders = ordersResult.value!;
      hasReachedMax = orders.length < 20;
    }

    emit(MemberDetailLoaded(
      member: member,
      orders: orders,
      hasReachedMaxOrders: hasReachedMax,
    ));
  }

  Future<void> _onRefreshRequested(
    MemberDetailRefreshRequested event,
    Emitter<MemberDetailState> emit,
  ) async {
    if (_currentMemberId != null) {
      add(MemberDetailLoadRequested(_currentMemberId!));
    }
  }
}