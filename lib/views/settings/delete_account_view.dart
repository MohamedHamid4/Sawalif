import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/account_settings_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// شاشة حذف الحساب - تتطلب كتابة "حذف" وكلمة المرور (أو إعادة Google sign-in)
class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  final _confirmController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_onChanged);
    _passwordController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _confirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _canDelete(AppLocalizations l10n, AccountSettingsViewModel vm) {
    if (vm.isLoading) return false;
    if (_confirmController.text.trim() != l10n.typeDeleteWord) return false;
    if (vm.isGoogleAccount) return true;
    return _passwordController.text.length >= 6;
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final vm = context.read<AccountSettingsViewModel>();
    final authVm = context.read<AuthViewModel>();
    final uid = authVm.currentUid;
    if (uid == null) return;

    final success = await vm.deleteAccount(
      uid: uid,
      password: vm.isGoogleAccount ? null : _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, l10n.accountDeleted);
      // مسح ViewModel state ثم العودة لشاشة تسجيل الدخول
      authVm.setCurrentUser(null);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } else {
      SnackBarHelper.showError(context, _errorMessage(vm.error, l10n));
    }
  }

  String _errorMessage(String? code, AppLocalizations l10n) {
    switch (code) {
      case 'wrong_password':
        return l10n.wrongPassword;
      case 'reauth_required':
        return l10n.reauthRequired;
      default:
        return l10n.deletionFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccount)),
      body: Consumer<AccountSettingsViewModel>(
        builder: (context, vm, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== أيقونة تحذير =====
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 56, color: AppColors.error),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                l10n.deleteAccount,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                l10n.deleteAccountWarning,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Text(
                  l10n.deleteAccountItems,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // ===== حقل التأكيد =====
              CustomTextField(
                controller: _confirmController,
                label: l10n.typeToConfirm,
                hint: l10n.typeDeleteWord,
                prefixIcon: Icons.edit_rounded,
              ),
              const SizedBox(height: AppSizes.md),

              // ===== كلمة المرور (للحسابات بالإيميل فقط) =====
              if (!vm.isGoogleAccount)
                CustomTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  hint: l10n.passwordHint,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !_showPassword,
                  suffixWidget: GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),
              if (!vm.isGoogleAccount) const SizedBox(height: AppSizes.lg),

              // ===== زر الحذف =====
              CustomButton(
                text: l10n.deleteAccount,
                onPressed: _canDelete(l10n, vm) ? _delete : null,
                isLoading: vm.isLoading,
                gradient: const LinearGradient(
                  colors: [AppColors.error, AppColors.error],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
