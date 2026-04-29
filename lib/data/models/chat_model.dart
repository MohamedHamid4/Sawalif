import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_strings.dart';
import 'user_model.dart';

/// نوع المحادثة
enum ChatType { individual, group }

extension ChatTypeExtension on ChatType {
  String get value {
    switch (this) {
      case ChatType.group:
        return 'group';
      case ChatType.individual:
        return 'individual';
    }
  }

  static ChatType fromString(String? value) {
    switch (value) {
      case 'group':
        return ChatType.group;
      default:
        return ChatType.individual;
    }
  }
}

/// موديل المحادثة في تطبيق سوالف (يدعم الفردية والجماعية)
class ChatModel {
  final String id;
  final ChatType type;
  final List<String> participants;

  // ===== خاص بالمجموعات =====
  final String groupName;
  final String groupPhotoUrl;
  final String groupAdminId;
  final List<String> groupAdmins;
  final String groupDescription;

  // ===== عام =====
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> typing;

  // بيانات المستخدم الآخر (للفردية فقط - تُملأ من الكود)
  UserModel? otherUser;

  ChatModel({
    required this.id,
    this.type = ChatType.individual,
    required this.participants,
    this.groupName = '',
    this.groupPhotoUrl = '',
    this.groupAdminId = '',
    this.groupAdmins = const [],
    this.groupDescription = '',
    this.lastMessage = '',
    this.lastMessageTime,
    this.lastSenderId = '',
    this.unreadCount = const {},
    this.typing = const {},
    this.otherUser,
  });

  bool get isGroup => type == ChatType.group;

  /// إنشاء chatId من uid المستخدمين (للفردية فقط)
  static String generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      type: ChatTypeExtension.fromString(
          data[AppStrings.fieldChatType] as String?),
      participants: List<String>.from(
          data[AppStrings.fieldParticipants] as List? ?? []),
      groupName: data[AppStrings.fieldGroupName] as String? ?? '',
      groupPhotoUrl: data[AppStrings.fieldGroupPhotoUrl] as String? ?? '',
      groupAdminId: data[AppStrings.fieldGroupAdminId] as String? ?? '',
      groupAdmins: List<String>.from(
          data[AppStrings.fieldGroupAdmins] as List? ?? []),
      groupDescription:
          data[AppStrings.fieldGroupDescription] as String? ?? '',
      lastMessage: data[AppStrings.fieldLastMessage] as String? ?? '',
      lastMessageTime:
          (data[AppStrings.fieldLastMessageTime] as Timestamp?)?.toDate(),
      lastSenderId: data[AppStrings.fieldLastSenderId] as String? ?? '',
      unreadCount: Map<String, int>.from(
          data[AppStrings.fieldUnreadCount] as Map? ?? {}),
      typing: Map<String, bool>.from(
          data[AppStrings.fieldTyping] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldChatType: type.value,
      AppStrings.fieldParticipants: participants,
      AppStrings.fieldGroupName: groupName,
      AppStrings.fieldGroupPhotoUrl: groupPhotoUrl,
      AppStrings.fieldGroupAdminId: groupAdminId,
      AppStrings.fieldGroupAdmins: groupAdmins,
      AppStrings.fieldGroupDescription: groupDescription,
      AppStrings.fieldLastMessage: lastMessage,
      AppStrings.fieldLastMessageTime: lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      AppStrings.fieldLastSenderId: lastSenderId,
      AppStrings.fieldUnreadCount: unreadCount,
      AppStrings.fieldTyping: typing,
    };
  }

  /// uid المستخدم الآخر (للفردية فقط)
  String getOtherUserId(String myUid) {
    return participants.firstWhere((id) => id != myUid, orElse: () => '');
  }

  /// المستخدمون الآخرون (للمجموعة)
  List<String> getOtherParticipants(String myUid) {
    return participants.where((id) => id != myUid).toList();
  }

  bool isAdmin(String uid) => groupAdmins.contains(uid);

  bool isOtherTyping(String myUid) {
    if (isGroup) {
      // أي شخص غيري يكتب
      return typing.entries
          .any((e) => e.key != myUid && e.value == true);
    }
    final otherUid = getOtherUserId(myUid);
    return typing[otherUid] ?? false;
  }

  int getUnreadCount(String uid) => unreadCount[uid] ?? 0;

  ChatModel copyWith({
    String? id,
    ChatType? type,
    List<String>? participants,
    String? groupName,
    String? groupPhotoUrl,
    String? groupAdminId,
    List<String>? groupAdmins,
    String? groupDescription,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? typing,
    UserModel? otherUser,
  }) {
    return ChatModel(
      id: id ?? this.id,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      groupName: groupName ?? this.groupName,
      groupPhotoUrl: groupPhotoUrl ?? this.groupPhotoUrl,
      groupAdminId: groupAdminId ?? this.groupAdminId,
      groupAdmins: groupAdmins ?? this.groupAdmins,
      groupDescription: groupDescription ?? this.groupDescription,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      typing: typing ?? this.typing,
      otherUser: otherUser ?? this.otherUser,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChatModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
