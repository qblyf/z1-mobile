import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/transfer_remote_datasource.dart';
import '../../data/models/transfer_model.dart';

abstract class TransferDetailEvent extends Equatable {
  const TransferDetailEvent();
  @override
  List<Object?> get props => [];
}

class TransferDetailLoadRequested extends TransferDetailEvent {
  final int id;
  const TransferDetailLoadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class TransferDetailShippingRequested extends TransferDetailEvent {
  final int id;
  const TransferDetailShippingRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class TransferDetailReceivedRequested extends TransferDetailEvent {
  final int id;
  const TransferDetailReceivedRequested(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class TransferDetailState extends Equatable {
  const TransferDetailState();
  @override
  List<Object?> get props => [];
}

class TransferDetailInitial extends TransferDetailState {
  const TransferDetailInitial();
}

class TransferDetailLoading extends TransferDetailState {
  const TransferDetailLoading();
}

class TransferDetailLoaded extends TransferDetailState {
  final TransferDetailModel transfer;
  const TransferDetailLoaded(this.transfer);
  @override
  List<Object?> get props => [transfer];
}

class TransferDetailError extends TransferDetailState {
  final String message;
  const TransferDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransferDetailOperating extends TransferDetailState {
  final TransferDetailModel transfer;
  const TransferDetailOperating(this.transfer);
  @override
  List<Object?> get props => [transfer];
}

class TransferDetailOperationSuccess extends TransferDetailState {
  final String message;
  const TransferDetailOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TransferDetailBloc extends Bloc<TransferDetailEvent, TransferDetailState> {
  final TransferRemoteDataSource _dataSource;

  TransferDetailBloc({required TransferRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const TransferDetailInitial()) {
    on<TransferDetailLoadRequested>(_onLoad);
    on<TransferDetailShippingRequested>(_onShipping);
    on<TransferDetailReceivedRequested>(_onReceived);
  }

  Future<void> _onLoad(
    TransferDetailLoadRequested event,
    Emitter<TransferDetailState> emit,
  ) async {
    emit(const TransferDetailLoading());

    final result = await _dataSource.getTransferDetail(event.id);

    if (result.isFailure) {
      emit(TransferDetailError(result.failure!.message));
      return;
    }

    emit(TransferDetailLoaded(result.value!));
  }

  Future<void> _onShipping(
    TransferDetailShippingRequested event,
    Emitter<TransferDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransferDetailLoaded) return;

    emit(TransferDetailOperating(currentState.transfer));

    final result = await _dataSource.shipping(event.id);

    if (result.isFailure) {
      emit(TransferDetailLoaded(currentState.transfer));
      return;
    }

    emit(const TransferDetailOperationSuccess('已确认发货'));
    add(TransferDetailLoadRequested(event.id));
  }

  Future<void> _onReceived(
    TransferDetailReceivedRequested event,
    Emitter<TransferDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransferDetailLoaded) return;

    emit(TransferDetailOperating(currentState.transfer));

    final result = await _dataSource.received(event.id);

    if (result.isFailure) {
      emit(TransferDetailLoaded(currentState.transfer));
      return;
    }

    emit(const TransferDetailOperationSuccess('已确认入库'));
    add(TransferDetailLoadRequested(event.id));
  }
}