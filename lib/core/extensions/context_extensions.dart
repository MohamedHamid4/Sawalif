import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// امتدادات BuildContext لتسهيل الوصول
extension ContextExtensions on BuildContext {
  /// الحصول على حجم الشاشة
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// الحصول على الثيم
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// هل الوضع الداكن مفعّل؟
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// الحصول على الترجمات
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// هل اتجاه النص من اليمين لليسار؟
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// عرض SnackBar بسيط
  void showSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// الانتقال لشاشة باستخدام push
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// الانتقال لشاشة واستبدال الحالية
  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, void>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// الرجوع للشاشة السابقة
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// الانتقال لمسار مسمى
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// الانتقال لمسار مسمى واستبدال الحالية
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  /// مسح كل الشاشات والانتقال لمسار مسمى
  Future<T?> pushNamedAndClearAll<T>(String routeName) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
    );
  }
}
