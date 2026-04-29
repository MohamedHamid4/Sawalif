import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_avatar.dart';
import 'add_members_view.dart';

/// شاشة معلومات المجموعة - الأعضاء، إعدادات الأدمن، مغادرة
class GroupInfoView extends StatelessWidget {
  final String groupId;

  const GroupInfoView({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUid = context.read<AuthViewModel>().currentUid ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupInfo)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppStrings.colChats)
            .doc(groupId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data?.data() == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final group = ChatModel.fromFirestore(snap.data!);
          final isAdmin = group.isAdmin(currentUid);

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // ===== صورة + اسم =====
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: AppSizes.avatarXl / 2,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: group.groupPhotoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(group.groupPhotoUrl)
                          : null,
                      child: group.groupPhotoUrl.isEmpty
                          ? const Icon(Icons.group_rounded,
                              size: 40, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(group.groupName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    if (group.groupDescription.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        group.groupDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // ===== شريط الأعضاء =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.groupMembers} (${group.participants.length})',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (isAdmin)
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddMembersView(group: group),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_rounded),
                      label: Text(l10n.addMembers),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // ===== قائمة الأعضاء =====
              ...group.participants.map((uid) =>
                  _MemberTile(
                    uid: uid,
                    group: group,
                    currentUid: currentUid,
                    isAdminViewer: isAdmin,
                  )),

              const SizedBox(height: AppSizes.lg),

              // ===== مغادرة المجموعة =====
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(Icons.exit_to_app_rounded,
                      color: AppColors.error),
                ),
                title: Text(l10n.leaveGroup,
                    style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600)),
                onTap: () => _confirmLeave(context, currentUid),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLeave(BuildContext context, String currentUid) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: Text(l10n.leaveGroup),
        content: Text(l10n.leaveGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context
                  .read<ChatRepository>()
                  .leaveGroup(groupId, currentUid);
              if (!context.mounted) return;
              Navigator.of(context).pop(); // back to chat
              Navigator.of(context).pop(); // back to chats list
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.leaveGroup),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String uid;
  final ChatModel group;
  final String currentUid;
  final bool isAdminViewer;

  const _MemberTile({
    required this.uid,
    required this.group,
    required this.currentUid,
    required this.isAdminViewer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMember = uid == currentUid;
    final isMemberAdmin = group.isAdmin(uid);

    return FutureBuilder<UserModel?>(
      future: context.read<UserRepository>().getUser(uid),
      builder: (context, snap) {
        final user = snap.data;
        return ListTile(
          leading: CustomAvatar(
            imageUrl: user?.photoUrl,
            name: user?.name ?? '?',
            size: AppSizes.avatarMd,
          ),
          title: Text(user?.name ?? '...',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            user?.username.isNotEmpty == true ? '@${user!.username}' : '',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMemberAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    l10n.groupAdmin,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (isAdminViewer && !isMember)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (v) async {
                    final repo = context.read<ChatRepository>();
                    if (v == 'admin' && !isMemberAdmin) {
                      await repo.makeGroupAdmin(group.id, uid);
                    } else if (v == 'remove') {
                      await repo.removeGroupMember(group.id, uid);
                    }
                  },
                  itemBuilder: (_) => [
                    if (!isMemberAdmin)
                      PopupMenuItem(
                          value: 'admin', child: Text(l10n.makeAdmin)),
                    PopupMenuItem(
                        value: 'remove',
                        child: Text(l10n.removeMember,
                            style:
                                const TextStyle(color: AppColors.error))),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
