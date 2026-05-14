import 'package:flutter/material.dart';

/// 字符串扩展
extension StringExtension on String {
  /// 是否为空或仅空白
  bool get isBlank => trim().isEmpty;

  /// 是否不为空
  bool get isNotBlank => !isBlank;

  /// 转为可选字符串（null 或空字符串转为 null）
  String? toNullable() => isEmpty ? null : this;
}

/// 空安全扩展
extension NullableStringExtension on String? {
  /// 是否为空或 null
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// 是否不为空且不为 null
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// 转为可选字符串
  String toOptional() => this ?? '';
}

/// DateTime 扩展
extension DateTimeExtension on DateTime {
  /// 格式化日期
  String get dateOnly => '$year-$month-$day';

  /// 格式化日期时间
  String get dateTime => '$dateOnly $hour:$minute';

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

/// List 扩展
extension ListExtension<T> on List<T> {
  /// 安全获取元素
  T? safeGet(int index) => index >= 0 && index < length ? this[index] : null;

  /// 判断是否为空
  bool get isNotEmpty => length > 0;
}

/// Map 扩展
extension MapExtension<K, V> on Map<K, V> {
  /// 安全获取值
  V? safeGet(K key) => containsKey(key) ? this[key] : null;
}

/// Context 扩展
extension ContextExtension on BuildContext {
  /// 获取主题
  ThemeData get theme => Theme.of(this);

  /// 获取文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 获取颜色主题
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 获取媒体查询数据
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 获取屏幕宽度
  double get screenWidth => mediaQuery.size.width;

  /// 获取屏幕高度
  double get screenHeight => mediaQuery.size.height;

  /// 判断是否是暗色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// 显示 Snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}