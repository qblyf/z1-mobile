// ignore_for_file: avoid_print
// 集成测试调试输出走 print，便于 `flutter test` 控制台直读。

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:z1_mobile/core/api/api_endpoints.dart';
import 'package:z1_mobile/features/auth/data/models/user_model.dart';
import 'package:z1_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z1_mobile/core/api/result.dart';

/// 登录功能测试
/// 
/// 测试场景：
/// 1. 验证 API 请求参数格式
/// 2. 验证响应解析
/// 3. 验证状态定义
/// 4. 真实 API 调用测试
void main() {
  group('登录功能测试', () {
    const testPhone = '99999999999';
    const testPassword = 'ncxSEpbZ\$20m\$W6O';

    test('验证 LoginRequest 参数格式正确', () {
      const request = LoginRequest(
        mobilePhone: testPhone,
        password: testPassword,
        rememberMe: false,
      );

      final json = request.toJson();

      expect(json['phone'], testPhone);
      expect(json['pwd'], testPassword);
      expect(json['remember_me'], false);
    });

    test('验证 API 端点路径正确', () {
      // 实际路径为 /members/phone-login
      expect(ApiEndpoints.login, '/members/phone-login');
    });

    test('验证 AuthUser.fromJson 能正确解析响应', () {
      final apiResponse = {
        'user_ident': 1,
        'real_name': '测试用户',
        'mobile_phone': testPhone,
        'email': 'test@example.com',
        'gender': 1,
        'coin': 100,
        'experience': 50,
        'grade': 1,
        'store_front_id': 10,
        'status': 1,
      };

      final user = AuthUser.fromJson(apiResponse);

      expect(user.userIdent, 1);
      expect(user.realName, '测试用户');
      expect(user.mobilePhone, testPhone);
      expect(user.email, 'test@example.com');
      expect(user.gender, 1);
      expect(user.coin, 100);
    });

    test('验证 LoginResponse 能正确解析 API 响应', () {
      final apiResponse = {
        'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test',
        'refresh_token': 'refresh_token_here',
        'expires_in': 604800,
        'user': {
          'user_ident': 1,
          'real_name': '测试用户',
          'mobile_phone': testPhone,
        },
      };

      final response = LoginResponse.fromJson(apiResponse);

      expect(response.accessToken, isNotEmpty);
      expect(response.refreshToken, isNotNull);
      expect(response.expiresIn, 604800);
      expect(response.user, isNotNull);
      expect(response.user!.userIdent, 1);
    });

    test('验证 AuthState 状态类型定义', () {
      const initial = AuthInitial();
      const loading = AuthLoading();
      const unauthenticated = AuthUnauthenticated();
      const error = AuthError('测试错误');

      expect(initial, isA<AuthState>());
      expect(loading, isA<AuthState>());
      expect(unauthenticated, isA<AuthState>());
      expect(error, isA<AuthState>());
      expect(error.message, '测试错误');
    });

    test('验证 Result 类型的行为', () {
      const successResult = Success<String>('test_token');
      expect(successResult.isSuccess, true);
      expect(successResult.isFailure, false);
      expect(successResult.value, 'test_token');

      const failureResult = Failure<String>(
        ApiFailure(
          type: ApiErrorType.unauthorized,
          message: '登录失败',
        ),
      );
      expect(failureResult.isSuccess, false);
      expect(failureResult.isFailure, true);
      expect(failureResult.value, isNull);
      expect(failureResult.failure.message, '登录失败');
    });

    test('验证 TokenModel 过期检测逻辑', () {
      final validToken = TokenModel(
        accessToken: 'token123',
        refreshToken: 'refresh456',
        expiresIn: 3600,
        createdAt: DateTime.now(),
      );
      expect(validToken.isExpired, false);

      final expiredToken = TokenModel(
        accessToken: 'token123',
        refreshToken: 'refresh456',
        expiresIn: -1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(expiredToken.isExpired, true);
    });

    test('验证手机号正则验证逻辑', () {
      // 有效的中国手机号：必须以 1 开头，第二位是 3-9
      expect(RegExp(r'^1[3-9]\d{9}$').hasMatch('13800138000'), true);
      expect(RegExp(r'^1[3-9]\d{9}$').hasMatch('15912345678'), true);
      expect(RegExp(r'^1[3-9]\d{9}$').hasMatch('19912345678'), true);
      expect(RegExp(r'^1[3-9]\d{9}$').hasMatch('12345678901'), false); // 2开头无效
      expect(RegExp(r'^1[3-9]\d{9}$').hasMatch('123456'), false); // 太短
      expect(RegExp(r'^1[3-9]\d{9}$').hasMatch(''), false); // 空
    });

    test('【真实 API 测试】登录请求', () async {
      print('\n========== 登录功能真实 API 测试 ==========');
      print('API 地址: https://z1-fun.zsqk.com.cn/deno/members/phone-login');
      print('手机号: $testPhone');
      print('密码: [已隐藏]');

      final dio = Dio(BaseOptions(
        baseUrl: 'https://z1-fun.zsqk.com.cn/deno',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      try {
        final response = await dio.post(
          '/members/phone-login',
          data: {
            'phone': testPhone,
            'pwd': testPassword,
          },
        );

        print('\n✓ 响应状态码: ${response.statusCode}');
        print('✓ 响应数据: ${response.data}');

        // 解析 token
        final token = response.data['res']?['token'];
        if (token != null) {
          print('✓ Token 解析成功: ${token.toString().substring(0, 30)}...');
        }
        
        // 解析用户信息
        final user = response.data['res'];
        if (user != null) {
          print('✓ 登录成功!');
        }
      } on DioException catch (e) {
        print('\n✗ API 请求失败:');
        print('  错误类型: ${e.type}');
        print('  错误消息: ${e.message}');
        
        if (e.response != null) {
          print('  HTTP 状态码: ${e.response?.statusCode}');
          print('  响应数据: ${e.response?.data}');
        }
      }

      print('========== 测试结束 ==========\n');
    }, tags: ['integration', 'real-api']);
  });
}