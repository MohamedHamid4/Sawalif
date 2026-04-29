import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_strings.dart';
import '../models/chat_model.dart';

/// خدمة المجموعات - عمليات على Firestore لمحادثات النوع group
class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _chats => _firestore.collection(AppStrings.colChats);

  /// إنشاء مجموعة جديدة
  /// يعيد chatId
  Future<String> createGroup({
    required String name,
    required String creatorId,
    required List<String> memberIds,
    String? description,
    String? photoUrl,
  }) async {
    final groupRef = _chats.doc();
    // المنشئ + الأعضاء (نتجنّب التكرار في حال تم تمرير المنشئ ضمن الأعضاء)
    final allParticipants = <String>{creatorId, ...memberIds}.toList();

    await groupRef.set({
      AppStrings.fieldChatType: ChatType.group.value,
      AppStrings.fieldGroupName: name,
      AppStrings.fieldGroupPhotoUrl: photoUrl ?? '',
      AppStrings.fieldGroupAdminId: creatorId,
      AppStrings.fieldGroupAdmins: [creatorId],
      AppStrings.fieldGroupDescription: description ?? '',
      AppStrings.fieldParticipants: allParticipants,
      AppStrings.fieldLastMessage: AppStrings.markerGroupCreated,
      AppStrings.fieldLastMessageTime: FieldValue.serverTimestamp(),
      AppStrings.fieldLastSenderId: creatorId,
      AppStrings.fieldUnreadCount: {for (final id in allParticipants) id: 0},
      AppStrings.fieldTyping: <String, bool>{},
      AppStrings.fieldCreatedAt: FieldValue.serverTimestamp(),
    });

    return groupRef.id;
  }

  Future<void> addMember(String groupId, String userId) async {
    await _chats.doc(groupId).update({
      AppStrings.fieldParticipants: FieldValue.arrayUnion([userId]),
      '${AppStrings.fieldUnreadCount}.$userId': 0,
    });
  }

  Future<void> removeMember(String groupId, String userId) async {
    await _chats.doc(groupId).update({
      AppStrings.fieldParticipants: FieldValue.arrayRemove([userId]),
      AppStrings.fieldGroupAdmins: FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    await removeMember(groupId, userId);
  }

  Future<void> makeAdmin(String groupId, String userId) async {
    await _chats.doc(groupId).update({
      AppStrings.fieldGroupAdmins: FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeAdmin(String groupId, String userId) async {
    await _chats.doc(groupId).update({
      AppStrings.fieldGroupAdmins: FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates[AppStrings.fieldGroupName] = name;
    if (description != null) {
      updates[AppStrings.fieldGroupDescription] = description;
    }
    if (photoUrl != null) updates[AppStrings.fieldGroupPhotoUrl] = photoUrl;
    if (updates.isNotEmpty) {
      await _chats.doc(groupId).update(updates);
    }
  }
}
