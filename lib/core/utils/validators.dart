import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../constants/app_strings.dart';

/// كلاس التحقق من صحة المدخلات في تطبيق سوالف.
/// كل دالّة تأخذ `BuildContext` لاشتقاق الرسائل من [AppLocalizations].
class Validators {
  Validators._();

  static final RegExp _usernameRegex = RegExp(r'^[a-z0-9_]+$');
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  /// التحقق من صحة اسم المستخدم.
  /// يقبل فقط: حروف صغيرة، أرقام، وشرطة سفلية. الطول 3-20.
  static String? validateUsername(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.usernameRequired;
    final trimmed = value.trim();
    if (trimmed.length < 3) return l10n.usernameTooShort;
    if (trimmed.length > 20) return l10n.usernameTooLong;
    if (!_usernameRegex.hasMatch(trimmed)) return l10n.usernameInvalid;
    if (AppStrings.reservedUsernames.contains(trimmed)) {
      return l10n.usernameReserved;
    }
    return null;
  }

  /// تطبيع اسم المستخدم: حذف @ والمسافات وتحويل للحروف الصغيرة.
  /// (Pure helper — لا يحتاج context.)
  static String normalizeUsername(String value) {
    return value.trim().toLowerCase().replaceAll('@', '');
  }

  /// التحقق من صحة البريد الإلكتروني.
  static String? validateEmail(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.emailRequired;
    if (!_emailRegex.hasMatch(value.trim())) return l10n.invalidEmail;
    return null;
  }

  /// التحقق من صحة كلمة المرور.
  static String? validatePassword(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordTooShort;
    return null;
  }

  /// التحقق من صحة الاسم.
  static String? validateName(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.nameRequired;
    if (value.trim().length < 2) return l10n.nameTooShort;
    return null;
  }

  /// التحقق من تأكيد كلمة المرور.
  static String? validateConfirmPassword(
      String? value, String? password, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) return l10n.confirmPasswordRequired;
    if (value != password) return l10n.passwordsDontMatch;
    return null;
  }

  /// التحقق من أن الحقل غير فارغ.
  static String? validateRequired(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
    return null;
  }
}
