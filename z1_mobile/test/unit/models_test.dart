import 'package:flutter_test/flutter_test.dart';
import 'package:z1_mobile/core/api/result.dart';
import 'package:z1_mobile/features/auth/data/models/user_model.dart';

void main() {
  group('Result 类型测试', () {
    test('Success 包含正确的值', () {
      const user = AuthUser(
        userIdent: 1,
        realName: 'Test',
        mobilePhone: '13800138000',
      );
      const result = Success<AuthUser>(user);

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value.userIdent, 1);
      expect(result.failure, isNull);
    });

    test('Failure 包含错误信息', () {
      const failure = ApiFailure(
        type: ApiErrorType.serverError,
        message: '服务器错误',
        statusCode: 500,
      );
      const result = Failure<AuthUser>(failure);

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.value, isNull);
      expect(result.failure.message, '服务器错误');
    });

    test('fold 方法正确路由', () {
      const user = AuthUser(
        userIdent: 1,
        realName: 'Test',
        mobilePhone: '13800138000',
      );
      const successResult = Success<AuthUser>(user);

      final successValue = successResult.fold(
        (_) => 'error',
        (user) => user.realName,
      );
      expect(successValue, 'Test');

      final failureResult = Failure<AuthUser>(
        ApiFailure.serverError('服务器错误'),
      );
      final failureValue = failureResult.fold(
        (f) => f.message,
        (_) => 'success',
      );
      expect(failureValue, '服务器错误');
    });

    test('map 方法正确转换值', () {
      const user = AuthUser(
        userIdent: 1,
        realName: 'Test',
        mobilePhone: '13800138000',
      );
      const result = Success<AuthUser>(user);
      final mapped = result.map((u) => u.userIdent);

      expect(mapped.value, 1);
    });
  });

  group('ApiFailure 工厂方法测试', () {
    test('serverError 工厂方法', () {
      final failure = ApiFailure.serverError();
      expect(failure.type, ApiErrorType.serverError);
      expect(failure.message, '服务器错误');
    });

    test('networkError 工厂方法', () {
      final failure = ApiFailure.networkError();
      expect(failure.type, ApiErrorType.networkError);
      expect(failure.message, '网络错误');
    });

    test('unauthorized 工厂方法', () {
      final failure = ApiFailure.unauthorized('Token过期');
      expect(failure.type, ApiErrorType.unauthorized);
      expect(failure.message, 'Token过期');
    });

    test('validationError 工厂方法', () {
      final failure = ApiFailure.validationError('参数错误');
      expect(failure.type, ApiErrorType.validationError);
      expect(failure.message, '参数错误');
    });

    test('unknown 工厂方法', () {
      final failure = ApiFailure.unknown();
      expect(failure.type, ApiErrorType.unknown);
      expect(failure.message, '未知错误');
    });
  });

  group('AuthUser 测试', () {
    test('fromJson 正确解析 JSON', () {
      final json = {
        'user_ident': 1,
        'real_name': '张三',
        'mobile_phone': '13800138000',
        'email': 'test@example.com',
        'gender': 1,
        'coin': 100,
        'experience': 50,
        'grade': 1,
        'store_front_id': 10,
        'status': 1,
      };

      final user = AuthUser.fromJson(json);

      expect(user.userIdent, 1);
      expect(user.realName, '张三');
      expect(user.mobilePhone, '13800138000');
      expect(user.email, 'test@example.com');
      expect(user.gender, 1);
      expect(user.coin, 100);
      expect(user.status, 1);
    });

    test('fromJson 处理可选字段为 null', () {
      final json = {
        'user_ident': 2,
        'real_name': '王五',
        'mobile_phone': '13900139000',
      };

      final user = AuthUser.fromJson(json);

      expect(user.userIdent, 2);
      expect(user.realName, '王五');
      expect(user.mobilePhone, '13900139000');
      expect(user.email, isNull);
    });

    test('fromJson 使用默认值', () {
      final json = <String, dynamic>{};

      final user = AuthUser.fromJson(json);

      expect(user.userIdent, 0);
      expect(user.realName, '');
      expect(user.mobilePhone, '');
      expect(user.gender, 0);
      expect(user.coin, 0);
      expect(user.status, 1);
    });
  });

  group('LoginRequest 测试', () {
    test('toJson 正确序列化', () {
      const request = LoginRequest(
        mobilePhone: '13800138000',
        password: 'password123',
        rememberMe: true,
      );

      final json = request.toJson();

      expect(json['phone'], '13800138000');
      expect(json['pwd'], 'password123');
      expect(json['remember_me'], true);
    });
  });

  group('LoginResponse 测试', () {
    test('fromJson 正确解析', () {
      final json = {
        'access_token': 'token123',
        'refresh_token': 'refresh456',
        'expires_in': 3600,
        'user': {
          'user_ident': 1,
          'real_name': '用户',
          'mobile_phone': '13800138000',
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'token123');
      expect(response.refreshToken, 'refresh456');
      expect(response.expiresIn, 3600);
      expect(response.user, isNotNull);
      expect(response.user?.userIdent, 1);
    });

    test('fromJson 处理 user 为 null', () {
      final json = {
        'access_token': 'token123',
        'refresh_token': 'refresh456',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'token123');
      expect(response.user, isNull);
    });
  });

  group('TokenModel 测试', () {
    test('isExpired - 未过期', () {
      final token = TokenModel(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresIn: 3600,
        createdAt: DateTime.now(),
      );

      expect(token.isExpired, false);
    });

    test('isExpired - 已过期', () {
      final token = TokenModel(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresIn: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(token.isExpired, true);
    });

    test('fromJson 正确解析', () {
      final json = {
        'access_token': 'token123',
        'refresh_token': 'refresh456',
        'expires_in': 7200,
      };

      final token = TokenModel.fromJson(json);

      expect(token.accessToken, 'token123');
      expect(token.refreshToken, 'refresh456');
      expect(token.expiresIn, 7200);
    });
  });
}