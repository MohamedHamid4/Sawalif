import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

/// ViewModel لإدارة الحساب: تغيير كلمة المرور، تأكيد البريد، حذف الحساب
class AccountSettingsViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AccountSettingsViewModel({required AuthRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGoogleAccount => _repository.isGoogleAccount;
  bool get isEmailVerified => _repository.isEmailVerified;

  /// حذف الحساب - يحتاج كلمة المرور للحسابات بالإيميل
  /// أو إعادة مصادقة Google تلقائياً للحسابات بـ Google
  Future<bool> deleteAccount({String? password, required String uid}) async {
    _setLoading(true);
    try {
      bool reauth;
      if (isGoogleAccount) {
        reauth = await _repository.reauthenticateWithGoogle();
      } else {
        if (password == null || password.isEmpty) {
          throw Exception('password_required');
        }
        reauth = await _repository.reauthenticateWithPassword(password);
      }

      if (!reauth) {
        _error = 'reauth_failed';
        notifyListeners();
        return false;
      }

      await _repository.deleteAccount(uid);
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تغيير كلمة المرور - فقط للحسابات بالإيميل
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// إعادة إرسال رابط تأكيد البريد
  Future<bool> resendVerification() async {
    _setLoading(true);
    try {
      await _repository.sendEmailVerification();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// التحقق من حالة تأكيد البريد (يعيد تحميل البيانات)
  Future<bool> refreshEmailVerified() async {
    final verified = await _repository.checkEmailVerified();
    notifyListeners();
    return verified;
  }

  /// تحويل الخطأ لرمز موحّد قابل للترجمة
  String _parseError(Object e) {
    final str = e.toString().toLowerCase();
    if (str.contains('wrong_current_password')) return 'wrong_password';
    if (str.contains('reauth_failed')) return 'reauth_required';
    if (str.contains('weak-password') || str.contains('password_too_weak')) {
      return 'password_too_weak';
    }
    if (str.contains('requires_reauthentication')) return 'reauth_required';
    if (str.contains('password_required')) return 'wrong_password';
    return 'unknown_error';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
