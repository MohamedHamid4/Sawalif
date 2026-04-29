import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_strings.dart';

/// ViewModel لإدارة اللغة (عربي/إنجليزي) مع RTL تلقائي
/// أول تشغيل: يكتشف لغة الجهاز. الاستخدام اللاحق: يحترم اختيار المستخدم.
class LocaleViewModel extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  /// الخط المناسب حسب اللغة الحالية
  String get fontFamily => isArabic ? 'Cairo' : 'Poppins';

  /// تهيئة اللغة - يتحقق من حفظها سابقاً، وإلا يستخدم لغة الجهاز
  /// يجب استدعاؤها قبل runApp()
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppStrings.keyLocale);

    if (saved != null && saved.isNotEmpty) {
      // استخدم اللغة المحفوظة من قبل المستخدم
      _locale = Locale(saved);
    } else {
      // أول تشغيل - اكتشف لغة الجهاز
      _locale = _detectDeviceLanguage();
      await prefs.setString(AppStrings.keyLocale, _locale.languageCode);
    }
    notifyListeners();
  }

  /// اكتشاف لغة الجهاز - يدعم العربي والإنجليزي فقط
  Locale _detectDeviceLanguage() {
    final deviceLocales = ui.PlatformDispatcher.instance.locales;
    if (deviceLocales.isEmpty) return const Locale('en');

    final deviceLang = deviceLocales.first.languageCode.toLowerCase();
    if (deviceLang == 'ar') return const Locale('ar');
    return const Locale('en');
  }

  /// تغيير اللغة وحفظها
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.keyLocale, newLocale.languageCode);
    notifyListeners();
  }

  /// تبديل بين العربي والإنجليزي
  Future<void> toggleLocale() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }

  /// إعادة للتعرف التلقائي على لغة الجهاز
  Future<void> resetToDeviceLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.keyLocale);
    _locale = _detectDeviceLanguage();
    await prefs.setString(AppStrings.keyLocale, _locale.languageCode);
    notifyListeners();
  }
}
