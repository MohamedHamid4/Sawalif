import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/utils/snackbar_helper.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/account_settings_viewmodel.dart';

/// شريط تأكيد البريد الإلكتروني
///
/// - يتحقق تلقائياً من حالة التأكيد عند العودة للتطبيق (lifecycle resume)
/// - يتحقق دورياً كل 30 ثانية ما دام البريد غير مؤكد
/// - يوفّر زرين: "تحقق الآن" + "إعادة إرسال"
/// - يختفي تلقائياً بمجرد تأكيد البريد (notifyListeners من الـ VM)
/// - مخفي للحسابات بـ Google (لا يحتاجون تأكيد بريد)
class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner>
    with WidgetsBindingObserver {
  Timer? _periodicTimer;
  bool _isCheckingNow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // فحص فوري عند البناء + بدء فحص دوري إذا كان البريد غير مؤكد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
      _startPeriodicCheck();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // عند العودة من فتح بريد التأكيد - أعد التحقق فوراً
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    final vm = context.read<AccountSettingsViewModel>();
    if (vm.isEmailVerified || vm.isGoogleAccount) return;
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final live = context.read<AccountSettingsViewModel>();
      if (live.isEmailVerified) {
        _periodicTimer?.cancel();
        return;
      }
      _refresh();
    });
  }

  Future<void> _refresh({bool fromButton = false}) async {
    if (!mounted) return;
    final vm = context.read<AccountSettingsViewModel>();
    if (vm.isGoogleAccount) return;

    if (fromButton) setState(() => _isCheckingNow = true);
    final wasVerified = vm.isEmailVerified;
    final nowVerified = await vm.refreshEmailVerified();
    if (!mounted) return;
    if (fromButton) setState(() => _isCheckingNow = false);

    if (!fromButton) return;

    final l10n = AppLocalizations.of(context);
    if (nowVerified) {
      SnackBarHelper.showSuccess(context, l10n.verifiedNow);
    } else if (!wasVerified) {
      SnackBarHelper.showWarning(context, l10n.notVerifiedYet);
    }
  }

  Future<void> _resend() async {
    if (!mounted) return;
    final vm = context.read<AccountSettingsViewModel>();
    final l10n = AppLocalizations.of(context);
    final ok = await vm.resendVerification();
    if (!mounted) return;
    if (ok) {
      SnackBarHelper.showSuccess(context, l10n.verificationSent);
    } else {
      SnackBarHelper.showError(context, l10n.errorUnknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountSettingsViewModel>(
      builder: (context, vm, _) {
        // مخفي للحسابات بـ Google ومؤكدي البريد
        if (vm.isGoogleAccount || vm.isEmailVerified) {
          _periodicTimer?.cancel();
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context);
        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      l10n.emailNotVerified,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                l10n.verifyEmailMessage,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCheckingNow || vm.isLoading
                          ? null
                          : () => _refresh(fromButton: true),
                      icon: _isCheckingNow
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                      label: Text(l10n.verifyNow),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: vm.isLoading ? null : _resend,
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: Text(l10n.resend),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
