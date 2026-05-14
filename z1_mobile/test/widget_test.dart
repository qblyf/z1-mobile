import 'package:flutter_test/flutter_test.dart';

import 'package:z1_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(const Z1App());

    // 等待初始化
    await tester.pump();

    // 验证应用渲染
    expect(find.text('Z1 全网连锁'), findsOneWidget);
  });
}