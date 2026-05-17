import 'package:flutter_test/flutter_test.dart';

void main() {
  group('项目基础测试', () {
    test('测试框架正常工作', () {
      expect(true, isTrue);
    });

    test('Dart 基础功能正常', () {
      const name = 'Z1 Mobile';
      expect(name.isNotEmpty, true);
    });
  });
}