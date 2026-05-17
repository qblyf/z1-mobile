import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/coin_discount_remote_datasource.dart';

abstract class CoinDiscountEvent extends Equatable {
  const CoinDiscountEvent();
  @override
  List<Object?> get props => [];
}

class CoinDiscountLoadRequested extends CoinDiscountEvent {
  final int customerIdent;
  final int orderAmount;
  const CoinDiscountLoadRequested({
    required this.customerIdent,
    required this.orderAmount,
  });
  @override
  List<Object?> get props => [customerIdent, orderAmount];
}

class CoinDiscountCalculateRequested extends CoinDiscountEvent {
  final int customerIdent;
  final int coins;
  final int orderAmount;
  const CoinDiscountCalculateRequested({
    required this.customerIdent,
    required this.coins,
    required this.orderAmount,
  });
  @override
  List<Object?> get props => [customerIdent, coins, orderAmount];
}

class CoinDiscountReset extends CoinDiscountEvent {
  const CoinDiscountReset();
}

abstract class CoinDiscountState extends Equatable {
  const CoinDiscountState();
  @override
  List<Object?> get props => [];
}

class CoinDiscountInitial extends CoinDiscountState {
  const CoinDiscountInitial();
}

class CoinDiscountLoading extends CoinDiscountState {
  const CoinDiscountLoading();
}

class CoinDiscountLoaded extends CoinDiscountState {
  final int availableCoins;
  final int selectedCoins;
  final int discountAmount;
  final bool isCalculated;

  const CoinDiscountLoaded({
    required this.availableCoins,
    this.selectedCoins = 0,
    this.discountAmount = 0,
    this.isCalculated = false,
  });

  CoinDiscountLoaded copyWith({
    int? availableCoins,
    int? selectedCoins,
    int? discountAmount,
    bool? isCalculated,
  }) {
    return CoinDiscountLoaded(
      availableCoins: availableCoins ?? this.availableCoins,
      selectedCoins: selectedCoins ?? this.selectedCoins,
      discountAmount: discountAmount ?? this.discountAmount,
      isCalculated: isCalculated ?? this.isCalculated,
    );
  }

  @override
  List<Object?> get props => [availableCoins, selectedCoins, discountAmount, isCalculated];
}

class CoinDiscountError extends CoinDiscountState {
  final String message;
  const CoinDiscountError(this.message);
  @override
  List<Object?> get props => [message];
}

class CoinDiscountBloc extends Bloc<CoinDiscountEvent, CoinDiscountState> {
  final CoinDiscountRemoteDataSource _dataSource;

  CoinDiscountBloc({required CoinDiscountRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const CoinDiscountInitial()) {
    on<CoinDiscountLoadRequested>(_onLoadRequested);
    on<CoinDiscountCalculateRequested>(_onCalculateRequested);
    on<CoinDiscountReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    CoinDiscountLoadRequested event,
    Emitter<CoinDiscountState> emit,
  ) async {
    emit(const CoinDiscountLoading());

    final result = await _dataSource.calculateCoinDiscount(
      customerIdent: event.customerIdent,
      coins: 0,
      orderAmount: event.orderAmount,
    );

    if (result.isFailure) {
      emit(CoinDiscountError(result.failure!.message));
      return;
    }

    final data = result.value!;
    emit(CoinDiscountLoaded(
      availableCoins: data.coins,
      selectedCoins: 0,
      discountAmount: 0,
      isCalculated: false,
    ));
  }

  Future<void> _onCalculateRequested(
    CoinDiscountCalculateRequested event,
    Emitter<CoinDiscountState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CoinDiscountLoaded) return;

    emit(currentState.copyWith(isCalculated: false));

    final result = await _dataSource.calculateCoinDiscount(
      customerIdent: event.customerIdent,
      coins: event.coins,
      orderAmount: event.orderAmount,
    );

    if (result.isFailure) {
      emit(CoinDiscountError(result.failure!.message));
      return;
    }

    final data = result.value!;
    emit(currentState.copyWith(
      selectedCoins: event.coins,
      discountAmount: data.discountAmount,
      isCalculated: true,
    ));
  }

  void _onReset(
    CoinDiscountReset event,
    Emitter<CoinDiscountState> emit,
  ) {
    final currentState = state;
    if (currentState is CoinDiscountLoaded) {
      emit(currentState.copyWith(
        selectedCoins: 0,
        discountAmount: 0,
        isCalculated: false,
      ));
    }
  }
}