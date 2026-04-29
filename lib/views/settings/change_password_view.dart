import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/account_settings_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// شاشة تغيير كلمة المرور (للحسابات بالإيميل)
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final vm = context.read<AccountSettingsViewModel>();

    final success = await vm.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );

    if (!mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, l10n.passwordChanged);
      Navigator.of(context).pop();
    } else {
      SnackBarHelper.showError(context, _errorMessage(vm.error, l10n));
    }
  }

  String _errorMessage(String? code, AppLocalizations l10n) {
    switch (code) {
      case 'wrong_password':
        return l10n.wrongPassword;
      case 'password_too_weak':
        return l10n.passwordTooWeak;
      case 'reauth_required':
        return l10n.reauthRequired;
      default:
        return l10n.errorUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _currentController,
                label: l10n.currentPassword,
                hint: l10n.passwordHint,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: !_showCurrent,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.validatePassword(v, context),
                suffixWidget: GestureDetector(
                  onTap: () => setState(() => _showCurrent = !_showCurrent),
                  child: Icon(
                    _showCurrent
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _newController,
                label: l10n.newPassword,
                hint: l10n.passwordHint,
                prefixIcon: Icons.lock_reset_rounded,
                obscureText: !_showNew,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.validatePassword(v, context),
                suffixWidget: GestureDetector(
                  onTap: () => setState(() => _showNew = !_showNew),
                  child: Icon(
                    _showNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _confirmController,
                label: l10n.confirmNewPassword,
                hint: l10n.passwordHint,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: !_showConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.validateConfirmPassword(
                    v, _newController.text, context),
                suffixWidget: GestureDetector(
                  onTap: () => setState(() => _showConfirm = !_showConfirm),
                  child: Icon(
                    _showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Consumer<AccountSettingsViewModel>(
                builder: (context, vm, _) => CustomButton(
                  text: l10n.saveChanges,
                  onPressed: _submit,
                  isLoading: vm.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
