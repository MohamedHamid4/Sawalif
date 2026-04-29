import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/common/custom_avatar.dart';
import '../../widgets/common/gradient_container.dart';
import '../../widgets/common/loading_indicator.dart';

/// شاشة عرض الملف الشخصي
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().currentUid;
      if (uid != null) context.read<ProfileViewModel>().loadUser(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const FullScreenLoading();

          final user = vm.user;
          if (user == null) {
            return Center(child: Text(l10n.errorUnknown));
          }

          return CustomScrollView(
            slivers: [
              // AppBar مع الصورة
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.sunsetGradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSizes.xxxl),
                        CustomAvatar(
                          imageUrl: user.photoUrl,
                          name: user.name,
                          size: AppSizes.avatarXxl,
                          showOnlineDot: true,
                          isOnline: true,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (user.username.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            '@${user.username}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.editProfile),
                  ),
                ],
              ),

              // المعلومات
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.screenPadding),
                  child: Column(
                    children: [
                      // البايو
                      if (user.bio.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLg),
                          ),
                          child: Text(
                            user.bio,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],

                      // معلومات إضافية
                      _buildInfoCard(context, [
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: l10n.email,
                          value: user.email,
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: l10n.joined,
                          value: DateFormatter.formatDateDivider(user.createdAt, context),
                        ),
                      ]),

                      // ===== بطاقة QR Code =====
                      if (user.username.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.md),
                        _buildQrCard(context, user.username, l10n),
                      ],

                      const SizedBox(height: AppSizes.lg),

                      // زر تعديل الملف الشخصي
                      GradientContainer(
                        padding: EdgeInsets.zero,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.editProfile),
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(l10n.editProfile),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize:
                                const Size(double.infinity, AppSizes.buttonHeight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// بطاقة QR + أزرار المشاركة والمسح
  Widget _buildQrCard(
      BuildContext context, String username, AppLocalizations l10n) {
    final qrData = '${AppStrings.qrUriScheme}://${AppStrings.qrUriUserHost}/$username';

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            l10n.myQrCode,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '@$username',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareProfile(username, l10n),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(l10n.share),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.qrScanner),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: Text(l10n.scan),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareProfile(String username, AppLocalizations l10n) {
    final link = '${AppStrings.qrUriScheme}://${AppStrings.qrUriUserHost}/$username';
    Share.share(
      '${l10n.addMeOnSawalif}\n@$username\n$link',
      subject: l10n.addMeOnSawalif,
    );
  }

  Widget _buildInfoCard(BuildContext context, List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: rows
            .map((row) => ListTile(
                  leading: Icon(row.icon, color: AppColors.primary),
                  title: Text(
                    row.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  subtitle: Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}
