import 'dart:io';
import '../../core/constants/app_strings.dart';
import 'imgbb_service.dart';

/// خدمة رفع الصور - تستخدم ImgBB كبديل مجاني لـ Firebase Storage
class StorageService {
  final ImgBBService _imgbb = ImgBBService();

  /// رفع صورة الملف الشخصي
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final url = await _imgbb.uploadImage(
      imageFile,
      name:
          '${AppStrings.storageProfileImages}_${uid}_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url == null) {
      // رسائل الاستثناءات بالإنجليزية للسجلّات والتشخيص
      // (المستخدم النهائي يرى رسائل مترجمة من طبقة الـ ViewModel/View).
      throw Exception('upload_profile_image_failed');
    }
    return url;
  }

  /// رفع صورة في المحادثة
  Future<String> uploadChatImage(String chatId, File imageFile) async {
    final url = await _imgbb.uploadImage(
      imageFile,
      name:
          '${AppStrings.storageChatImages}_${chatId}_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url == null) {
      throw Exception('upload_chat_image_failed');
    }
    return url;
  }

  /// رفع صورة المجموعة (يستخدم نفس مجلد chat_images)
  Future<String> uploadGroupImage(File imageFile) async {
    final url = await _imgbb.uploadImage(
      imageFile,
      name: 'group_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url == null) {
      throw Exception('upload_group_image_failed');
    }
    return url;
  }

  /// رفع صورة حالة (Story)
  Future<String> uploadStoryImage(File imageFile) async {
    final url = await _imgbb.uploadImage(
      imageFile,
      name: 'story_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url == null) {
      throw Exception('upload_story_image_failed');
    }
    return url;
  }
}
