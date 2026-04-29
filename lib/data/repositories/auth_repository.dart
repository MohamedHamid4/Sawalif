import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/onesignal_service.dart';

/// طبقة الوسيط بين AuthService وـ ViewModels
class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  final OneSignalService _oneSignalService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
    required NotificationService notificationService,
    required OneSignalService oneSignalService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _notificationService = notificationService,
        _oneSignalService = oneSignalService;

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// تسجيل الدخول بالإيميل
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    await _updateUserOnlineAndToken(user.uid);
    return await _firestoreService.getUser(user.uid);
  }

  /// التحقق من توفر اسم المستخدم
  Future<bool> isUsernameAvailable(String username) async {
    return await _firestoreService.isUsernameAvailable(username);
  }

  /// إنشاء حساب جديد
  /// يفشل بـ Exception('username_taken') إذا كان اسم المستخدم محجوزاً.
  Future<UserModel?> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    // 1. التحقق من توفر اسم المستخدم قبل إنشاء حساب Firebase Auth
    final available = await _firestoreService.isUsernameAvailable(username);
    if (!available) {
      throw Exception('username_taken');
    }

    // 2. إنشاء حساب Firebase Auth
    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    await _authService.updateDisplayName(name);

    final fcmToken = await _notificationService.getToken() ?? '';
    final newUser = UserModel(
      uid: user.uid,
      name: name,
      username: username,
      email: email,
      createdAt: DateTime.now(),
      isOnline: true,
      fcmToken: fcmToken,
    );

    // 3. حفظ المستخدم وحجز اسم المستخدم بشكل atomic
    await _firestoreService.saveUserWithUsername(newUser);
    return newUser;
  }

  /// تسجيل الدخول بـ Google
  Future<UserModel?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null) return null;

    final user = credential.user;
    if (user == null) return null;

    // تحقق إذا كان مستخدم جديد
    final existingUser = await _firestoreService.getUser(user.uid);
    final fcmToken = await _notificationService.getToken() ?? '';

    if (existingUser == null) {
      // Fallback لاسم العرض: محاولة استخدام بادئة الإيميل ثم نص محايد.
      // المستخدم يستطيع تعديله من شاشة "تعديل الملف الشخصي" لاحقاً.
      final fallbackName = user.email != null && user.email!.contains('@')
          ? user.email!.split('@').first
          : '';
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? fallbackName,
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
        isOnline: true,
        fcmToken: fcmToken,
      );
      await _firestoreService.saveUser(newUser);
      return newUser;
    }

    await _updateUserOnlineAndToken(user.uid);
    return existingUser.copyWith(isOnline: true, fcmToken: fcmToken);
  }

  /// إرسال بريد إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// تسجيل الخروج (legacy)
  Future<void> signOut(String uid) async {
    await signOutComplete(uid);
  }

  /// تسجيل خروج محسّن - يصفّر الحالة + يمسح FCM token + OneSignal + يخرج من Google
  Future<void> signOutComplete(String? uid) async {
    if (uid != null) {
      await _firestoreService.clearOnlineAndToken(uid);
    }
    await _oneSignalService.logout(uid);
    await _authService.signOut();
  }

  // ============= إدارة الحساب =============

  /// هل الحساب الحالي حساب Google؟
  bool get isGoogleAccount => _authService.isGoogleAccount();

  /// هل الإيميل مؤكد؟
  bool get isEmailVerified => _authService.isEmailVerified;

  Future<bool> reauthenticateWithPassword(String password) =>
      _authService.reauthenticateWithPassword(password);

  Future<bool> reauthenticateWithGoogle() =>
      _authService.reauthenticateWithGoogle();

  /// تغيير كلمة المرور (للحسابات بالإيميل)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// إرسال رابط تأكيد البريد
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  /// التحقق من تأكيد البريد (يعيد تحميل الحساب)
  Future<bool> checkEmailVerified() => _authService.checkEmailVerified();

  /// حذف الحساب بالكامل: Firestore ثم Firebase Auth ثم Google sign-out
  /// المتصل مسؤول عن إعادة المصادقة قبل النداء.
  Future<void> deleteAccount(String uid) async {
    // 1. حذف بيانات Firestore أولاً (المستخدم لا يزال مصادقاً عليه)
    await _firestoreService.deleteUserData(uid);
    // 2. حذف حساب Firebase Auth (قد يرمي requires_reauthentication)
    await _authService.deleteCurrentAuthUser();
    // 3. خروج من Google لتنظيف الجلسة
    await _authService.signOut();
  }

  /// تحديث حالة الاتصال والـ Token
  Future<void> _updateUserOnlineAndToken(String uid) async {
    final fcmToken = await _notificationService.getToken();
    await _firestoreService.updateOnlineStatus(uid, true);
    if (fcmToken != null) {
      await _firestoreService.updateFcmToken(uid, fcmToken);
    }
  }
}
