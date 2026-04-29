import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_strings.dart';
import '../models/story_model.dart';

/// خدمة الحالات (Stories) - تنشر/تستعرض/تحذف القصص
class StoriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _stories => _firestore.collection('stories');

  /// نشر حالة جديدة (تنتهي بعد 24 ساعة)
  Future<void> postStory({
    required String imageUrl,
    String? caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('not_authenticated');
    }

    if (kDebugMode) {
      debugPrint('[Stories] postStory uid=${user.uid} url=$imageUrl');
    }

    final userDoc =
        await _firestore.collection(AppStrings.colUsers).doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    final ref = await _stories.add({
      'userId': user.uid,
      'userName': userData[AppStrings.fieldName] ?? '',
      'userPhotoUrl': userData[AppStrings.fieldPhotoUrl] ?? '',
      'imageUrl': imageUrl,
      'caption': caption ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewedBy': <String>[],
    });

    if (kDebugMode) {
      debugPrint('[Stories] created docId=${ref.id}');
    }
  }

  /// مراقبة الحالات النشطة (لم تنتهِ صلاحيتها)
  Stream<List<StoryModel>> getActiveStories() {
    return _stories
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => StoryModel.fromFirestore(doc)).toList());
  }

  /// تعليم الحالة كمُشاهَدة من المستخدم الحالي
  Future<void> markAsViewed(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _stories.doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([user.uid]),
    });
  }

  /// حذف حالة (للمالك فقط - تُفرض عبر قواعد Firestore)
  Future<void> deleteStory(String storyId) async {
    await _stories.doc(storyId).delete();
  }

  /// تنظيف الحالات المنتهية للمستخدم الحالي
  Future<void> cleanupExpiredStories() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final expired = await _stories
        .where('userId', isEqualTo: user.uid)
        .where('expiresAt', isLessThan: Timestamp.now())
        .get();

    for (final doc in expired.docs) {
      try {
        await doc.reference.delete();
      } catch (_) {}
    }
  }
}
