import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/services/permission_service.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_avatar.dart';

/// شاشة تعديل الملف الشخصي
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<ProfileViewModel>().user;
      if (user != null) {
        _nameController.text = user.name;
        _bioController.text = user.bio;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
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
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: Text(l10n.takePhoto),
              onTap: () async {
                Navigator.pop(ctx);
                await _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: Text(l10n.chooseGallery),
              onTap: () async {
                Navigator.pop(ctx);
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
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked != null && mounted) {
      context.read<ProfileViewModel>().setSelectedImage(File(picked.path));
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = context.read<AuthViewModel>().currentUid ?? '';
    final vm = context.read<ProfileViewModel>();
    final l10n = AppLocalizations.of(context);

    final success = await vm.saveProfile(
      uid: uid,
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, l10n.profileUpdated);
      Navigator.of(context).pop();
    } else {
      SnackBarHelper.showError(context, vm.localizedError(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: AppSizes.md),

              // صورة الملف الشخصي
              Consumer<ProfileViewModel>(
                builder: (context, vm, _) => Stack(
                  children: [
                    vm.selectedImage != null
                        ? CircleAvatar(
                            radius: AppSizes.avatarXl / 2,
                            backgroundImage:
                                FileImage(vm.selectedImage!),
                          )
                        : CustomAvatar(
                            imageUrl: vm.user?.photoUrl,
                            name: vm.user?.name ?? '?',
                            size: AppSizes.avatarXl,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // الاسم
              CustomTextField(
                controller: _nameController,
                label: l10n.name,
                hint: l10n.nameHint,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) => Validators.validateName(v, context),
              ),

              const SizedBox(height: AppSizes.md),

              // البايو
              CustomTextField(
                controller: _bioController,
                label: l10n.bio,
                hint: l10n.bioHint,
                prefixIcon: Icons.info_outline_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: AppSizes.xl),

              // زر الحفظ
              Consumer<ProfileViewModel>(
                builder: (context, vm, _) => CustomButton(
                  text: l10n.saveChanges,
                  onPressed: _save,
                  isLoading: vm.isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
