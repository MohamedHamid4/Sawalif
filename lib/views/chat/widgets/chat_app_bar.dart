import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/presence_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/common/custom_avatar.dart';

/// AppBar مخصص لشاشة المحادثة - يدعم الفردية والجماعية
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatModel? chat;
  final UserModel? otherUser;
  final bool isTyping;
  final UserPresence? presence;
  final VoidCallback? onTap;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;

  const ChatAppBar({
    super.key,
    this.chat,
    this.otherUser,
    this.isTyping = false,
    this.presence,
    this.onTap,
    this.onBack,
    this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  bool get _isGroup => chat?.isGroup ?? false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isGroup
                        ? chat!.groupName
                        : (otherUser?.name ?? '---'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isTyping
                        ? Text(
                            l10n.typing,
                            key: const ValueKey('typing'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : _buildSubtitle(context, l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (onSearch != null)
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: onSearch,
          ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: onTap,
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (_isGroup) {
      final url = chat!.groupPhotoUrl;
      if (url.isNotEmpty) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _groupPlaceholder(),
          ),
        );
      }
      return _groupPlaceholder();
    }
    final isOnline = presence?.isOnline ?? otherUser?.isOnline ?? false;
    return CustomAvatar(
      imageUrl: otherUser?.photoUrl,
      name: otherUser?.name ?? '?',
      size: 40,
      showOnlineDot: true,
      isOnline: isOnline,
    );
  }

  Widget _groupPlaceholder() => Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.group_rounded, color: Colors.white, size: 22),
      );

  Widget _buildSubtitle(BuildContext context, AppLocalizations l10n) {
    if (_isGroup) {
      return Text(
        '${chat!.participants.length} ${l10n.groupMembers}',
        key: const ValueKey('group_members'),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.lightTextSecondary,
        ),
      );
    }
    if (otherUser == null) return const SizedBox.shrink();

    // RTDB presence له الأولوية إذا تَوفّر، وإلا نقرأ من Firestore عبر otherUser.
    final isOnline = presence?.isOnline ?? otherUser!.isOnline;
    final lastSeen = presence?.lastSeen ?? otherUser!.lastSeen;

    if (isOnline) {
      return Text(
        l10n.online,
        key: const ValueKey('online'),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.online,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    if (lastSeen != null) {
      return Text(
        '${l10n.lastSeen} ${DateFormatter.formatLastSeen(lastSeen, context)}',
        key: const ValueKey('last_seen'),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.lightTextSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      l10n.offline,
      key: const ValueKey('offline'),
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.lightTextSecondary,
      ),
    );
  }
}
