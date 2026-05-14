import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// 认证 BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final ApiClient apiClient;

  AuthBloc({
    required this.authRepository,
    required this.apiClient,
  }) : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCleared>(_onCleared);

    // 启动时自动检查认证状态
    add(const AuthCheckRequested());
  }

  /// 检查认证状态
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final isAuthenticated = await authRepository.isAuthenticated();

    if (isAuthenticated) {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) {
          emit(const AuthState.unauthenticated());
        },
        (user) {
          emit(AuthState.authenticated(user: user));
        },
      );
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  /// 登录
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await authRepository.login(
      LoginParams(
        phone: event.account,
        pwd: event.password,
      ),
    );

    // fold 的回调可以是 async，需要 await fold 本身
    await result.fold(
      (failure) async {
        emit(AuthState.failure(message: failure.message));
      },
      (success) async {
        // 登录成功，获取用户信息
        final userResult = await authRepository.getCurrentUser();
        userResult.fold(
          (failure) {
            emit(const AuthState.authenticated());
          },
          (user) {
            emit(AuthState.authenticated(user: user));
          },
        );
      },
    );
  }

  /// 登出
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await authRepository.logout();

    result.fold(
      (failure) {
        emit(const AuthState.unauthenticated());
      },
      (success) {
        emit(const AuthState.unauthenticated());
      },
    );
  }

  /// 清除认证状态
  void _onCleared(
    AuthCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState.unauthenticated());
  }
}