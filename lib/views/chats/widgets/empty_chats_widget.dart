import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/common/empty_state.dart';

/// حالة عدم وجود محادثات
class EmptyChatsWidget extends StatelessWidget {
  final VoidCallback? onStartChat;

  const EmptyChatsWidget({super.key, this.onStartChat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      animationPath: AppAssets.emptyChats,
      title: l10n.noChats,
      description: l10n.noChatsDesc,
      buttonText: l10n.startChat,
      onButtonTap: onStartChat,
    );
  }
}
