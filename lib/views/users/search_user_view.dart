import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_avatar.dart';

/// شاشة البحث عن مستخدم بواسطة @username
class SearchUserView extends StatefulWidget {
  const SearchUserView({super.key});

  @override
  State<SearchUserView> createState() => _SearchUserViewState();
}

class _SearchUserViewState extends State<SearchUserView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _isSearching = false;
  bool _hasSearched = false;
  UserModel? _result;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    _debounce?.cancel();
    final username = Validators.normalizeUsername(raw);

    if (username.isEmpty) {
      setState(() {
        _isSearching = false;
        _hasSearched = false;
        _result = null;
      });
      return;
    }

    // تأخير 300ms لتقليل الطلبات
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(username));
  }

  Future<void> _search(String username) async {
    if (Validators.validateUsername(username, context) != null) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _result = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    final user = await context.read<UserRepository>().findUserByUsername(username);
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _hasSearched = true;
      _result = user;
    });
  }

  Future<void> _startChat(UserModel otherUser) async {
    final authVm = context.read<AuthViewModel>();
    final chatRepo = context.read<ChatRepository>();
    final currentUid = authVm.currentUid;
    if (currentUid == null || currentUid == otherUser.uid) return;

    final chat = await chatRepo.getOrCreateChat(currentUid, otherUser.uid, otherUser);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.chat, arguments: chat);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchByUsername),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: l10n.searchUsernameHint,
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                filled: true,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onChanged('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(child: _buildBody(l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (!_hasSearched) {
      return _EmptyHint(
        icon: Icons.search_rounded,
        title: l10n.searchUsernameEmptyTitle,
        subtitle: l10n.searchUsernameEmptySubtitle,
      );
    }
    if (_result == null) {
      return _EmptyHint(
        icon: Icons.person_off_outlined,
        title: l10n.userNotFound,
      );
    }

    final user = _result!;
    final currentUid = context.read<AuthViewModel>().currentUid;
    final isSelf = user.uid == currentUid;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            children: [
              CustomAvatar(
                imageUrl: user.photoUrl,
                name: user.name,
                size: AppSizes.avatarXl,
                showOnlineDot: true,
                isOnline: user.isOnline,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                user.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                '@${user.username}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSelf ? null : () => _startChat(user),
                  icon: const Icon(Icons.chat_rounded),
                  label: Text(l10n.startChat),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _EmptyHint({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.lightTextSecondary),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle!,
                style: const TextStyle(color: AppColors.lightTextSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
