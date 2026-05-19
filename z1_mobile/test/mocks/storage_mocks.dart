import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设置 Mock 初始化
void mockInit() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// 模拟 SharedPreferences
Future<MockSharedPreferences> mockSharedPreferences({
  Map<String, Object>? values,
}) async {
  SharedPreferences.setMockInitialValues(values ?? {});
  return MockSharedPreferences();
}

class MockSharedPreferences extends Mock implements SharedPreferences {}