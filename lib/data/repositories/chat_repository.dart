import 'dart:io';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/group_service.dart';
import '../services/onesignal_service.dart';
import '../services/storage_service.dart';
import 'user_repository.dart';

/// طبقة الوسيط لعمليات المحادثات
class ChatRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final UserRepository _userRepository;
  final OneSignalService _oneSignalService;
  final GroupService _groupService;

  ChatRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required UserRepository userRepository,
    required OneSignalService oneSignalService,
    GroupService? groupService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService,
        _userRepository = userRepository,
        _oneSignalService = oneSignalService,
        _groupService = groupService ?? GroupService();

  /// رفع صورة مجموعة
  Future<String> uploadGroupImage(File imageFile) =>
      _storageService.uploadGroupImage(imageFile);

  /// رفع صورة حالة (Story)
  Future<String> uploadStoryImage(File imageFile) =>
      _storageService.uploadStoryImage(imageFile);

  /// إنشاء مجموعة
  Future<String> createGroup({
    required String name,
    required String creatorId,
    required List<String> memberIds,
    String? description,
    String? photoUrl,
  }) =>
      _groupService.createGroup(
        name: name,
        creatorId: creatorId,
        memberIds: memberIds,
        description: description,
        photoUrl: photoUrl,
      );

  Future<void> addGroupMember(String groupId, String userId) =>
      _groupService.addMember(groupId, userId);
  Future<void> removeGroupMember(String groupId, String userId) =>
      _groupService.removeMember(groupId, userId);
  Future<void> leaveGroup(String groupId, String userId) =>
      _groupService.leaveGroup(groupId, userId);
  Future<void> makeGroupAdmin(String groupId, String userId) =>
      _groupService.makeAdmin(groupId, userId);
  Future<void> removeGroupAdmin(String groupId, String userId) =>
      _groupService.removeAdmin(groupId, userId);
  Future<void> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? photoUrl,
  }) =>
      _groupService.updateGroupInfo(
          groupId: groupId,
          name: name,
          description: description,
          photoUrl: photoUrl);

  /// مراقبة قائمة المحادثات مع بيانات المستخدمين (يستثني المحظورين)
  Stream<List<ChatModel>> watchChats(String uid) {
    return _firestoreService.watchChats(uid).asyncMap((chats) async {
      final me = await _userRepository.getUser(uid);
      final blocked = me?.blockedUsers ?? const <String>[];

      final enriched = <ChatModel>[];
      for (final chat in chats) {
        if (chat.isGroup) {
          enriched.add(chat);
          continue;
        }
        final otherUid = chat.getOtherUserId(uid);
        if (blocked.contains(otherUid)) continue;
        final otherUser = await _userRepository.getUser(otherUid);
        chat.otherUser = otherUser;
        enriched.add(chat);
      }
      return enriched;
    });
  }

  /// الحصول على محادثة أو إنشاؤها
  Future<ChatModel> getOrCreateChat(
      String uid1, String uid2, UserModel otherUser) async {
    final chat = await _firestoreService.getOrCreateChat(uid1, uid2);
    chat.otherUser = otherUser;
    return chat;
  }

  /// مراقبة الرسائل
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _firestoreService.watchMessages(chatId);
  }

  /// إرسال رسالة نصية (يدعم الفردية والجماعية)
  Future<void> sendTextMessage({
    required ChatModel chat,
    required String senderId,
    required String content,
    String? replyToId,
    String? replyToContent,
  }) async {
    final senderName = await _resolveSenderName(senderId);
    final message = MessageModel(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      replyToContent: replyToContent,
    );

    final receivers = chat.getOtherParticipants(senderId);
    await _firestoreService.sendMessage(chat.id, message, receivers);
    _fanoutNotifications(chat, senderId, senderName, content);
  }

  /// إرسال صورة (يدعم الفردية والجماعية)
  Future<void> sendImageMessage({
    required ChatModel chat,
    required String senderId,
    required File imageFile,
  }) async {
    final senderName = await _resolveSenderName(senderId);
    final imageUrl =
        await _storageService.uploadChatImage(chat.id, imageFile);

    final message = MessageModel(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: '📷 صورة',
      type: MessageType.image,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );

    final receivers = chat.getOtherParticipants(senderId);
    await _firestoreService.sendMessage(chat.id, message, receivers);
    _fanoutNotifications(chat, senderId, senderName, '📷 صورة');
  }

  /// جلب اسم المرسل من Firestore (للعرض في رسائل المجموعة وفي الإشعار)
  Future<String> _resolveSenderName(String uid) async {
    try {
      final user = await _userRepository.getUser(uid);
      return user?.name ?? '';
    } catch (_) {
      return '';
    }
  }

  /// إرسال إشعارات Push لكل المستقبلين (لا يمنع الإرسال إذا فشل)
  void _fanoutNotifications(
    ChatModel chat,
    String senderId,
    String senderName,
    String preview,
  ) {
    try {
      final receivers = chat.getOtherParticipants(senderId);
      if (chat.isGroup) {
        for (final receiverId in receivers) {
          _oneSignalService.sendNotificationToUser(
            receiverUid: receiverId,
            title: '${chat.groupName} 👥',
            message: '$senderName: $preview',
            chatId: chat.id,
            senderName: senderName,
          );
        }
      } else {
        for (final receiverId in receivers) {
          _oneSignalService.sendNotificationToUser(
            receiverUid: receiverId,
            title: senderName,
            message: preview,
            chatId: chat.id,
            senderName: senderName,
          );
        }
      }
    } catch (_) {
      // الإشعارات اختيارية - لا تكسر الإرسال
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestoreService.deleteMessage(chatId, messageId);
  }

  /// إضافة ردّ فعل
  Future<void> addReaction(
      String chatId, String messageId, String uid, String emoji) async {
    await _firestoreService.addReaction(chatId, messageId, uid, emoji);
  }

  /// إزالة ردّ فعل
  Future<void> removeReaction(
      String chatId, String messageId, String uid, String emoji) async {
    await _firestoreService.removeReaction(chatId, messageId, uid, emoji);
  }

  /// تحديث حالة الكتابة
  Future<void> updateTypingStatus(
      String chatId, String uid, bool isTyping) async {
    await _firestoreService.updateTypingStatus(chatId, uid, isTyping);
  }

  /// تصفير عداد الرسائل غير المقروءة
  Future<void> resetUnreadCount(String chatId, String uid) async {
    await _firestoreService.resetUnreadCount(chatId, uid);
  }

  /// تعليم الرسائل كمُسلَّمة (يفصل بين "وصلت الجهاز" و"تمت قراءتها")
  Future<void> markMessagesAsDelivered(
      String chatId, String currentUid) async {
    await _firestoreService.markMessagesAsDelivered(chatId, currentUid);
  }

  /// تحديث حالة قراءة الرسائل
  Future<void> markMessagesAsRead(String chatId, String currentUid) async {
    await _firestoreService.markMessagesAsRead(chatId, currentUid);
  }
}
