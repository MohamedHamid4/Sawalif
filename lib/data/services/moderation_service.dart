import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_strings.dart';

/// خدمة الإشراف: حظر/إلغاء حظر المستخدمين، الإبلاغ
class ModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  Future<void> blockUser(String userIdToBlock) async {
    final uid = _currentUid;
    if (uid == null || uid == userIdToBlock) return;
    await _firestore
        .collection(AppStrings.colUsers)
        .doc(uid)
        .update({
      AppStrings.fieldBlockedUsers: FieldValue.arrayUnion([userIdToBlock]),
    });
  }

  Future<void> unblockUser(String userId) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _firestore
        .collection(AppStrings.colUsers)
        .doc(uid)
        .update({
      AppStrings.fieldBlockedUsers: FieldValue.arrayRemove([userId]),
    });
  }

  Future<bool> isUserBlocked(String userId) async {
    final uid = _currentUid;
    if (uid == null) return false;
    final doc =
        await _firestore.collection(AppStrings.colUsers).doc(uid).get();
    final blocked = List<String>.from(
        doc.data()?[AppStrings.fieldBlockedUsers] ?? []);
    return blocked.contains(userId);
  }

  Stream<List<String>> blockedUsersStream() {
    final uid = _currentUid;
    if (uid == null) return Stream.value(<String>[]);
    return _firestore
        .collection(AppStrings.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => List<String>.from(
            doc.data()?[AppStrings.fieldBlockedUsers] ?? []));
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? messageId,
    String? chatId,
    String? additionalDetails,
  }) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _firestore.collection('reports').add({
      'reporterId': uid,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'messageId': messageId,
      'chatId': chatId,
      'additionalDetails': additionalDetails,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
