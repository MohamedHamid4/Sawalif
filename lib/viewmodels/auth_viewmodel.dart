import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../l10n/app_localizations.dart';

/// حالة المصادقة
enum AuthState { idle, loading, success, error }

/// ViewModel للمصادقة - تسجيل الدخول والتسجيل وإدارة الجلسة
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository;

  // ===== الحالة =====
  AuthState _state = AuthState.idle;
  UserModel? _currentUser;
  // نخزّن رمز خطأ موحّد بدلاً من سلسلة عربية، ونترجمه عند العرض
  // عبر [localizedError]. هذا يسمح للواجهة الإنجليزية برؤية رسائل
  // إنجليزية والعربية رسائل عربية من نفس مصدر الحالة.
  String? _errorCode;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ===== Getters =====
  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorCode => _errorCode;
  bool get isLoading => _state == AuthState.loading;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoggedIn => _repository.currentUser != null;
  String? get currentUid => _repository.currentUser?.uid;
  Stream get authStateChanges => _repository.authStateChanges;

  /// رسالة خطأ مترجمة بحسب اللغة الحالية. تُستخدم في الـ Views
  /// التي تعرض الخطأ للمستخدم عبر SnackBar.
  String localizedError(BuildContext context) {
    final code = _errorCode;
    if (code == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'username_taken':
        return l10n.usernameTaken;
      case 'username_required':
        return l10n.usernameRequired;
      case 'user-not-found':
        return l10n.authUserNotFound;
      case 'wrong-password':
        return l10n.wrongPassword;
      case 'email-already-in-use':
        return l10n.authEmailInUse;
      case 'weak-password':
        return l10n.passwordTooWeak;
      case 'invalid-email':
        return l10n.invalidEmail;
      case 'network-request-failed':
        return l10n.errorNoInternet;
      case 'too-many-requests':
        return l10n.authTooManyRequests;
      case 'user-disabled':
        return l10n.authUserDisabled;
      case 'invalid-credential':
        return l10n.authInvalidCredential;
      default:
        return l10n.errorUnknown;
    }
  }

  /// تسجيل الدخول بالإيميل
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  /// إنشاء حساب جديد
  Future<bool> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _repository.signUp(
        name: name,
        username: username,
        email: email,
        password: password,
      );
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  /// التحقق من توفر اسم المستخدم
  /// يُعيد رمي الخطأ - المستدعي يُقرّر كيف يعرض حالة "تعذّر التحقق"
  /// (إعادة `false` صامتة كانت تخفي خطأ permission-denied)
  Future<bool> isUsernameAvailable(String username) async {
    return await _repository.isUsernameAvailable(username);
  }

  /// تسجيل الدخول بـ Google
  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _repository.signInWithGoogle();
      if (_currentUser == null) {
        _setState(AuthState.idle);
        return false;
      }
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  /// إرسال بريد إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail(String email) async {
    _setState(AuthState.loading);
    try {
      await _repository.sendPasswordResetEmail(email);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    if (_currentUser == null) return;
    await _repository.signOut(_currentUser!.uid);
    _currentUser = null;
    _setState(AuthState.idle);
  }

  /// تعيين المستخدم الحالي من خارج الـ ViewModel
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  /// إعادة تعيين الحالة
  void resetState() {
    _state = AuthState.idle;
    _errorCode = null;
    notifyListeners();
  }

  // ===== Private Methods =====
  void _setState(AuthState state) {
    _state = state;
    if (state != AuthState.error) _errorCode = null;
    notifyListeners();
  }

  void _setError(String code) {
    _state = AuthState.error;
    _errorCode = code;
    notifyListeners();
  }

  /// يستخرج رمز خطأ موحّد من أي استثناء.
  /// لا نُترجم هنا — الترجمة في [localizedError] لتتبع لغة الواجهة الحالية.
  String _parseError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('username_taken')) return 'username_taken';
    if (errorStr.contains('username_required')) return 'username_required';
    // FirebaseAuthException يُسرَّد بصيغة "[firebase_auth/code] message"
    if (errorStr.contains('[')) {
      try {
        return errorStr
            .split('[')[1]
            .split(']')[0]
            .replaceAll('firebase_auth/', '');
      } catch (_) {
        // fallthrough
      }
    }
    return 'unknown';
  }
}
