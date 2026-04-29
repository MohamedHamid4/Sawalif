import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/email_verification_banner.dart';

/// شاشة الإعدادات الرئيسية
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ===== شريط تأكيد البريد (auto-refresh + زر "تحقق الآن") =====
          const EmailVerificationBanner(),

          // ===== المظهر =====
          _SectionHeader(title: l10n.appearance),

          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.theme,
            subtitle: isDark ? l10n.darkMode : l10n.lightMode,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.themeSettings),
          ),

          _SettingsTile(
            icon: Icons.language_rounded,
            title: l10n.language,
            subtitle: AppLocalizations.of(context).isArabic ? 'العربية' : 'English',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.languageSettings),
          ),

          const SizedBox(height: AppSizes.md),

          // ===== الإشعارات =====
          _SectionHeader(title: l10n.notifications),

          Consumer<SettingsViewModel>(
            builder: (context, vm, _) => _SettingsSwitchTile(
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              subtitle: l10n.notificationsDesc,
              value: vm.notificationsEnabled,
              onChanged: vm.toggleNotifications,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // ===== الحساب =====
          _SectionHeader(title: l10n.account),

          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: l10n.profile,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),

          _SettingsTile(
            icon: Icons.manage_accounts_rounded,
            title: l10n.accountSettings,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.accountSettings),
          ),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.aboutApp,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
          ),

          _SettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.logout,
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _confirmLogout(context),
          ),

          const SizedBox(height: AppSizes.md),

          // إصدار التطبيق - نص ثابت، لا يحتاج Consumer
          Center(
            child: Text(
              '${l10n.appVersion}: ${AppStrings.appVersion}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthViewModel>().signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            )
          : null,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.lightTextSecondary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}
