import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/moderation_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_avatar.dart';

/// شاشة المستخدمين المحظورين - مع زر إلغاء الحظر
class BlockedUsersView extends StatelessWidget {
  const BlockedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mod = context.read<ModerationService>();
    final userRepo = context.read<UserRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.blockedUsers)),
      body: StreamBuilder<List<String>>(
        stream: mod.blockedUsersStream(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final ids = snap.data!;
          if (ids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block_rounded,
                        size: 64,
                        color: AppColors.lightTextSecondary),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      l10n.noBlockedUsers,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.sm),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return FutureBuilder<UserModel?>(
                future: userRepo.getUser(ids[index]),
                builder: (context, userSnap) {
                  final user = userSnap.data;
                  return ListTile(
                    leading: CustomAvatar(
                      imageUrl: user?.photoUrl,
                      name: user?.name ?? '?',
                      size: AppSizes.avatarMd,
                    ),
                    title: Text(user?.name ?? '...',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: user?.username.isNotEmpty == true
                        ? Text('@${user!.username}')
                        : null,
                    trailing: TextButton(
                      onPressed: () async {
                        await mod.unblockUser(ids[index]);
                        if (!context.mounted) return;
                        SnackBarHelper.showSuccess(
                            context, l10n.userUnblocked);
                      },
                      child: Text(l10n.unblockUser),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
