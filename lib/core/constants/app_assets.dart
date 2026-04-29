/// مسارات الأصول (الصور والأنيميشنز) في تطبيق سوالف
///
/// ملاحظة: قم بتنزيل ملفات Lottie المجانية من lottiefiles.com
/// وضعها في مجلد assets/animations/ بالأسماء التالية:
///   - onboarding_chat.json     (شاشة تعريف 1 - محادثة)
///   - onboarding_connect.json  (شاشة تعريف 2 - تواصل)
///   - onboarding_secure.json   (شاشة تعريف 3 - أمان)
///   - empty_chats.json         (حالة لا توجد محادثات)
///   - empty_messages.json      (حالة لا توجد رسائل)
///   - loading.json             (تحميل عام)
class AppAssets {
  AppAssets._();

  // ===== مسار الأصول الجذر =====
  static const String _images = 'assets/images/';
  static const String _animations = 'assets/animations/';

  // ===== الصور =====
  static const String logo = '${_images}logo.png';
  static const String logoWhite = '${_images}logo_white.png';
  static const String googleIcon = '${_images}google_icon.png';

  // ===== أنيميشنز Lottie =====
  // شاشات التعريف (Onboarding)
  static const String onboardingChat = '${_animations}onboarding_chat.json';
  static const String onboardingConnect = '${_animations}onboarding_connect.json';
  static const String onboardingSecure = '${_animations}onboarding_secure.json';

  // حالات فارغة (Empty States)
  static const String emptyChats = '${_animations}empty_chats.json';
  static const String emptyMessages = '${_animations}empty_messages.json';
  static const String emptySearch = '${_animations}empty_search.json';

  // تحميل عام
  static const String loading = '${_animations}loading.json';
}
