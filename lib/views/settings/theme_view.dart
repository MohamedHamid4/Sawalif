import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/theme_viewmodel.dart';

/// شاشة اختيار الثيم (فاتح/داكن/تابع للنظام)
class ThemeView extends StatelessWidget {
  const ThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme)),
      body: Consumer<ThemeViewModel>(
        builder: (context, vm, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              _ThemeTile(
                icon: Icons.light_mode_rounded,
                title: l10n.lightMode,
                isSelected: vm.isLight,
                onTap: () => vm.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(height: AppSizes.sm),
              _ThemeTile(
                icon: Icons.dark_mode_rounded,
                title: l10n.darkMode,
                isSelected: vm.isDark,
                onTap: () => vm.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(height: AppSizes.sm),
              _ThemeTile(
                icon: Icons.settings_suggest_rounded,
                title: l10n.systemMode,
                isSelected: vm.isSystem,
                onTap: () => vm.setThemeMode(ThemeMode.system),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : null,
              size: 28,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
