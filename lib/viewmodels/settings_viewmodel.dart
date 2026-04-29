import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_strings.dart';

/// ViewModel للإعدادات العامة
class SettingsViewModel extends ChangeNotifier {
  bool _notificationsEnabled = true;
  final String _appVersion = AppStrings.appVersion;

  SettingsViewModel() {
    _loadSettings();
  }

  bool get notificationsEnabled => _notificationsEnabled;
  String get appVersion => _appVersion;

  /// تبديل حالة الإشعارات
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.keyNotificationsEnabled, enabled);
  }

  /// تحميل الإعدادات
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled =
        prefs.getBool(AppStrings.keyNotificationsEnabled) ?? true;
    notifyListeners();
  }
}
