import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants/app_strings.dart';

/// معالج الرسائل في الخلفية (يجب أن يكون top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService._instance._showLocalNotification(message);
}

/// خدمة الإشعارات - FCM + Local Notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    // طلب الإذن
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // إعداد الإشعارات المحلية
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // إنشاء قناة الإشعار للـ Android
    const androidChannel = AndroidNotificationChannel(
      AppStrings.notifChannelId,
      AppStrings.notifChannelName,
      description: AppStrings.notifChannelDesc,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // معالجة الرسائل عند فتح التطبيق من إشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // معالجة الرسائل أثناء تشغيل التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // معالجة الرسائل في الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// الحصول على FCM token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  /// مراقبة تحديث الـ Token
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// عرض إشعار محلي
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppStrings.notifChannelId,
          AppStrings.notifChannelName,
          channelDescription: AppStrings.notifChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// معالجة فتح التطبيق من الإشعار
  void _handleMessageOpenedApp(RemoteMessage message) {
    // يمكن هنا التعامل مع الانتقال للمحادثة المناسبة
  }
}
