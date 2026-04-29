import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/chats_viewmodel.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../stories/stories_bar.dart';
import 'widgets/chat_tile.dart';
import 'widgets/empty_chats_widget.dart';

/// الشاشة الرئيسية - قائمة المحادثات
class ChatsListView extends StatefulWidget {
  const ChatsListView({super.key});

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authVm = context.read<AuthViewModel>();
    final currentUid = authVm.currentUid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchChats,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (q) =>
                    context.read<ChatsViewModel>().setSearchQuery(q),
              )
            : Text(l10n.chats),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              setState(() => _isSearchVisible = !_isSearchVisible);
              if (!_isSearchVisible) {
                _searchController.clear();
                context.read<ChatsViewModel>().clearSearch();
              }
            },
          ),
          // قائمة الإعدادات
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded),
                    const SizedBox(width: AppSizes.sm),
                    Text(l10n.profile),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: AppSizes.sm),
                    Text(l10n.settings),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      l10n.logout,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).pushNamed(AppRoutes.profile);
                case 'settings':
                  Navigator.of(context).pushNamed(AppRoutes.settings);
                case 'logout':
                  _confirmLogout(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== شريط الحالات =====
          const StoriesBar(),
          const Divider(height: 1),

          // ===== قائمة المحادثات =====
          Expanded(
            child: StreamBuilder(
              stream: context
                  .read<ChatsViewModel>()
                  .watchChats(currentUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ChatListShimmer();
                }
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.errorLoading));
                }

                final chats = snapshot.data ?? [];
                context.read<ChatsViewModel>().updateChats(chats);

                return Consumer<ChatsViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isEmpty) {
                      return EmptyChatsWidget(
                        onStartChat: () => _showAddFriendOptions(context),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {},
                      child: AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.sm),
                          // keep alives off لأن قائمة المحادثات لا تحتاج
                          // الاحتفاظ بحالة عناصرها خارج الشاشة.
                          addAutomaticKeepAlives: false,
                          // RepaintBoundaries ON (الافتراضي) — يعزل كل
                          // ChatTile عن إعادة الرسم عند التمرير وهو مكسب
                          // واضح لقوائم بها صور وأيقونات.
                          itemCount: vm.chats.length,
                          itemBuilder: (context, index) {
                            final chat = vm.chats[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                horizontalOffset: 50,
                                child: FadeInAnimation(
                                  child: ChatTile(
                                    chat: chat,
                                    currentUid: currentUid,
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                      AppRoutes.chat,
                                      arguments: chat,
                                    ),
                                    onLongPress: () =>
                                        _showChatOptions(context, chat.id),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFriendOptions(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text(
          l10n.addFriend,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showAddFriendOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXxl)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search_rounded,
                    color: AppColors.primary),
                title: Text(l10n.searchByUsername),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.searchUser);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded,
                    color: AppColors.primary),
                title: Text(l10n.scanQrCode),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.qrScanner);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add_rounded,
                    color: AppColors.primary),
                title: Text(l10n.createGroup),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.createGroup);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context, String chatId) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              title: Text(l10n.delete,
                  style: const TextStyle(color: AppColors.error)),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthViewModel>().signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
