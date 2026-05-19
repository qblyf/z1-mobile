# 测试配置

## 测试运行命令

```bash
# 运行所有测试
flutter test

# 运行单元测试
flutter test test/unit/

# 运行 Widget 测试
flutter test test/widget/

# 生成覆盖率报告
flutter test --coverage

# 查看覆盖率详情
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 测试覆盖目标

- **核心业务逻辑（BLoC/Repository）**: 80%+
- **Widget 测试**: 关键页面覆盖
- **集成测试**: 核心流程

## Mock 策略

使用 `mocktail` 进行依赖 Mock：
- `MockAuthRemoteDataSource` - Mock API 调用
- `MockTokenService` - Mock Token 存储
- `MockSharedPreferences` - Mock 本地存储

## 注意事项

1. 所有 async 方法需要 `setUpAll` 注册 fallback values
2. 使用 `blocTest` 进行 BLoC 测试
3. Widget 测试使用 `MockBloc` 隔离 BLoC