import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../data/repositories/chat_repository.dart';

/// ViewModel لقائمة المحادثات
class ChatsViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  ChatsViewModel({required ChatRepository repository})
      : _repository = repository;

  // ===== الحالة =====
  List<ChatModel> _chats = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // ===== Getters =====
  List<ChatModel> get chats => _filteredChats;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isEmpty => _chats.isEmpty;

  List<ChatModel> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      final name = chat.otherUser?.name.toLowerCase() ?? '';
      final lastMsg = chat.lastMessage.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || lastMsg.contains(query);
    }).toList();
  }

  /// مراقبة المحادثات في الوقت الفعلي
  Stream<List<ChatModel>> watchChats(String uid) {
    return _repository.watchChats(uid);
  }

  /// تحديث قائمة المحادثات من الـ Stream
  void updateChats(List<ChatModel> chats) {
    _chats = chats;
    notifyListeners();
  }

  /// تحديث نص البحث
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// مسح البحث
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
