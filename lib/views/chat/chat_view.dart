import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/moderation_service.dart';
import '../../data/services/presence_service.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../moderation/report_dialog.dart';
import 'chat_search_delegate.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';

/// شاشة المحادثة الفردية - Real-time messaging
class ChatView extends StatefulWidget {
  final ChatModel chat;

  const ChatView({super.key, required this.chat});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late ChatViewModel _viewModel;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final currentUid = context.read<AuthViewModel>().currentUid ?? '';
    _viewModel = ChatViewModel(
      repository: context.read<ChatRepository>(),
      currentUid: currentUid,
      chat: widget.chat,
    );
    _viewModel.startListening();
    _viewModel.addListener(_onMessagesUpdated);
  }

  // الـ scroll تلقائياً عند فتح لوحة المفاتيح
  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onMessagesUpdated() {
    if (_viewModel.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onMessagesUpdated);
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(AppSizes.appBarHeight),
          child: Consumer<ChatViewModel>(
            builder: (context, vm, _) {
              // المحادثات الجماعية: لا حاجة لـ presence stream
              if (widget.chat.isGroup) {
                return ChatAppBar(
                  chat: widget.chat,
                  otherUser: widget.chat.otherUser,
                  isTyping: widget.chat.isOtherTyping(vm.currentUid),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.groupInfo,
                    arguments: widget.chat.id,
                  ),
                  onSearch: () => showSearch(
                    context: context,
                    delegate: ChatSearchDelegate(messages: vm.messages),
                  ),
                );
              }
              // الفردية: Presence لحظي من RTDB
              final otherUid =
                  widget.chat.getOtherUserId(vm.currentUid);
              return StreamBuilder<UserPresence>(
                stream: otherUid.isEmpty
                    ? null
                    : PresenceService().watchUserPresence(otherUid),
                builder: (context, snap) {
                  return ChatAppBar(
                    chat: widget.chat,
                    otherUser: widget.chat.otherUser,
                    isTyping: widget.chat.isOtherTyping(vm.currentUid),
                    presence: snap.data,
                    onTap: () => _showOneOnOneOptions(context),
                    onSearch: () => showSearch(
                      context: context,
                      delegate: ChatSearchDelegate(messages: vm.messages),
                    ),
                  );
                },
              );
            },
          ),
        ),
        body: Column(
          children: [
            // قائمة الرسائل
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    );
                  }

                  if (vm.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            AppLocalizations.of(context).startChat,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildMessagesList(context, vm);
                },
              ),
            ),

            // شريط الإدخال
            Consumer<ChatViewModel>(
              builder: (context, vm, _) => MessageInput(
                onSendText: vm.sendTextMessage,
                onSendImage: vm.sendImage,
                onTypingChanged: vm.onTyping,
                replyToMessage: vm.replyToMessage,
                onCancelReply: () => vm.setReplyTo(null),
                isSending: vm.isSending,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatViewModel vm) {
    final messages = vm.messages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = vm.isMyMessage(message);

        // فاصل اليوم
        final showDateDivider = index == 0 ||
            DateFormatter.isDifferentDay(
              messages[index - 1].timestamp,
              message.timestamp,
            );

        return Column(
          children: [
            if (showDateDivider) _buildDateDivider(context, message.timestamp),

            // الرسالة مع أنيميشن ظهور
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: MessageBubble(
                message: message,
                isMe: isMe,
                showSenderName: widget.chat.isGroup,
                onReply: () => vm.setReplyTo(message),
                onDelete: isMe ? () => vm.deleteMessage(message.id) : null,
                onReact: (emoji) => vm.addReaction(message.id, emoji),
              ),
            ),

            // مؤشر الكتابة
            if (index == messages.length - 1 &&
                widget.chat.isOtherTyping(vm.currentUid))
              const TypingIndicator(),
          ],
        );
      },
    );
  }

  /// Bottom sheet بخيارات حظر/إبلاغ في المحادثة الفردية
  void _showOneOnOneOptions(BuildContext context) {
    if (widget.chat.isGroup) return;
    final otherUid = widget.chat.getOtherUserId(
      context.read<AuthViewModel>().currentUid ?? '',
    );
    if (otherUid.isEmpty) return;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXxl)),
      ),
      builder: (sheetCtx) => SafeArea(
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
                leading: const Icon(Icons.block_rounded,
                    color: AppColors.error),
                title: Text(l10n.blockUser,
                    style: const TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await _confirmBlock(context, otherUid);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: AppColors.warning),
                title: Text(l10n.reportUser),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  showReportSheet(
                    context,
                    reportedUserId: otherUid,
                    chatId: widget.chat.id,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBlock(BuildContext context, String otherUid) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: Text(l10n.blockUser),
        content: Text(l10n.blockConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.blockUser),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await context.read<ModerationService>().blockUser(otherUid);
    if (!context.mounted) return;
    SnackBarHelper.showSuccess(context, l10n.userBlocked);
    Navigator.of(context).pop(); // back to chats list
  }

  Widget _buildDateDivider(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              ),
              child: Text(
                DateFormatter.formatDateDivider(date, context),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
