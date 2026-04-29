/// امتدادات String لتسهيل العمليات النصية
extension StringExtensions on String {
  /// هل النص يحتوي على عربي؟
  bool get isArabic => RegExp(r'[؀-ۿ]').hasMatch(this);

  /// الحصول على الأحرف الأولى (للافتار)
  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// تحويل للـ camelCase
  String get toCamelCase {
    final words = split(' ');
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join('');
  }

  /// اختصار النص بعد عدد معين من الأحرف
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// إزالة المسافات الزائدة
  String get cleanSpaces => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// هل النص بريد إلكتروني صالح؟
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);

  /// هل النص فارغ أو null؟
  bool get isNullOrEmpty => isEmpty;
}

extension NullableStringExtensions on String? {
  /// هل النص null أو فارغ؟
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// قيمة افتراضية إذا كان null أو فارغ
  String orDefault(String defaultValue) =>
      (this == null || this!.isEmpty) ? defaultValue : this!;
}
