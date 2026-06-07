import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/models/order_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// ===== Events =====
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

// ===== States =====
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final AuthUser user;
  final HomeStats stats;
  final List<OrderModel> recentOrders;

  const HomeLoaded({
    required this.user,
    required this.stats,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [user, stats, recentOrders];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== BLoC =====
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRemoteDataSource _dataSource;
  final AuthBloc _authBloc;

  HomeBloc({
    required HomeRemoteDataSource dataSource,
    required AuthBloc authBloc,
  })  : _dataSource = dataSource,
        _authBloc = authBloc,
        super(const HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
  }

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const HomeError('未登录'));
      return;
    }
    final AuthUser user = authState.user;

    final result = await _dataSource.getOrderList();

    if (result.isFailure) {
      emit(HomeError(result.failure!.message));
      return;
    }

    final orders = result.value!;
    final stats = HomeStats.fromOrders(orders);
    final recentOrders = orders.take(3).toList();

    emit(HomeLoaded(
      user: user,
      stats: stats,
      recentOrders: recentOrders,
    ));
  }
}