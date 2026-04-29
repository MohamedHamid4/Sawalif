import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';

/// ViewModel لشاشة المحادثة الفردية
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final String currentUid;
  final ChatModel chat;

  ChatViewModel({
    required ChatRepository repository,
    required this.currentUid,
    required this.chat,
  }) : _repository = repository;

  // ===== الحالة =====
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isTyping = false;
  MessageModel? _replyToMessage;
  Timer? _typingTimer;
  StreamSubscription? _messagesSubscription;

  // ===== Getters =====
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  MessageModel? get replyToMessage => _replyToMessage;
  String get chatId => chat.id;
  bool get otherUserIsTyping => chat.isOtherTyping(currentUid);

  /// بدء الاستماع للرسائل
  void startListening() {
    _messagesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _messagesSubscription =
        _repository.watchMessages(chatId).listen((messages) {
      _messages = messages;
      _isLoading = false;
      notifyListeners();

      // تحديث حالة القراءة
      _markAsRead();
    });
  }

  /// إيقاف الاستماع
  void stopListening() {
    _messagesSubscription?.cancel();
  }

  /// إرسال رسالة نصية
  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      await _repository.sendTextMessage(
        chat: chat,
        senderId: currentUid,
        content: content.trim(),
        replyToId: _replyToMessage?.id,
        replyToContent: _replyToMessage?.content,
      );
      _replyToMessage = null;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// إرسال صورة
  Future<void> sendImage(File imageFile) async {
    _isSending = true;
    notifyListeners();

    try {
      await _repository.sendImageMessage(
        chat: chat,
        senderId: currentUid,
        imageFile: imageFile,
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    await _repository.deleteMessage(chatId, messageId);
  }

  /// إضافة ردّ فعل
  Future<void> addReaction(String messageId, String emoji) async {
    await _repository.addReaction(chatId, messageId, currentUid, emoji);
  }

  /// إزالة ردّ فعل
  Future<void> removeReaction(String messageId, String emoji) async {
    await _repository.removeReaction(chatId, messageId, currentUid, emoji);
  }

  /// تعيين الرسالة المراد الرد عليها
  void setReplyTo(MessageModel? message) {
    _replyToMessage = message;
    notifyListeners();
  }

  /// تحديث حالة الكتابة
  void onTyping(bool isTyping) {
    if (_isTyping == isTyping) return;
    _isTyping = isTyping;
    _repository.updateTypingStatus(chatId, currentUid, isTyping);

    // إيقاف مؤشر الكتابة بعد 3 ثوان
    if (isTyping) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _isTyping = false;
        _repository.updateTypingStatus(chatId, currentUid, false);
      });
    }
  }

  /// هل الرسالة من المستخدم الحالي؟
  bool isMyMessage(MessageModel message) => message.senderId == currentUid;

  /// تحديث حالة القراءة (يَتضمّن تعليم "مُسلَّمة" أيضاً)
  Future<void> _markAsRead() async {
    await _repository.resetUnreadCount(chatId, currentUid);
    // markMessagesAsRead يضيف uid إلى deliveredTo و readBy معاً
    await _repository.markMessagesAsRead(chatId, currentUid);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messagesSubscription?.cancel();
    // إيقاف الكتابة عند مغادرة الشاشة
    _repository.updateTypingStatus(chatId, currentUid, false);
    super.dispose();
  }
}
