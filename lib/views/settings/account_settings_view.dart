import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/account_settings_viewmodel.dart';
import '../../widgets/email_verification_banner.dart';

/// شاشة إعدادات الحساب: تغيير كلمة المرور، تأكيد البريد، حذف الحساب
class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ===== شريط تأكيد البريد (مع auto-refresh على resume + كل 30 ثانية) =====
          const EmailVerificationBanner(),

          // ===== تغيير كلمة المرور (للحسابات بالإيميل فقط) =====
          Consumer<AccountSettingsViewModel>(
            builder: (context, vm, _) {
              if (vm.isGoogleAccount) return const SizedBox.shrink();
              return _AccountTile(
                icon: Icons.lock_outline_rounded,
                title: l10n.changePassword,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.changePassword),
              );
            },
          ),

          // ===== المستخدمون المحظورون =====
          _AccountTile(
            icon: Icons.block_rounded,
            title: l10n.blockedUsers,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.blockedUsers),
          ),

          const SizedBox(height: AppSizes.lg),

          // ===== حذف الحساب =====
          _AccountTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.deleteAccount,
            color: AppColors.error,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.deleteAccount),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(icon, color: tint, size: 22),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.lightTextSecondary),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}
