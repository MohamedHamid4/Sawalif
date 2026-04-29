import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_avatar.dart';
import '../../widgets/common/custom_button.dart';

/// إضافة أعضاء جدد لمجموعة موجودة
class AddMembersView extends StatefulWidget {
  final ChatModel group;
  const AddMembersView({super.key, required this.group});

  @override
  State<AddMembersView> createState() => _AddMembersViewState();
}

class _AddMembersViewState extends State<AddMembersView> {
  final Set<String> _selected = {};
  bool _isAdding = false;

  Future<void> _add() async {
    if (_selected.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final repo = context.read<ChatRepository>();
    setState(() => _isAdding = true);
    try {
      for (final uid in _selected) {
        await repo.addGroupMember(widget.group.id, uid);
      }
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, l10n.done);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      SnackBarHelper.showError(context, l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUid = context.read<AuthViewModel>().currentUid ?? '';
    final existing = widget.group.participants.toSet();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addMembers)),
      body: Column(
        children: [
          Expanded(
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
                final users =
                    snap.data!.where((u) => !existing.contains(u.uid)).toList();
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
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: CustomButton(
              text: l10n.addMembers,
              onPressed: _selected.isEmpty ? null : _add,
              isLoading: _isAdding,
            ),
          ),
        ],
      ),
    );
  }
}
