import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../l10n/app_localizations.dart';

/// ViewModel للملف الشخصي وتعديله
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository;

  ProfileViewModel({required UserRepository repository})
      : _repository = repository;

  // ===== الحالة =====
  UserModel? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorCode;
  File? _selectedImage;

  // ===== Getters =====
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorCode => _errorCode;
  File? get selectedImage => _selectedImage;

  /// رسالة خطأ مترجمة وفق لغة الواجهة الحالية.
  String localizedError(BuildContext context) {
    final code = _errorCode;
    if (code == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'load_failed':
        return l10n.errorLoading;
      case 'save_failed':
      default:
        return l10n.errorUnknown;
    }
  }

  /// تحميل بيانات المستخدم
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.getUser(uid);
    } catch (e) {
      _errorCode = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// مراقبة تحديثات المستخدم
  Stream<UserModel?> watchUser(String uid) {
    return _repository.watchCurrentUser(uid);
  }

  /// تعيين صورة مختارة
  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  /// حفظ التعديلات
  Future<bool> saveProfile({
    required String uid,
    required String name,
    required String bio,
  }) async {
    _isSaving = true;
    _errorCode = null;
    notifyListeners();

    try {
      _user = await _repository.updateProfile(
        uid: uid,
        name: name,
        bio: bio,
        newImageFile: _selectedImage,
        currentPhotoUrl: _user?.photoUrl,
      );
      _selectedImage = null;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorCode = 'save_failed';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث المستخدم المحلي
  void updateUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }
}
