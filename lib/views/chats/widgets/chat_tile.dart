import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/system_message_resolver.dart';
import '../../../data/models/chat_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/common/custom_avatar.dart';

/// بطاقة محادثة في القائمة الرئيسية
class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUid;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUid,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = chat.otherUser;
    final unread = chat.getUnreadCount(currentUid);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGroup = chat.isGroup;
    final l10n = AppLocalizations.of(context);

    final title = isGroup
        ? chat.groupName
        : (otherUser?.name ?? '---');

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            // الأفاتار / أيقونة المجموعة
            if (isGroup)
              _GroupAvatar(photoUrl: chat.groupPhotoUrl)
            else
              CustomAvatar(
                imageUrl: otherUser?.photoUrl,
                name: otherUser?.name ?? '?',
                size: AppSizes.avatarMd,
                showOnlineDot: true,
                isOnline: otherUser?.isOnline ?? false,
              ),

            const SizedBox(width: AppSizes.md),

            // معلومات المحادثة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الاسم
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // الوقت
                      if (chat.lastMessageTime != null)
                        Text(
                          DateFormatter.formatLastSeen(chat.lastMessageTime!, context),
                          style: TextStyle(
                            fontSize: 11,
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.lightTextSecondary,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // آخر رسالة أو "يكتب..."
                      Expanded(
                        child: Text(
                          chat.isOtherTyping(currentUid)
                              ? l10n.typing
                              : SystemMessageResolver.resolve(
                                  chat.lastMessage, context),
                          style: TextStyle(
                            fontSize: 13,
                            color: chat.isOtherTyping(currentUid)
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontWeight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                            fontStyle: chat.isOtherTyping(currentUid)
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Badge عدد غير المقروء
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// أفاتار المجموعة - صورة المجموعة أو أيقونة افتراضية بتدرج
class _GroupAvatar extends StatelessWidget {
  final String photoUrl;
  const _GroupAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: AppSizes.avatarMd,
          height: AppSizes.avatarMd,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(),
          errorWidget: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: AppSizes.avatarMd,
        height: AppSizes.avatarMd,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.group_rounded, color: Colors.white, size: 22),
      );
}

