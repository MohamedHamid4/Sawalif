import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// مدير الثيم الموحد لتطبيق سوالف
class AppThemes {
  AppThemes._();

  static ThemeData light(String fontFamily) => LightTheme.theme(fontFamily);
  static ThemeData dark(String fontFamily) => DarkTheme.theme(fontFamily);
}
