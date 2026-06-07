import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/jwt_utils.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/session_remote_datasource.dart';
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
  final SessionRemoteDataSource _sessionDatasource;
  final TokenService _tokenService;

  AuthBloc({
    required AuthRemoteDataSource authDatasource,
    required SessionRemoteDataSource sessionDatasource,
    required TokenService tokenService,
  })  : _authDatasource = authDatasource,
        _sessionDatasource = sessionDatasource,
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
      final result = await _authDatasource.getUserInfo();
      if (result.isSuccess && result.value != null) {
        final user = result.value!;
        emit(AuthAuthenticated(user));
        emit(AuthAuthenticated(await _enrichSession(user)));
      } else {
        await _tokenService.clearTokens();
        emit(const AuthUnauthenticated());
      }
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
        permissionToken: response.permissionToken,
      );

      var user = response.user;
      if (user == null) {
        final userResult = await _authDatasource.getUserInfo();
        if (userResult.isSuccess) {
          user = userResult.value;
        }
      }

      if (user == null) {
        await _tokenService.clearTokens();
        emit(const AuthError('获取用户信息失败'));
        return;
      }

      // 两段式：先尽快进首页，再异步补齐部门/默认仓/权限包
      emit(AuthAuthenticated(user));
      emit(AuthAuthenticated(await _enrichSession(user)));
    } catch (e) {
      emit(AuthError('登录失败: $e'));
    }
  }

  /// 注入员工部门 / 默认仓 / 零售权限包 JWT。
  /// 任何一步失败都不阻断登录（token 才是硬条件），仅返回尽量补齐的 user。
  Future<AuthUser> _enrichSession(AuthUser user) async {
    try {
      final deptID = deptIDFromToken(_tokenService.getAccessToken());

      // 部门名称（首页门店显示；仅需 Authorization，独立于权限 JWT）
      String? deptName;
      if (deptID != null) {
        final dept = await _sessionDatasource.getDepartmentName(deptID);
        if (dept.isSuccess) deptName = dept.value;
      }

      // 1) 零售权限包 JWT（含 shopSaleAdd / GetWarehouseIDsByMainDeptID）
      String? permissionJwt;
      final grant = await _sessionDatasource
          .grantPermissionPackage(ApiEndpoints.permKeyShopSaleApply);
      if (grant.isSuccess && (grant.value?.isNotEmpty ?? false)) {
        permissionJwt = grant.value;
        await _tokenService.savePermissionFor(
          ApiEndpoints.permKeyShopSaleApply,
          permissionJwt!,
        );
      }

      // 2) 默认仓（需主部门 + 真实权限 JWT）
      int? defaultWarehouseID;
      if (deptID != null && permissionJwt != null) {
        final wh = await _sessionDatasource.getDefaultWarehouseByDept(
          deptID,
          permissionJwt: permissionJwt,
        );
        if (wh.isSuccess) defaultWarehouseID = wh.value;
      }

      return user.copyWith(
        deptID: deptID,
        deptName: deptName,
        defaultWarehouseID: defaultWarehouseID,
      );
    } catch (_) {
      return user;
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
