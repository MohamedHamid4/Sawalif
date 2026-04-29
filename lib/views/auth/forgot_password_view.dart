import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/animations/fade_in_animation.dart';

/// شاشة نسيت كلمة المرور
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AuthViewModel>();
    final success =
        await vm.sendPasswordResetEmail(_emailController.text.trim());

    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
      SnackBarHelper.showSuccess(context, AppLocalizations.of(context).resetLinkSent);
    } else {
      SnackBarHelper.showError(context, vm.localizedError(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر الرجوع
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSizes.lg),

                // أيقونة
                FadeInAnimation(
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // العنوان
                FadeInAnimation(
                  delay: const Duration(milliseconds: 150),
                  slideFrom: const Offset(0, 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.resetPassword,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        l10n.resetPasswordDesc,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                if (!_emailSent) ...[
                  // حقل الإيميل
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 250),
                    slideFrom: const Offset(0, 0.3),
                    child: CustomTextField(
                      controller: _emailController,
                      label: l10n.email,
                      hint: l10n.emailHint,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _sendResetLink(),
                      validator: (v) => Validators.validateEmail(v, context),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // زر الإرسال
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 350),
                    child: Consumer<AuthViewModel>(
                      builder: (context, vm, _) => CustomButton(
                        text: l10n.sendResetLink,
                        onPressed: _sendResetLink,
                        isLoading: vm.isLoading,
                      ),
                    ),
                  ),
                ] else ...[
                  // رسالة نجاح
                  FadeInAnimation(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.success, size: 28),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Text(
                              l10n.resetLinkSent,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  FadeInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: CustomButton(
                      text: l10n.back,
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
