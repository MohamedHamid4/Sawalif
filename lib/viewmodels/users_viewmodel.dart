import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

/// ViewModel لقائمة المستخدمين والبحث
class UsersViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UsersViewModel({required UserRepository repository})
      : _repository = repository;

  // ===== الحالة =====
  List<UserModel> _users = [];
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';

  // ===== Getters =====
  List<UserModel> get users => _isSearching ? _searchResults : _users;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  bool get isEmpty => users.isEmpty;

  /// مراقبة كل المستخدمين
  Stream<List<UserModel>> watchAllUsers(String currentUid) {
    return _repository.watchAllUsers(currentUid);
  }

  /// تحديث قائمة المستخدمين
  void updateUsers(List<UserModel> users) {
    _users = users;
    notifyListeners();
  }

  /// البحث عن مستخدمين
  Future<void> search(String query, String currentUid) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchUsers(query, currentUid);
    } catch (_) {
      _searchResults = _users.where((u) {
        return u.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// مسح البحث
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }
}
