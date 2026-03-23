import 'package:flutter/material.dart';

/// Minimal global theme notifier so budget_screen.dart compiles.
class _AppTheme extends ValueNotifier<ThemeMode> {
  _AppTheme() : super(ThemeMode.light);

  bool get isDark => value == ThemeMode.dark;

  void toggle() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}

final appTheme = _AppTheme();
