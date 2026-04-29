import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../constants/app_strings.dart';

/// يُحوِّل علامات النظام (markers) المخزّنة في Firestore إلى نصوص مترجمة
/// وفق لغة الواجهة الحالية. للنصوص العادية يُرجع القيمة كما هي.
///
/// التوافقية الخلفية: لو كانت Firestore تحتوي رسائل قديمة بالنص العربي
/// ("تم إنشاء المجموعة" / "تم حذف هذه الرسالة")، نتعرّف عليها
/// ونترجمها أيضاً، فلا تُكسر التجربة على البيانات السابقة.
class SystemMessageResolver {
  SystemMessageResolver._();

  static String resolve(String raw, BuildContext context) {
    if (raw.isEmpty) return raw;
    final l10n = AppLocalizations.of(context);

    if (raw == AppStrings.markerGroupCreated ||
        raw == 'تم إنشاء المجموعة') {
      return l10n.systemGroupCreated;
    }
    if (raw == AppStrings.markerMessageDeleted ||
        raw == 'تم حذف هذه الرسالة') {
      return l10n.messageDeleted;
    }
    return raw;
  }
}
