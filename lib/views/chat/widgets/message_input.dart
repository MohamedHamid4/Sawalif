import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/permission_service.dart';
import '../../../l10n/app_localizations.dart';

/// شريط إدخال الرسالة مع دعم الصور والرد
class MessageInput extends StatefulWidget {
  final void Function(String text) onSendText;
  final void Function(File image) onSendImage;
  final void Function(bool isTyping) onTypingChanged;
  final MessageModel? replyToMessage;
  final VoidCallback? onCancelReply;
  final bool isSending;

  const MessageInput({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onTypingChanged,
    this.replyToMessage,
    this.onCancelReply,
    this.isSending = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late AnimationController _sendButtonController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
      widget.onTypingChanged(hasText);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onSendText(text);
  }

  Future<void> _pickImage() async {
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
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: Text(l10n.takePhoto),
              onTap: () async {
                Navigator.of(context).pop();
                await _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: Text(l10n.chooseGallery),
              onTap: () async {
                Navigator.of(context).pop();
                await _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    if (!await _ensurePermissionForSource(source)) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked != null) {
      widget.onSendImage(File(picked.path));
    }
  }

  /// التحقق من إذن المعرض/الكاميرا حسب مصدر الصورة
  Future<bool> _ensurePermissionForSource(ImageSource source) async {
    final perm = PermissionService();
    final l10n = AppLocalizations.of(context);

    if (source == ImageSource.camera) {
      if (await perm.hasPermission(Permission.camera)) return true;
      final granted = await perm.requestCamera();
      if (granted) return true;
      if (await perm.isPermanentlyDenied(Permission.camera) && mounted) {
        await perm.showOpenSettingsDialog(
          context: context,
          title: l10n.permissionDenied,
          message: l10n.permissionDeniedSettings,
          openText: l10n.openSettings,
          cancelText: l10n.cancel,
        );
      }
      return false;
    }

    // gallery
    final granted = await perm.requestGallery();
    if (granted) return true;
    if (await perm.isPermanentlyDenied(Permission.photos) && mounted) {
      await perm.showOpenSettingsDialog(
        context: context,
        title: l10n.permissionGalleryTitle,
        message: l10n.permissionDeniedSettings,
        openText: l10n.openSettings,
        cancelText: l10n.cancel,
      );
    }
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // قسم الرد
        if (widget.replyToMessage != null) _buildReplyPreview(context),

        // شريط الإدخال
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // زر الصورة
              AnimatedButton(
                icon: Icons.attach_file_rounded,
                onTap: _pickImage,
              ),

              const SizedBox(width: AppSizes.xs),

              // حقل النص
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkInputBg
                        : AppColors.lightInputBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.typeMessage,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),

              const SizedBox(width: AppSizes.xs),

              // زر الإرسال
              _buildSendButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 46,
      child: widget.isSending
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            )
          : GestureDetector(
              onTap: _hasText ? _send : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _hasText ? AppColors.primaryGradient : null,
                  color: _hasText ? null : AppColors.lightDivider,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: _hasText ? Colors.white : AppColors.lightTextSecondary,
                  size: 22,
                ),
              ),
            ),
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightInputBg,
        border: const Border(
          top: BorderSide(color: AppColors.lightDivider),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).replyTo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.replyToMessage!.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: widget.onCancelReply,
            color: AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }
}

/// زر دائري مع أيقونة
class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AnimatedButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
