import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/permission_service.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_avatar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// شاشة إنشاء مجموعة جديدة
class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selected = {};
  File? _pickedImage;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickGroupPhoto() async {
    final perm = PermissionService();
    if (!await perm.requestGallery()) {
      if (await perm.isPermanentlyDenied(Permission.photos) && mounted) {
        await perm.showOpenSettingsDialog(
          context: context,
          title: AppLocalizations.of(context).permissionGalleryTitle,
          message: AppLocalizations.of(context).permissionDeniedSettings,
        );
      }
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarHelper.showError(context, l10n.fieldRequired);
      return;
    }
    if (_selected.isEmpty) {
      SnackBarHelper.showError(context, l10n.minMembers);
      return;
    }

    setState(() => _isCreating = true);
    try {
      final chatRepo = context.read<ChatRepository>();
      final currentUid = context.read<AuthViewModel>().currentUid!;

      String? photoUrl;
      if (_pickedImage != null) {
        photoUrl = await chatRepo.uploadGroupImage(_pickedImage!);
      }

      final groupId = await chatRepo.createGroup(
        name: name,
        creatorId: currentUid,
        memberIds: _selected.toList(),
        description: _descController.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      SnackBarHelper.showSuccess(context, l10n.groupCreated);

      // افتح المجموعة - نُنشئ ChatModel محلياً للتنقل
      final chat = ChatModel(
        id: groupId,
        type: ChatType.group,
        groupName: name,
        groupPhotoUrl: photoUrl ?? '',
        groupAdminId: currentUid,
        groupAdmins: [currentUid],
        groupDescription: _descController.text.trim(),
        participants: [currentUid, ..._selected],
        lastMessage: AppStrings.markerGroupCreated,
        lastSenderId: currentUid,
        lastMessageTime: DateTime.now(),
        unreadCount: const {},
      );
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.chat,
        arguments: chat,
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUid = context.read<AuthViewModel>().currentUid ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createGroup)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ===== صورة المجموعة =====
          Center(
            child: GestureDetector(
              onTap: _pickGroupPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarXl / 2,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.group_rounded,
                            size: 40, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // ===== الاسم =====
          CustomTextField(
            controller: _nameController,
            label: l10n.groupName,
            hint: l10n.groupName,
            prefixIcon: Icons.title_rounded,
          ),
          const SizedBox(height: AppSizes.md),

          // ===== الوصف =====
          CustomTextField(
            controller: _descController,
            label: l10n.groupDescription,
            hint: l10n.groupDescription,
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.lg),

          // ===== اختيار الأعضاء =====
          Text(l10n.selectMembers,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 320,
            child: StreamBuilder<List<UserModel>>(
              stream: context
                  .read<UserRepository>()
                  .watchAllUsers(currentUid),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }
                final users = snap.data!;
                if (users.isEmpty) {
                  return Center(child: Text(l10n.noUsers));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final selected = _selected.contains(user.uid);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selected.add(user.uid);
                        } else {
                          _selected.remove(user.uid);
                        }
                      }),
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.trailing,
                      secondary: CustomAvatar(
                        imageUrl: user.photoUrl,
                        name: user.name,
                        size: AppSizes.avatarMd,
                      ),
                      title: Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      subtitle:
                          user.username.isNotEmpty ? Text('@${user.username}') : null,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          CustomButton(
            text: l10n.createGroup,
            onPressed: _create,
            isLoading: _isCreating,
          ),
        ],
      ),
    );
  }
}
