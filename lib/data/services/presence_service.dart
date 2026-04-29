import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_strings.dart';

/// خدمة تتبّع وجود المستخدم (Presence) في الوقت الفعلي.
///
/// لماذا Realtime Database بدلاً من Firestore؟
/// - RTDB يدعم `onDisconnect()` الذي يُنفَّذ عند انقطاع الجهاز فجأة:
///   إغلاق التطبيق بالقوة، انقطاع الشبكة، نفاد البطارية... كلها تُكتشف تلقائياً.
/// - Firestore لا يملك آلية موثوقة مكافئة لاكتشاف الانقطاعات المفاجئة.
///
/// مسار البيانات في RTDB:
///   /presence/{uid} = { isOnline: bool, lastSeen: ServerValue.timestamp }
///
/// نُحدِّث Firestore أيضاً لأن قائمة المحادثات تستعلم عن `users` و
/// تحتاج رؤية isOnline / lastSeen مباشرةً (RTDB لا يُستخدم في تلك القائمة).
class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DatabaseEvent>? _connectionSub;
  bool _initialized = false;

  /// تُستدعى مرة واحدة بعد المصادقة (من AuthGate أو لاحقاً).
  Future<void> initializePresence() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (kDebugMode) debugPrint('[Presence] no user, skip init');
      return;
    }
    if (_initialized) return;
    _initialized = true;
    if (kDebugMode) debugPrint('[Presence] init for $uid');

    final presenceRef = _rtdb.ref('presence/$uid');
    final connectedRef = _rtdb.ref('.info/connected');

    _connectionSub = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      if (!connected) {
        if (kDebugMode) debugPrint('[Presence] RTDB disconnected');
        return;
      }

      try {
        // سجِّل onDisconnect أولاً قبل تعليم online
        // كي نضمن وجود التعليمة على الخادم حتى لو انقطعنا فوراً.
        await presenceRef.onDisconnect().set({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
        });

        await presenceRef.set({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
        });

        await _mirrorToFirestore(uid, isOnline: true);
        if (kDebugMode) debugPrint('[Presence] online');
      } catch (e) {
        if (kDebugMode) debugPrint('[Presence] init error: $e');
      }
    });
  }

  /// تُستدعى عند تسجيل الخروج (لا للخلفية).
  Future<void> disposePresence() async {
    final uid = _auth.currentUser?.uid;
    if (kDebugMode) debugPrint('[Presence] dispose for $uid');

    await _connectionSub?.cancel();
    _connectionSub = null;
    _initialized = false;

    if (uid == null) return;
    try {
      await _rtdb.ref('presence/$uid').onDisconnect().cancel();
      await _rtdb.ref('presence/$uid').set({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
      await _mirrorToFirestore(uid, isOnline: false);
    } catch (e) {
      if (kDebugMode) debugPrint('[Presence] dispose error: $e');
    }
  }

  /// عند انتقال التطبيق إلى الخلفية.
  Future<void> setOffline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _rtdb.ref('presence/$uid').update({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
      await _mirrorToFirestore(uid, isOnline: false);
      if (kDebugMode) debugPrint('[Presence] offline (background)');
    } catch (e) {
      if (kDebugMode) debugPrint('[Presence] setOffline error: $e');
    }
  }

  /// عند عودة التطبيق إلى الواجهة.
  Future<void> setOnline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final presenceRef = _rtdb.ref('presence/$uid');
      // أعِد تسجيل onDisconnect لأنه قد يكون نُفِّذ.
      await presenceRef.onDisconnect().set({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
      await presenceRef.set({
        'isOnline': true,
        'lastSeen': ServerValue.timestamp,
      });
      await _mirrorToFirestore(uid, isOnline: true);
      if (kDebugMode) debugPrint('[Presence] online (foreground)');
    } catch (e) {
      if (kDebugMode) debugPrint('[Presence] setOnline error: $e');
    }
  }

  /// مراقبة وجود مستخدم محدّد عبر RTDB (تحديثات لحظية).
  Stream<UserPresence> watchUserPresence(String userId) {
    return _rtdb.ref('presence/$userId').onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) {
        return const UserPresence(isOnline: false, lastSeen: null);
      }
      final data = raw;
      final isOnline = data['isOnline'] as bool? ?? false;
      final ts = data['lastSeen'];
      DateTime? lastSeen;
      if (ts is int) {
        lastSeen = DateTime.fromMillisecondsSinceEpoch(ts);
      }
      return UserPresence(isOnline: isOnline, lastSeen: lastSeen);
    });
  }

  Future<void> _mirrorToFirestore(String uid, {required bool isOnline}) async {
    try {
      await _firestore.collection(AppStrings.colUsers).doc(uid).update({
        AppStrings.fieldIsOnline: isOnline,
        AppStrings.fieldLastSeen: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // قد تفشل إذا الوثيقة محذوفة (حساب محذوف) — تجاهل.
      if (kDebugMode) debugPrint('[Presence] firestore mirror error: $e');
    }
  }
}

/// قيمة وجود مستخدم في لحظة محدّدة.
class UserPresence {
  final bool isOnline;
  final DateTime? lastSeen;

  const UserPresence({required this.isOnline, this.lastSeen});
}
