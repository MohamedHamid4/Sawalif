import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

/// مساعد تنسيق التواريخ والأوقات في تطبيق سوالف.
///
/// كل دالة تأخذ `BuildContext` لاستنتاج اللغة الفعلية من
/// [AppLocalizations] بدلاً من الاعتماد على افتراض ثابت كان
/// يجعل واجهة الإنجليزية تعرض تواريخ بالعربية.
class DateFormatter {
  DateFormatter._();

  /// تنسيق وقت الرسالة (مثال: ٠٣:٤٥ م / 03:45 PM)
  static String formatMessageTime(DateTime dt, BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final code = isArabic ? 'ar' : 'en';
    final formatted = DateFormat('hh:mm a', code).format(dt);
    return isArabic ? _toArabicDigits(formatted) : formatted;
  }

  /// تنسيق "آخر ظهور" / آخر رسالة (نسبي ثم تاريخ كامل لو قديم)
  static String formatLastSeen(DateTime dt, BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final code = isArabic ? 'ar' : 'en';
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60) {
      return isArabic ? 'الآن' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      final n = diff.inMinutes;
      if (isArabic) {
        return _toArabicDigits('منذ $n ${_arPlural(n, 'دقيقة', 'دقيقتين', 'دقائق')}');
      }
      return n == 1 ? '1m ago' : '${n}m ago';
    }
    if (diff.inHours < 24) {
      final formatted = DateFormat('hh:mm a', code).format(dt);
      return isArabic ? _toArabicDigits(formatted) : formatted;
    }
    if (diff.inDays == 1) {
      return isArabic ? 'أمس' : 'Yesterday';
    }
    if (diff.inDays < 7) {
      // اسم اليوم ("Friday" / "الجمعة")
      return DateFormat('EEEE', code).format(dt);
    }
    final formatted = DateFormat('dd/MM/yyyy', code).format(dt);
    return isArabic ? _toArabicDigits(formatted) : formatted;
  }

  /// فاصل اليوم في المحادثة (اليوم / أمس / تاريخ كامل)
  static String formatDateDivider(DateTime dt, BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final code = isArabic ? 'ar' : 'en';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return isArabic ? 'اليوم' : 'Today';
    if (date == yesterday) return isArabic ? 'أمس' : 'Yesterday';

    final formatted = DateFormat('dd MMMM yyyy', code).format(dt);
    return isArabic ? _toArabicDigits(formatted) : formatted;
  }

  /// مقارنة هل يومان مختلفان
  static bool isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  /// جمع عربي مبسّط: 1 → مفرد، 2 → مثنى، 3-10 → جمع، 11+ → مفرد (تمييز نحوي).
  static String _arPlural(int n, String singular, String dual, String plural) {
    if (n == 1) return singular;
    if (n == 2) return dual;
    if (n >= 3 && n <= 10) return plural;
    return singular;
  }

  static String _toArabicDigits(String input) {
    const w = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const a = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var s = input;
    for (var i = 0; i < w.length; i++) {
      s = s.replaceAll(w[i], a[i]);
    }
    return s;
  }
}
