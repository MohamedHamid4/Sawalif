import 'dart:io';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// طبقة الوسيط لعمليات المستخدمين
class UserRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  UserRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  /// الحصول على مستخدم
  Future<UserModel?> getUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  /// مراقبة المستخدم الحالي
  Stream<UserModel?> watchCurrentUser(String uid) {
    return _firestoreService.watchUser(uid);
  }

  /// جلب كل المستخدمين
  Stream<List<UserModel>> watchAllUsers(String currentUid) {
    return _firestoreService.watchAllUsers(currentUid);
  }

  /// البحث عن مستخدمين بالاسم (legacy - تستخدمه شاشة قديمة)
  Future<List<UserModel>> searchUsers(String query, String currentUid) async {
    return await _firestoreService.searchUsers(query, currentUid);
  }

  /// إيجاد مستخدم بواسطة اسم المستخدم (@username)
  Future<UserModel?> findUserByUsername(String username) async {
    return await _firestoreService.findUserByUsername(username);
  }

  /// التحقق من توفر اسم المستخدم
  Future<bool> isUsernameAvailable(String username) async {
    return await _firestoreService.isUsernameAvailable(username);
  }

  /// تعيين اسم مستخدم لأول مرة (للمستخدمين القدامى الذين لم يكن لديهم اسم)
  Future<void> setUsername(String uid, String username) async {
    await _firestoreService.setUsernameForExistingUser(uid, username);
  }

  /// تحديث الملف الشخصي
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    required String bio,
    File? newImageFile,
    String? currentPhotoUrl,
  }) async {
    String photoUrl = currentPhotoUrl ?? '';

    if (newImageFile != null) {
      photoUrl = await _storageService.uploadProfileImage(uid, newImageFile);
    }

    await _firestoreService.updateUser(uid, {
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
    });

    final updatedUser = await _firestoreService.getUser(uid);
    return updatedUser!;
  }

  /// تحديث حالة الاتصال
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _firestoreService.updateOnlineStatus(uid, isOnline);
  }
}
