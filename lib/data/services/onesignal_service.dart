import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../core/constants/app_strings.dart';

/// 🔔 خدمة الإشعارات Push عبر OneSignal
///
/// ⚠️ تحذير أمني: REST API key مضمّنة في كود العميل، أي شخص يفك تشفير الـ APK
/// يستطيع استخراجها وإرسال إشعارات نيابة عنك. الحل الأنسب: proxy على خادم.
class OneSignalService {
  static const String _appId = '5d6addff-be80-4683-9aa9-db08263a7729';
  static const String _restApiKey =
      'os_v2_app_lvvn3756qbdihgvj3mecmotxfflsnn6bkmsubwutcq4dlqus7vp6xix5k5f66kszadj3id5i56ymg2zal5i5ptch2gduvohur2qcqrq';

  bool _initialized = false;

  /// تهيئة OneSignal عند بدء التطبيق - تستدعى مرة واحدة فقط
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    OneSignal.initialize(_appId);
    await OneSignal.Notifications.requestPermission(true);
    _setupNotificationHandlers();
  }

  /// ربط OneSignal بالمستخدم بعد تسجيل الدخول
  /// يحفظ Player ID في وثيقة المستخدم على Firestore
  Future<void> linkUser(String uid) async {
    try {
      await OneSignal.login(uid);
      // ننتظر قليلاً حتى يصبح Player ID متاحاً
      await Future.delayed(const Duration(seconds: 2));

      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null && playerId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(AppStrings.colUsers)
            .doc(uid)
            .update({AppStrings.fieldOneSignalId: playerId});
      }
    } catch (e) {
      if (kDebugMode) debugPrint('OneSignal link error: $e');
    }
  }

  void _setupNotificationHandlers() {
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data == null) return;

      final type = data['type'] as String?;
      final chatId = data['chatId'] as String?;

      // ملاحظة: التنقل من إشعار يحتاج navigator key عام؛ مؤجّل لتنفيذ لاحق
      if (kDebugMode) {
        debugPrint('Notification clicked: type=$type, chatId=$chatId');
      }
    });
  }

  /// إرسال إشعار لمستخدم معيّن (يستدعي REST API مباشرة)
  Future<void> sendNotificationToUser({
    required String receiverUid,
    required String title,
    required String message,
    String? chatId,
    String? senderName,
  }) async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection(AppStrings.colUsers)
          .doc(receiverUid)
          .get();

      final oneSignalId =
          receiverDoc.data()?[AppStrings.fieldOneSignalId] as String?;
      if (oneSignalId == null || oneSignalId.isEmpty) return;

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'include_player_ids': [oneSignalId],
          'headings': {'en': title, 'ar': title},
          'contents': {'en': message, 'ar': message},
          'data': {
            'type': 'message',
            'chatId': chatId,
            'senderName': senderName,
          },
          'android_channel_id': AppStrings.notifChannelId,
        }),
      );

      if (kDebugMode && response.statusCode != 200) {
        debugPrint(
            'OneSignal send failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to send notification: $e');
    }
  }

  /// تسجيل خروج OneSignal + مسح Player ID من Firestore
  Future<void> logout(String? uid) async {
    try {
      await OneSignal.logout();
    } catch (_) {}
    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection(AppStrings.colUsers)
            .doc(uid)
            .update({AppStrings.fieldOneSignalId: ''});
      } catch (_) {}
    }
  }
}

