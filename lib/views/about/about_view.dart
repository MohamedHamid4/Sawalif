import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_logo.dart';

/// شاشة "عن التطبيق" - تعرض الوصف، المميزات، ومعلومات المطوّر
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const String _developerWebsite =
      'https://mohamedhamid4.github.io/MohamedHamid.com/';

  Future<void> _openWebsite(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(_developerWebsite);
    try {
      final ok =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        SnackBarHelper.showError(context, l10n.errorUnknown);
      }
    } catch (_) {
      if (context.mounted) {
        SnackBarHelper.showError(context, l10n.errorUnknown);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.lg),
            const AppLogo(size: 120),
            const SizedBox(height: AppSizes.md),
            Text(
              l10n.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              '${l10n.appVersion}: ${AppStrings.appVersion}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // ===== بطاقة الوصف =====
            _SectionCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: l10n.aboutApp,
              child: Text(
                isArabic
                    ? 'سوالف تطبيق محادثات حديث ومُبتكر يجمع الأصدقاء والعائلة في تجربة دردشة سلسة وآمنة. يدعم المحادثات الفردية والجماعية، الحالات اليومية، البحث بأسماء المستخدمين، والإشعارات الفورية. مصمَّم بواجهة عربية أنيقة ومميزات احترافية تجعل التواصل أسهل ومتعة.'
                    : 'Sawalif is a modern messaging app that brings friends and family together with a smooth, secure chat experience. It features one-on-one and group chats, daily stories, username search, and real-time notifications. Designed with a sleek interface and professional features to make communication easier and more enjoyable.',
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ===== بطاقة المميزات =====
            _SectionCard(
              icon: Icons.star_outline_rounded,
              title: l10n.aboutFeatures,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureRow(
                    icon: Icons.message_outlined,
                    text: isArabic
                        ? 'محادثات فردية وجماعية'
                        : 'One-on-one & group chats',
                  ),
                  _FeatureRow(
                    icon: Icons.auto_awesome_outlined,
                    text: isArabic
                        ? 'حالات يومية تختفي بعد 24 ساعة'
                        : 'Daily stories (24h)',
                  ),
                  _FeatureRow(
                    icon: Icons.qr_code_scanner_outlined,
                    text: isArabic
                        ? 'مشاركة عبر QR Code'
                        : 'QR code sharing',
                  ),
                  _FeatureRow(
                    icon: Icons.notifications_outlined,
                    text: isArabic
                        ? 'إشعارات فورية'
                        : 'Real-time notifications',
                  ),
                  _FeatureRow(
                    icon: Icons.shield_outlined,
                    text: isArabic ? 'خصوصية وأمان' : 'Privacy & security',
                  ),
                  _FeatureRow(
                    icon: Icons.dark_mode_outlined,
                    text: isArabic ? 'الوضع الليلي' : 'Dark mode',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ===== بطاقة المطوّر =====
            _SectionCard(
              icon: Icons.person_outline_rounded,
              title: l10n.aboutDeveloper,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'M',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    isArabic ? 'محمد حامد' : 'Mohamed Hamid',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? 'مطوّر تطبيقات' : 'Mobile App Developer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    isArabic
                        ? 'فلسطيني • شغوف بالتقنية والبرمجة'
                        : 'Palestinian • Passionate about tech & coding',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWebsite(context),
                      icon: const Icon(Icons.language_rounded),
                      label: Text(l10n.visitWebsite),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
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
            const SizedBox(height: AppSizes.lg),

            // ===== التذييل =====
            Text(
              isArabic
                  ? 'صُنع بـ ❤️ في فلسطين'
                  : 'Made with ❤️ in Palestine',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              isArabic
                  ? '© 2026 سوالف. جميع الحقوق محفوظة.'
                  : '© 2026 Sawalif. All rights reserved.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
