import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../../core/constants/app_strings.dart';

/// خدمة Firestore - جميع عمليات قاعدة البيانات
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== المراجع =====
  CollectionReference get _users => _db.collection(AppStrings.colUsers);
  CollectionReference get _chats => _db.collection(AppStrings.colChats);
  CollectionReference get _usernames =>
      _db.collection(AppStrings.colUsernames);

  CollectionReference _messages(String chatId) =>
      _chats.doc(chatId).collection(AppStrings.colMessages);

  // =============================================
  // ===== عمليات المستخدمين =====
  // =============================================

  /// حفظ بيانات المستخدم عند التسجيل لأول مرة
  Future<void> saveUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  /// حفظ المستخدم وحجز اسم المستخدم في عملية واحدة (atomic)
  /// يفشل إذا كان اسم المستخدم محجوزاً مسبقاً.
  Future<void> saveUserWithUsername(UserModel user) async {
    if (user.username.isEmpty) {
      throw Exception('username_required');
    }
    final batch = _db.batch();
    batch.set(_users.doc(user.uid), user.toMap());
    batch.set(_usernames.doc(user.username), {
      AppStrings.fieldUid: user.uid,
      AppStrings.fieldReservedAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// التحقق من توفر اسم المستخدم
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernames.doc(username).get();
    return !doc.exists;
  }

  /// إيجاد مستخدم بواسطة اسم المستخدم
  Future<UserModel?> findUserByUsername(String username) async {
    final usernameDoc = await _usernames.doc(username).get();
    if (!usernameDoc.exists) return null;

    final uid = (usernameDoc.data() as Map<String, dynamic>)[AppStrings.fieldUid]
        as String?;
    if (uid == null || uid.isEmpty) return null;

    return await getUser(uid);
  }

  /// حجز اسم مستخدم لمستخدم موجود (لمن سجّل بدون اسم مستخدم سابقاً)
  Future<void> setUsernameForExistingUser(String uid, String username) async {
    final batch = _db.batch();
    batch.update(_users.doc(uid), {AppStrings.fieldUsername: username});
    batch.set(_usernames.doc(username), {
      AppStrings.fieldUid: uid,
      AppStrings.fieldReservedAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// حذف بيانات المستخدم وحجز اسمه (Firestore فقط - بدون Firebase Auth)
  Future<void> deleteUserData(String uid) async {
    // قراءة اسم المستخدم لتحرير الحجز
    final userDoc = await _users.doc(uid).get();
    String? username;
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?;
      username = data?[AppStrings.fieldUsername] as String?;
    }

    final batch = _db.batch();
    batch.delete(_users.doc(uid));
    if (username != null && username.isNotEmpty) {
      batch.delete(_usernames.doc(username));
    }
    await batch.commit();

    // وضع علامة على المحادثات للطرف الآخر
    await _markChatsForDeletedUser(uid);
  }

  /// إضافة المستخدم لقائمة المحذوفين في كل محادثاته
  Future<void> _markChatsForDeletedUser(String uid) async {
    final chats = await _chats
        .where(AppStrings.fieldParticipants, arrayContains: uid)
        .get();

    if (chats.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in chats.docs) {
      batch.update(doc.reference, {
        'deletedParticipants': FieldValue.arrayUnion([uid]),
      });
    }
    await batch.commit();
  }

  /// مسح حالة الاتصال + FCM token عند تسجيل الخروج
  Future<void> clearOnlineAndToken(String uid) async {
    try {
      await _users.doc(uid).update({
        AppStrings.fieldIsOnline: false,
        AppStrings.fieldLastSeen: FieldValue.serverTimestamp(),
        AppStrings.fieldFcmToken: '',
      });
    } catch (_) {
      // تجاهل الفشل (مثلاً مستخدم محذوف)
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  /// الحصول على مستخدم واحد
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// مراقبة بيانات المستخدم الحالي في الوقت الفعلي
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// البحث عن المستخدمين بالاسم
  Future<List<UserModel>> searchUsers(String query, String currentUid) async {
    final snapshot = await _users
        .where(AppStrings.fieldName, isGreaterThanOrEqualTo: query)
        .where(AppStrings.fieldName, isLessThanOrEqualTo: '$query')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.uid != currentUid)
        .toList();
  }

  /// جلب كل المستخدمين (لقائمة بدء محادثة)
  Stream<List<UserModel>> watchAllUsers(String currentUid) {
    return _users
        .where(AppStrings.fieldUid, isNotEqualTo: currentUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  /// تحديث حالة الاتصال
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _users.doc(uid).update({
      AppStrings.fieldIsOnline: isOnline,
      AppStrings.fieldLastSeen: FieldValue.serverTimestamp(),
    });
  }

  /// تحديث FCM token
  Future<void> updateFcmToken(String uid, String token) async {
    await _users.doc(uid).update({AppStrings.fieldFcmToken: token});
  }

  // =============================================
  // ===== عمليات المحادثات =====
  // =============================================

  /// مراقبة قائمة المحادثات في الوقت الفعلي
  Stream<List<ChatModel>> watchChats(String uid) {
    return _chats
        .where(AppStrings.fieldParticipants, arrayContains: uid)
        .orderBy(AppStrings.fieldLastMessageTime, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  /// الحصول على محادثة أو إنشاؤها
  ///
  /// نستخدم set مع merge بدلاً من get-then-set:
  /// - get على وثيقة غير موجودة كان يفشل بـ PERMISSION_DENIED
  ///   (قاعدة allow read تتحقق من resource.data.participants وهو null للوثائق غير الموجودة).
  /// - merge ينشئ الوثيقة إن لم تكن موجودة، ولا يمسّ الحقول الموجودة إن كانت موجودة.
  /// - نكتب فقط حقول الهوية الثابتة (type + participants) كي لا نُصفّر
  ///   lastMessage / unreadCount / typing عند إعادة فتح محادثة قائمة.
  Future<ChatModel> getOrCreateChat(String uid1, String uid2) async {
    final chatId = ChatModel.generateChatId(uid1, uid2);

    await _chats.doc(chatId).set({
      AppStrings.fieldChatType: ChatType.individual.value,
      AppStrings.fieldParticipants: [uid1, uid2],
    }, SetOptions(merge: true));

    // نُرجع نموذجاً محلياً بسيطاً؛ بقية البيانات (آخر رسالة، عدّاد القراءة...)
    // تتدفّق عبر stream قائمة المحادثات.
    return ChatModel(
      id: chatId,
      type: ChatType.individual,
      participants: [uid1, uid2],
    );
  }

  /// تحديث حالة الكتابة
  Future<void> updateTypingStatus(
      String chatId, String uid, bool isTyping) async {
    await _chats.doc(chatId).update({'${AppStrings.fieldTyping}.$uid': isTyping});
  }

  /// تصفير عداد الرسائل غير المقروءة
  Future<void> resetUnreadCount(String chatId, String uid) async {
    await _chats
        .doc(chatId)
        .update({'${AppStrings.fieldUnreadCount}.$uid': 0});
  }

  // =============================================
  // ===== عمليات الرسائل =====
  // =============================================

  /// مراقبة الرسائل في الوقت الفعلي
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _messages(chatId)
        .orderBy(AppStrings.fieldTimestamp, descending: false)
        .limitToLast(AppStrings.messagesPaginationLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  /// إرسال رسالة (يدعم fanout لمستقبلين متعددين)
  Future<String> sendMessage(
    String chatId,
    MessageModel message,
    List<String> receiverIds,
  ) async {
    final batch = _db.batch();

    // إضافة الرسالة - نستبدل الـ timestamp المحلي بـ serverTimestamp
    // لأن ساعة الجهاز قد تكون منحرفة وتُسبّب ترتيباً خاطئاً للرسائل
    // (كل رسائل المرسِل تظهر مجمّعة قبل رسائل المستقبل أو العكس).
    final messageRef = _messages(chatId).doc();
    final messageData = message.toMap();
    messageData[AppStrings.fieldTimestamp] = FieldValue.serverTimestamp();
    batch.set(messageRef, messageData);

    // تحديث بيانات المحادثة + زيادة unreadCount لكل مستقبل
    final updates = <String, dynamic>{
      AppStrings.fieldLastMessage:
          message.type == MessageType.image ? '📷 صورة' : message.content,
      AppStrings.fieldLastMessageTime: FieldValue.serverTimestamp(),
      AppStrings.fieldLastSenderId: message.senderId,
    };
    for (final receiverId in receiverIds) {
      updates['${AppStrings.fieldUnreadCount}.$receiverId'] =
          FieldValue.increment(1);
    }
    batch.update(_chats.doc(chatId), updates);

    await batch.commit();
    return messageRef.id;
  }

  /// حذف رسالة (soft delete) - نكتب marker ثابت بدلاً من نص بلغة معيّنة
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _messages(chatId).doc(messageId).update({
      AppStrings.fieldIsDeleted: true,
      AppStrings.fieldContent: AppStrings.markerMessageDeleted,
    });
  }

  /// إضافة ردّ فعل على رسالة
  Future<void> addReaction(
      String chatId, String messageId, String uid, String emoji) async {
    final reactionKey = '$uid:$emoji';
    await _messages(chatId).doc(messageId).update({
      AppStrings.fieldReactions: FieldValue.arrayUnion([reactionKey]),
    });
  }

  /// إزالة ردّ فعل
  Future<void> removeReaction(
      String chatId, String messageId, String uid, String emoji) async {
    final reactionKey = '$uid:$emoji';
    await _messages(chatId).doc(messageId).update({
      AppStrings.fieldReactions: FieldValue.arrayRemove([reactionKey]),
    });
  }

  /// تعليم الرسائل كـ "مُسلَّمة" للمستخدم الحالي.
  /// يُضيف uid إلى deliveredTo[] ويرفع الحالة إلى delivered (إن لم تكن read).
  Future<void> markMessagesAsDelivered(
      String chatId, String currentUid) async {
    final undelivered = await _messages(chatId)
        .where(AppStrings.fieldSenderId, isNotEqualTo: currentUid)
        .get();

    final batch = _db.batch();
    var hasUpdates = false;
    for (final doc in undelivered.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final delivered = List<String>.from(
          data[AppStrings.fieldDeliveredTo] as List? ?? []);
      if (delivered.contains(currentUid)) continue;

      final currentStatus = data[AppStrings.fieldStatus] as String? ?? 'sent';
      final updates = <String, dynamic>{
        AppStrings.fieldDeliveredTo: FieldValue.arrayUnion([currentUid]),
      };
      // لا نُنزِل الحالة من read إلى delivered
      if (currentStatus != MessageStatus.read.value) {
        updates[AppStrings.fieldStatus] = MessageStatus.delivered.value;
      }
      batch.update(doc.reference, updates);
      hasUpdates = true;
    }
    if (hasUpdates) await batch.commit();
  }

  /// تحديث حالة قراءة الرسائل (يضمن أيضاً أنها مُسلَّمة).
  Future<void> markMessagesAsRead(String chatId, String currentUid) async {
    final unreadMessages = await _messages(chatId)
        .where(AppStrings.fieldSenderId, isNotEqualTo: currentUid)
        .where(AppStrings.fieldStatus, isNotEqualTo: MessageStatus.read.value)
        .get();

    final batch = _db.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        AppStrings.fieldStatus: MessageStatus.read.value,
        AppStrings.fieldDeliveredTo:
            FieldValue.arrayUnion([currentUid]),
        AppStrings.fieldReadBy: FieldValue.arrayUnion([currentUid]),
      });
    }
    await batch.commit();
  }
}
