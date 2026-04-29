import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/message_model.dart';
import '../../../l10n/app_localizations.dart';

/// فقاعة الرسالة مع دعم كامل للنصوص والصور والردود
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final bool showSenderName;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final void Function(String emoji)? onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    this.showSenderName = false,
    this.onReply,
    this.onDelete,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return _buildDeletedBubble(context);
    }

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context);
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: isMe ? 60 : AppSizes.md,
          end: isMe ? AppSizes.md : 60,
          top: 2,
          bottom: 2,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // اسم المرسل في المجموعات (للرسائل الواردة فقط)
            if (showSenderName && !isMe && message.senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 12, bottom: 2, top: 2),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),

            // قسم الرد إن وُجد
            if (message.replyToContent != null) _buildReplyHeader(context),

            // الفقاعة الرئيسية
            _buildBubble(context),

            // الوقت وحالة القراءة
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatMessageTime(message.timestamp, context),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  _buildStatusIcon(),
                ],
              ],
            ),

            // ردود الفعل
            if (message.reactions.isNotEmpty)
              _buildReactions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        gradient: isMe ? AppColors.primaryGradient : null,
        color: isMe
            ? null
            : (isDark
                ? AppColors.otherMessageDarkBg
                : AppColors.otherMessageLightBg),
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(AppSizes.radiusLg),
          topEnd: const Radius.circular(AppSizes.radiusLg),
          bottomStart: Radius.circular(isMe ? AppSizes.radiusLg : 4),
          bottomEnd: Radius.circular(isMe ? 4 : AppSizes.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: message.type == MessageType.image
          ? _buildImageContent()
          : _buildTextContent(context),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: isMe ? Colors.white : null,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: CachedNetworkImage(
        imageUrl: message.imageUrl ?? '',
        width: 220,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 220,
          height: 200,
          color: AppColors.lightDivider,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 220,
          height: 200,
          color: AppColors.lightDivider,
          child: const Icon(Icons.broken_image_rounded, size: 40),
        ),
      ),
    );
  }

  Widget _buildReplyHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: const BorderDirectional(
          start: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Text(
        message.replyToContent ?? '',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDeletedBubble(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isMe ? 60 : AppSizes.md,
        end: isMe ? AppSizes.md : 60,
        top: 2,
        bottom: 2,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightDivider,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.do_not_disturb_alt_rounded,
                size: 14, color: AppColors.lightTextSecondary),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).messageDeleted,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.lightTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    // المصادر بالأولوية:
    // 1) المصفوفات (readBy / deliveredTo) — أدق
    // 2) status string — للرسائل القديمة قبل إضافة المصفوفات
    final isRead = message.readBy.isNotEmpty ||
        message.status == MessageStatus.read;
    final isDelivered = message.deliveredTo.isNotEmpty ||
        message.status == MessageStatus.delivered;

    IconData icon;
    Color color;
    if (isRead) {
      icon = Icons.done_all_rounded;
      color = Colors.lightBlue;
    } else if (isDelivered) {
      icon = Icons.done_all_rounded;
      color = AppColors.lightTextSecondary;
    } else {
      icon = Icons.done_rounded;
      color = AppColors.lightTextSecondary;
    }
    return Icon(icon, size: 14, color: color);
  }

  Widget _buildReactions(BuildContext context) {
    // تجميع ردود الفعل
    final Map<String, int> emojiCount = {};
    for (final r in message.reactions) {
      final emoji = r.split(':').last;
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: emojiCount.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${entry.key} ${entry.value}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      builder: (context) => _MessageOptionsSheet(
        message: message,
        isMe: isMe,
        onReply: () {
          Navigator.of(context).pop();
          onReply?.call();
        },
        onDelete: () {
          Navigator.of(context).pop();
          onDelete?.call();
        },
        onReact: (emoji) {
          Navigator.of(context).pop();
          onReact?.call(emoji);
        },
      ),
    );
  }
}

/// Bottom Sheet خيارات الرسالة
class _MessageOptionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final void Function(String emoji)? onReact;

  const _MessageOptionsSheet({
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const emojis = ['❤️', '😂', '👍', '😮', '😢', '🔥'];

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.lightDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // الإيموجي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis.map((emoji) {
              return GestureDetector(
                onTap: () => onReact?.call(emoji),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.lightInputBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSizes.md),
          const Divider(),

          // خيارات
          ListTile(
            leading: const Icon(Icons.reply_rounded),
            title: Text(l10n.reply),
            onTap: onReply,
          ),

          if (message.type == MessageType.text)
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(l10n.copy),
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(ClipboardData(text: message.content));
              },
            ),

          if (isMe)
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: Text(
                l10n.deleteMessage,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: onDelete,
            ),
        ],
      ),
    );
  }
}
