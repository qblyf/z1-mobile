import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z1_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z1_mobile/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  setUpAll(() {
    registerFallbackValue(const AuthLoginRequested(
      mobilePhone: '',
      password: '',
    ));
  });

  Widget createWidgetUnderTest() {
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer(
      (_) => Stream.value(const AuthInitial()),
    );

    return CupertinoApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('显示登录界面元素', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 验证标题（实际显示：掌上高远）
      expect(find.text('掌上高远'), findsOneWidget);
      expect(find.text('企业管理'), findsOneWidget);

      // 验证输入框（账号和密码）
      expect(find.byType(CupertinoTextField), findsNWidgets(2));

      // 验证登录按钮
      expect(find.text('登录'), findsOneWidget);
    });

    testWidgets('点击登录按钮时显示验证错误 - 空手机号', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 输入密码但不输入手机号
      final passwordField = find.byType(CupertinoTextField).last;
      await tester.enterText(passwordField, 'password123');

      // 点击登录
      await tester.tap(find.text('登录'));
      await tester.pumpAndSettle();

      // 验证弹窗提示（实际显示：账号和密码）
      expect(find.text('请输入账号和密码'), findsOneWidget);
    });

    testWidgets('登录成功发送 AuthLoginRequested 事件', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 输入正确的手机号和密码
      final phoneField = find.byType(CupertinoTextField).first;
      await tester.enterText(phoneField, '13800138000');

      final passwordField = find.byType(CupertinoTextField).last;
      await tester.enterText(passwordField, 'password123');

      // 点击登录
      await tester.tap(find.text('登录'));
      await tester.pump();

      // 验证发送了正确的事件
      verify(() => mockAuthBloc.add(any(that: isA<AuthLoginRequested>()))).called(1);
    });

    testWidgets('加载状态时按钮显示 loading', (WidgetTester tester) async {
      // 创建新的 bloc，设置 Loading 状态
      final loadingBloc = MockAuthBloc();
      when(() => loadingBloc.state).thenReturn(const AuthLoading());
      when(() => loadingBloc.stream).thenAnswer(
        (_) => Stream.value(const AuthLoading()),
      );

      final widget = CupertinoApp(
        home: BlocProvider<AuthBloc>.value(
          value: loadingBloc,
          child: const LoginPage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      // 验证显示 loading 指示器
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      
      // 验证按钮 child 已切换为 loading 状态
      // 按钮中的 Text '登录' 应该不显示了
      expect(find.text('登录'), findsNothing);
    });

    testWidgets('记住我复选框切换', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 初始为未选中
      expect(find.byIcon(CupertinoIcons.square), findsOneWidget);

      // 点击切换
      await tester.tap(find.text('记住我'));
      await tester.pumpAndSettle();

      // 切换后应为选中
      expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsOneWidget);
    });

    testWidgets('密码显示/隐藏切换', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 初始为隐藏密码 - 查找眼睛图标（可能在 suffix 中）
      final eyeIcons = find.byIcon(CupertinoIcons.eye);
      expect(eyeIcons, findsOneWidget);

      // 点击切换眼睛图标
      await tester.tap(eyeIcons);
      await tester.pumpAndSettle();

      // 切换后应为显示密码（眼睛斜线图标）
      expect(find.byIcon(CupertinoIcons.eye_slash), findsOneWidget);
    });
  });
}