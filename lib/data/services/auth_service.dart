import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// خدمة المصادقة - تتعامل مع Firebase Auth مباشرة
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// Stream لتغييرات حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// إنشاء حساب جديد
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// تسجيل الدخول بـ Google
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// إرسال بريد إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// تحديث اسم المستخدم
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  /// تحديث صورة المستخدم
  Future<void> updatePhotoUrl(String photoUrl) async {
    await _auth.currentUser?.updatePhotoURL(photoUrl);
  }

  /// تسجيل الخروج (يقتصر على Firebase Auth + Google)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ============= إعادة المصادقة =============

  /// إعادة المصادقة بكلمة المرور (للحسابات بالإيميل)
  Future<bool> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  /// إعادة المصادقة بـ Google (للحسابات بـ Google)
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user == null) return false;
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// هل الحساب الحالي حساب Google؟
  bool isGoogleAccount() {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  // ============= تغيير كلمة المرور =============

  /// تغيير كلمة المرور (يتطلب كلمة المرور الحالية لإعادة المصادقة)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_authenticated');

    final reauth = await reauthenticateWithPassword(currentPassword);
    if (!reauth) throw Exception('wrong_current_password');

    await user.updatePassword(newPassword);
  }

  // ============= تأكيد الإيميل =============

  /// إرسال رابط تأكيد البريد الإلكتروني
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_authenticated');
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  /// إعادة تحميل حالة الحساب والتحقق من تأكيد البريد
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// هل الإيميل مؤكد حالياً؟
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ============= حذف حساب Firebase Auth =============

  /// حذف حساب Firebase Auth الحالي
  /// يفشل بـ Exception('requires_reauthentication') إذا تطلب تسجيل دخول حديث
  Future<void> deleteCurrentAuthUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_authenticated');
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('requires_reauthentication');
      }
      rethrow;
    }
  }

  // ملاحظة: تحويل رمز الخطأ إلى رسالة مترجمة تمّ نقله إلى
  // [AuthViewModel.localizedError] ليعتمد على لغة الواجهة الحالية.
}
