import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/story_model.dart';
import '../../data/services/stories_service.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'create_story_view.dart';
import 'story_viewer.dart';

/// شريط أفقي لعرض الحالات في أعلى قائمة المحادثات
class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final currentUid = auth.currentUid ?? '';
    final myPhotoUrl = auth.currentUser?.photoUrl ?? '';
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<StoryModel>>(
      stream: StoriesService().getActiveStories(),
      builder: (context, snap) {
        final stories = snap.data ?? const <StoryModel>[];
        final grouped = <String, List<StoryModel>>{};
        for (final s in stories) {
          grouped.putIfAbsent(s.userId, () => []).add(s);
        }

        final myStories = grouped[currentUid] ?? const <StoryModel>[];
        final otherUserIds =
            grouped.keys.where((id) => id != currentUid).toList();

        return SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            children: [
              _StoryCircle(
                isMyAddTile: true,
                hasStories: myStories.isNotEmpty,
                userName: l10n.myStory,
                photoUrl: myStories.isNotEmpty
                    ? myStories.first.userPhotoUrl
                    : myPhotoUrl,
                allViewed: false,
                onTap: () {
                  if (myStories.isEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CreateStoryView()),
                    );
                  } else {
                    _showMyStoryOptions(context, myStories, l10n);
                  }
                },
              ),
              ...otherUserIds.map((uid) {
                final userStories = grouped[uid]!;
                final allViewed =
                    userStories.every((s) => s.viewedBy.contains(currentUid));
                return _StoryCircle(
                  isMyAddTile: false,
                  hasStories: true,
                  userName: userStories.first.userName,
                  photoUrl: userStories.first.userPhotoUrl,
                  allViewed: allViewed,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewer(stories: userStories),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showMyStoryOptions(
    BuildContext context,
    List<StoryModel> myStories,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            ListTile(
              leading: const Icon(Icons.visibility_rounded),
              title: Text(l10n.viewMyStory),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryViewer(stories: myStories),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_photo_alternate_rounded,
                  color: AppColors.primary),
              title: Text(l10n.addNewImage),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CreateStoryView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              title: Text(
                l10n.deleteStory,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _confirmDeleteAllMyStories(context, myStories, l10n);
              },
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAllMyStories(
    BuildContext context,
    List<StoryModel> myStories,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l10n.deleteStory),
        content: Text(l10n.deleteMessageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final service = StoriesService();
    for (final s in myStories) {
      try {
        await service.deleteStory(s.id);
      } catch (_) {}
    }
  }
}

class _StoryCircle extends StatelessWidget {
  final bool isMyAddTile;
  final bool hasStories;
  final String userName;
  final String photoUrl;
  final bool allViewed;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.isMyAddTile,
    required this.hasStories,
    required this.userName,
    required this.photoUrl,
    required this.allViewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // المنطق:
    //  - إذا كانت القصص موجودة → نعرض الحلقة (متدرّج عند الجديد، رمادي عند المُشاهَد).
    //  - إذا لا قصص (بطاقة "حالتي" فقط، لأن الآخرين بدون قصص لا يظهرون أصلاً) → بدون حلقة.
    final showRing = hasStories;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSizes.sm),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: showRing
                          ? const EdgeInsets.all(2.5)
                          : EdgeInsets.zero,
                      decoration: showRing
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: !allViewed
                                  ? AppColors.primaryGradient
                                  : null,
                              color:
                                  allViewed ? AppColors.lightDivider : null,
                            )
                          : null,
                      child: Container(
                        padding: showRing
                            ? const EdgeInsets.all(2)
                            : EdgeInsets.zero,
                        decoration: showRing
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                color: scaffoldBg,
                              )
                            : null,
                        child: ClipOval(
                          child: photoUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _placeholder(),
                                )
                              : _placeholder(),
                        ),
                      ),
                    ),
                    if (isMyAddTile)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: scaffoldBg,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.person, color: AppColors.primary),
      );
}
