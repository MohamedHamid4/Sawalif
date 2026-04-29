import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_strings.dart';

/// نوع الرسالة
enum MessageType { text, image }

/// حالة الرسالة
enum MessageStatus { sent, delivered, read }

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text: return 'text';
      case MessageType.image: return 'image';
    }
  }

  static MessageType fromString(String value) {
    switch (value) {
      case 'image': return MessageType.image;
      default: return MessageType.text;
    }
  }
}

extension MessageStatusExtension on MessageStatus {
  String get value {
    switch (this) {
      case MessageStatus.sent: return 'sent';
      case MessageStatus.delivered: return 'delivered';
      case MessageStatus.read: return 'read';
    }
  }

  static MessageStatus fromString(String value) {
    switch (value) {
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      default: return MessageStatus.sent;
    }
  }
}

/// موديل الرسالة في تطبيق سوالف
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? imageUrl;
  final String? replyToId;
  final String? replyToContent;
  final List<String> reactions; // قائمة "uid:emoji"
  final bool isDeleted;
  final List<String> deliveredTo; // uids الذين استلمت الرسالة على أجهزتهم
  final List<String> readBy; // uids الذين قرأوا الرسالة

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.imageUrl,
    this.replyToId,
    this.replyToContent,
    this.reactions = const [],
    this.isDeleted = false,
    this.deliveredTo = const [],
    this.readBy = const [],
  });

  /// تحويل من Firestore DocumentSnapshot
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data[AppStrings.fieldSenderId] as String? ?? '',
      senderName: data[AppStrings.fieldSenderName] as String? ?? '',
      content: data[AppStrings.fieldContent] as String? ?? '',
      type: MessageTypeExtension.fromString(
          data[AppStrings.fieldType] as String? ?? 'text'),
      timestamp: (data[AppStrings.fieldTimestamp] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MessageStatusExtension.fromString(
          data[AppStrings.fieldStatus] as String? ?? 'sent'),
      imageUrl: data[AppStrings.fieldImageUrl] as String?,
      replyToId: data[AppStrings.fieldReplyToId] as String?,
      replyToContent: data[AppStrings.fieldReplyToContent] as String?,
      reactions: List<String>.from(data[AppStrings.fieldReactions] as List? ?? []),
      isDeleted: data[AppStrings.fieldIsDeleted] as bool? ?? false,
      deliveredTo:
          List<String>.from(data[AppStrings.fieldDeliveredTo] as List? ?? []),
      readBy: List<String>.from(data[AppStrings.fieldReadBy] as List? ?? []),
    );
  }

  /// تحويل لـ Map لحفظه في Firestore
  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldSenderId: senderId,
      AppStrings.fieldSenderName: senderName,
      AppStrings.fieldContent: content,
      AppStrings.fieldType: type.value,
      AppStrings.fieldTimestamp: Timestamp.fromDate(timestamp),
      AppStrings.fieldStatus: status.value,
      AppStrings.fieldImageUrl: imageUrl,
      AppStrings.fieldReplyToId: replyToId,
      AppStrings.fieldReplyToContent: replyToContent,
      AppStrings.fieldReactions: reactions,
      AppStrings.fieldIsDeleted: isDeleted,
      AppStrings.fieldDeliveredTo: deliveredTo,
      AppStrings.fieldReadBy: readBy,
    };
  }

  /// نسخة معدّلة
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? imageUrl,
    String? replyToId,
    String? replyToContent,
    List<String>? reactions,
    bool? isDeleted,
    List<String>? deliveredTo,
    List<String>? readBy,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      reactions: reactions ?? this.reactions,
      isDeleted: isDeleted ?? this.isDeleted,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MessageModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
