import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/story_model.dart';
import '../../data/services/stories_service.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// شاشة عرض القصص بشكل ملء الشاشة - 5 ثوانٍ لكل حالة
class StoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  static const _storyDuration = Duration(seconds: 5);

  late int _index;
  late AnimationController _progress;
  bool _isPaused = false;
  // معرّف يتغيّر مع كل forward() جديد، حتى نُهمل أي whenComplete
  // مُعلَّق يخصّ تشغيلاً سابقاً (تجنّب القفز إلى التالي بعد التوقف).
  int _runId = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _progress = AnimationController(vsync: this, duration: _storyDuration);
    _start();
  }

  void _start() {
    _progress.reset();
    _markCurrentViewed();
    _runForward();
  }

  /// يُشغّل الأنيميشن للأمام ويربط whenComplete مع حماية من السباقات.
  /// كل استدعاء يأخذ runId خاصاً به؛ إذا تغيّرت القصة (next/prev) أو
  /// تمّ التوقّف (pause)، نتجاهل الإكمال القادم من الـ run السابق.
  void _runForward() {
    final myRun = ++_runId;
    _progress.forward().whenComplete(() {
      if (!mounted) return;
      if (myRun != _runId) return; // run قديم — تجاهل
      if (_progress.value < 1.0) return; // أوقفنا قبل اكتمال
      _next();
    });
  }

  void _markCurrentViewed() {
    final currentUid = context.read<AuthViewModel>().currentUid;
    final story = widget.stories[_index];
    if (currentUid != null &&
        currentUid != story.userId &&
        !story.viewedBy.contains(currentUid)) {
      StoriesService().markAsViewed(story.id);
    }
  }

  void _pause() {
    if (_isPaused) return;
    _progress.stop(canceled: false);
    // نُلغي صلاحية أي whenComplete مُعلَّق
    _runId++;
    setState(() => _isPaused = true);
  }

  void _resume() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    if (_progress.value >= 1.0) {
      _next();
      return;
    }
    _runForward();
  }

  void _next() {
    if (_index >= widget.stories.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _isPaused = false;
    });
    _start();
  }

  void _prev() {
    if (_index == 0) {
      // أعِد تشغيل القصة الحالية من البداية (سلوك Instagram)
      _start();
      return;
    }
    setState(() {
      _index--;
      _isPaused = false;
    });
    _start();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: Text(l10n.deleteStory),
        content: Text(l10n.deleteStory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await StoriesService().deleteStory(widget.stories[_index].id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_index];
    final currentUid = context.read<AuthViewModel>().currentUid;
    final isMine = currentUid == story.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الصورة بملء الشاشة
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: story.imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.error_outline, color: Colors.white),
            ),
          ),

          // ===== طبقة الإيماءات =====
          // ثلاث مناطق أفقية: يسار / وسط / يمين.
          // كلها تلتقط onLongPress (إيقاف/استئناف). اليسار/اليمين فقط
          // ينقلان عند النقر السريع. الوسط يبقى للإيقاف فقط.
          // onTapDown/onTapUp يُعطيان شعور إيقاف فوري عند مجرد لمس الشاشة.
          // ملاحظة: السحب العمودي نضعه على Stack-level في الأسفل.
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: _ZoneGesture(
                    onPause: _pause,
                    onResume: _resume,
                    onTap: _prev,
                  ),
                ),
                Expanded(
                  child: _ZoneGesture(
                    onPause: _pause,
                    onResume: _resume,
                    // الوسط لا ينقّل — فقط إيقاف/استئناف
                  ),
                ),
                Expanded(
                  child: _ZoneGesture(
                    onPause: _pause,
                    onResume: _resume,
                    onTap: _next,
                  ),
                ),
              ],
            ),
          ),

          // السحب لأسفل لإغلاق الـ viewer (فوق طبقة الإيماءات بحجم
          // محدود في الأعلى لتجنّب ابتلاع الإيماءات الأخرى)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 200) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),

          // ===== شريط التقدّم (يبقى مرئياً حتى عند الإيقاف) =====
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Row(
                    children: List.generate(
                      widget.stories.length,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  i == 0 || i == widget.stories.length - 1
                                      ? 1
                                      : 2),
                          child: AnimatedBuilder(
                            animation: _progress,
                            builder: (_, __) => LinearProgressIndicator(
                              value: i < _index
                                  ? 1.0
                                  : i > _index
                                      ? 0.0
                                      : _progress.value,
                              minHeight: 3,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ===== رأس الواجهة (اسم/وقت/إغلاق) =====
                // يختفي أثناء الضغط المطوّل لتجربة عرض نظيفة.
                AnimatedOpacity(
                  opacity: _isPaused ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  // IgnorePointer كي لا تظل أزرار الإغلاق/الحذف نشطة
                  // وهي مخفية (تفادي نقرة عرضية أثناء الضغط).
                  child: IgnorePointer(
                    ignoring: _isPaused,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: story.userPhotoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    story.userPhotoUrl)
                                : null,
                            child: story.userPhotoUrl.isEmpty
                                ? const Icon(Icons.person,
                                    color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatLastSeen(
                                      story.createdAt, context),
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMine)
                            IconButton(
                              icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white),
                              onPressed: _delete,
                            ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // التعليق - يختفي أيضاً أثناء الإيقاف للحصول على عرض نظيف
          if (story.caption.isNotEmpty)
            Positioned(
              bottom: 32,
              left: AppSizes.md,
              right: AppSizes.md,
              child: AnimatedOpacity(
                opacity: _isPaused ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Text(
                    story.caption,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// منطقة إيماءات خفيفة الوزن داخل عارض القصص.
/// ترتيب الأولوية:
///  - onLongPressStart/End → إيقاف/استئناف (الضغط المطوّل)
///  - onTapDown → إيقاف فوري بمجرد اللمس
///  - onTapUp → استئناف ثم تنفيذ النقر (إن وُجد) للتنقل
///  - onTapCancel → استئناف (مثلاً إذا انسحب الإصبع كـ scroll)
class _ZoneGesture extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback? onTap;

  const _ZoneGesture({
    required this.onPause,
    required this.onResume,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => onPause(),
      onLongPressEnd: (_) => onResume(),
      onTapDown: (_) => onPause(),
      onTapCancel: onResume,
      onTapUp: (_) {
        onResume();
        onTap?.call();
      },
    );
  }
}
