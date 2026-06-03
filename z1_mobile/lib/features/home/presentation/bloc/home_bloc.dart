import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/models/order_model.dart';
import '../../../auth/data/models/user_model.dart';

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

  HomeBloc({required HomeRemoteDataSource dataSource})
      : _dataSource = dataSource,
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
    final result = await _dataSource.getOrderList();

    if (result.isFailure) {
      emit(HomeError(result.failure!.message));
      return;
    }

    final orders = result.value!;
    final stats = HomeStats.fromOrders(orders);
    final recentOrders = orders.take(3).toList();

    // TODO(用户信息持久化): 当前显示硬编码占位用户。等 AuthBloc 提供已登录 user 后：
    // 1) HomeBloc 构造函数注入 AuthBloc 或 user provider
    // 2) 这里读取 AuthAuthenticated.user 并传给 HomeLoaded
    // 3) 删除 defaultUser 兜底
    const defaultUser = AuthUser(
      userIdent: 999999999,
      mobilePhone: '',
      realName: '用户',
    );

    emit(HomeLoaded(
      user: defaultUser,
      stats: stats,
      recentOrders: recentOrders,
    ));
  }
}