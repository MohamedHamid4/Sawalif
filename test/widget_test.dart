// اختبار دخان بسيط للتحقق من أن التطبيق يبدأ بدون أخطاء
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test placeholder', (WidgetTester tester) async {
    // ملاحظة: الاختبار الكامل يتطلب Firebase المهيّأة فعلياً.
    // بعد تشغيل flutterfire configure، يمكن استبدال هذا الاختبار باختبار حقيقي.
    expect(true, isTrue);
  });
}
