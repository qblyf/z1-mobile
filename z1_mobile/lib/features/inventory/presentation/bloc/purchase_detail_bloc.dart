import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/purchase_remote_datasource.dart';
import '../../data/models/purchase_model.dart';

abstract class PurchaseDetailEvent extends Equatable {
  const PurchaseDetailEvent();
  @override
  List<Object?> get props => [];
}

class PurchaseDetailLoadRequested extends PurchaseDetailEvent {
  final int id;
  const PurchaseDetailLoadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class PurchaseDetailState extends Equatable {
  const PurchaseDetailState();
  @override
  List<Object?> get props => [];
}

class PurchaseDetailInitial extends PurchaseDetailState {
  const PurchaseDetailInitial();
}

class PurchaseDetailLoading extends PurchaseDetailState {
  const PurchaseDetailLoading();
}

class PurchaseDetailLoaded extends PurchaseDetailState {
  final PurchaseDetailModel purchase;
  const PurchaseDetailLoaded(this.purchase);
  @override
  List<Object?> get props => [purchase];
}

class PurchaseDetailError extends PurchaseDetailState {
  final String message;
  const PurchaseDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class PurchaseDetailBloc extends Bloc<PurchaseDetailEvent, PurchaseDetailState> {
  final PurchaseRemoteDataSource _dataSource;

  PurchaseDetailBloc({required PurchaseRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const PurchaseDetailInitial()) {
    on<PurchaseDetailLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    PurchaseDetailLoadRequested event,
    Emitter<PurchaseDetailState> emit,
  ) async {
    emit(const PurchaseDetailLoading());

    final result = await _dataSource.getPurchaseDetail(event.id);

    if (result.isFailure) {
      emit(PurchaseDetailError(result.failure!.message));
      return;
    }

    emit(PurchaseDetailLoaded(result.value!));
  }
}