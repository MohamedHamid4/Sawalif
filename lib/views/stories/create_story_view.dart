import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/permission_service.dart';
import '../../data/services/stories_service.dart';
import '../../l10n/app_localizations.dart';

/// شاشة إنشاء حالة جديدة (متعدّدة الصور)
///
/// التدفّق:
///   1. تفتح الشاشة → يُفتح المعرض مباشرة بوضع تعدّد الاختيار
///   2. يختار المستخدم صورة أو أكثر → معاينة بملء الشاشة + شريط مصغّرات
///   3. يضغط "نشر" → رفع كل صورة كحالة منفصلة → عودة
///   4. لو ألغى الاختيار قبل أي صورة → نُغلق الشاشة تلقائياً
class CreateStoryView extends StatefulWidget {
  const CreateStoryView({super.key});

  @override
  State<CreateStoryView> createState() => _CreateStoryViewState();
}

class _CreateStoryViewState extends State<CreateStoryView> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _imageFiles = [];
  bool _isPosting = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('[CreateStory] view opened');
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickFromGallery());
  }

  Future<void> _pickFromGallery() async {
    final l10n = AppLocalizations.of(context);

    final perm = PermissionService();
    if (!await perm.requestGallery()) {
      if (await perm.isPermanentlyDenied(Permission.photos) && mounted) {
        await perm.showOpenSettingsDialog(
          context: context,
          title: l10n.permissionGalleryTitle,
          message: l10n.permissionDeniedSettings,
        );
      }
      if (mounted && _imageFiles.isEmpty) Navigator.of(context).pop();
      return;
    }

    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (picked.isEmpty) {
        if (kDebugMode) debugPrint('[CreateStory] picker cancelled');
        if (mounted && _imageFiles.isEmpty) Navigator.of(context).pop();
        return;
      }

      if (kDebugMode) {
        debugPrint('[CreateStory] picked count=${picked.length}');
      }
      if (!mounted) return;
      setState(() {
        _imageFiles
          ..clear()
          ..addAll(picked.map((x) => File(x.path)));
        _currentIndex = 0;
      });
    } catch (e, st) {
      if (kDebugMode) debugPrint('[CreateStory] pick error: $e\n$st');
      if (!mounted) return;
      SnackBarHelper.showError(context, '${l10n.errorUnknown}: $e');
    }
  }

  Future<void> _addMoreFromGallery() async {
    final l10n = AppLocalizations.of(context);

    final perm = PermissionService();
    if (!await perm.requestGallery()) {
      if (await perm.isPermanentlyDenied(Permission.photos) && mounted) {
        await perm.showOpenSettingsDialog(
          context: context,
          title: l10n.permissionGalleryTitle,
          message: l10n.permissionDeniedSettings,
        );
      }
      return;
    }

    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() {
        _imageFiles.addAll(picked.map((x) => File(x.path)));
      });
    } catch (e, st) {
      if (kDebugMode) debugPrint('[CreateStory] add-more error: $e\n$st');
      if (!mounted) return;
      SnackBarHelper.showError(context, '${l10n.errorUnknown}: $e');
    }
  }

  void _removeImageAt(int index) {
    setState(() {
      _imageFiles.removeAt(index);
      if (_imageFiles.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= _imageFiles.length) {
        _currentIndex = _imageFiles.length - 1;
      }
    });
  }

  Future<void> _publish() async {
    if (_imageFiles.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final repo = context.read<ChatRepository>();
    final service = StoriesService();

    setState(() => _isPosting = true);

    int success = 0;
    int failed = 0;

    try {
      for (int i = 0; i < _imageFiles.length; i++) {
        try {
          if (kDebugMode) {
            debugPrint('[CreateStory] uploading ${i + 1}/${_imageFiles.length}');
          }
          final url = await repo.uploadStoryImage(_imageFiles[i]);
          await service.postStory(imageUrl: url);
          success++;
        } catch (e, st) {
          if (kDebugMode) debugPrint('[CreateStory] failed image $i: $e\n$st');
          failed++;
        }
      }

      if (!mounted) return;

      if (success > 0 && failed == 0) {
        SnackBarHelper.showSuccess(context, l10n.storyPosted);
        Navigator.of(context).pop(true);
      } else if (success > 0 && failed > 0) {
        SnackBarHelper.showWarning(
          context,
          '${l10n.storyPosted} ($success/${_imageFiles.length})',
        );
        Navigator.of(context).pop(true);
      } else {
        SnackBarHelper.showError(context, l10n.errorUploading);
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = _imageFiles.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(count > 1 ? '${l10n.addStory} ($count)' : l10n.addStory),
        elevation: 0,
      ),
      body: count == 0 ? _buildEmptyState(l10n) : _buildPreview(l10n),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            l10n.storyCaption,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_rounded),
            label: Text(l10n.chooseGallery),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xl, vertical: AppSizes.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    final current = _imageFiles[_currentIndex];

    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                current,
                key: ValueKey(current.path),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image_outlined,
                          size: 80, color: Colors.white54),
                      const SizedBox(height: AppSizes.md),
                      Text(l10n.errorLoading,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (_imageFiles.length > 1) _buildThumbStrip(),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              MediaQuery.of(context).padding.bottom + AppSizes.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isPosting ? null : _addMoreFromGallery,
                  icon: const Icon(Icons.add_photo_alternate_rounded,
                      color: Colors.white),
                  tooltip: l10n.addMoreImages,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.all(AppSizes.md),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPosting ? null : _publish,
                    icon: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(
                      _isPosting
                          ? l10n.uploadingStory
                          : (_imageFiles.length == 1
                              ? l10n.postStory
                              : '${l10n.postStory} (${_imageFiles.length})'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isPosting)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      _imageFiles.length == 1
                          ? l10n.uploadingStory
                          : '${l10n.uploadingStory} (${_imageFiles.length})',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThumbStrip() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm),
        color: Colors.black.withValues(alpha: 0.4),
        child: SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
            itemBuilder: (_, index) {
              final isSelected = index == _currentIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white24,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSm - 2),
                        child: Image.file(
                          _imageFiles[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (!_isPosting)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeImageAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.black, width: 1.5),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
