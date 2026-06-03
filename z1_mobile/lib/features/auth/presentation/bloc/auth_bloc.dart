import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/token_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

// ===== Events =====
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String mobilePhone;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.mobilePhone,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [mobilePhone, password, rememberMe];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// ===== States =====
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== BLoC =====
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _authDatasource;
  final TokenService _tokenService;

  AuthBloc({
    required AuthRemoteDataSource authDatasource,
    required TokenService tokenService,
  })  : _authDatasource = authDatasource,
        _tokenService = tokenService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isLoggedIn = _tokenService.isLoggedIn();
    if (isLoggedIn) {
      // TODO(用户信息持久化): 当前即使本地有 token 也 emit Unauthenticated，等价于"无法自动登录"。
      // 接入 AuthLocalDataSource.getUser 后改为：getUser() ?? 调 /user/self 拉取 → emit AuthAuthenticated(user)
      // 失败兜底再 emit AuthUnauthenticated
      emit(const AuthUnauthenticated());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final request = LoginRequest(
        mobilePhone: event.mobilePhone,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      final result = await _authDatasource.login(request);

      if (result.isFailure) {
        emit(AuthError(result.failure!.message));
        return;
      }
      
      final response = result.value!;
      await _tokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // 使用响应中的用户信息或模拟用户
      final user = AuthUser(
        userIdent: 999999999,
        mobilePhone: event.mobilePhone,
        realName: '用户',
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('登录失败: $e'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _tokenService.clearTokens();
    emit(const AuthUnauthenticated());
  }
}