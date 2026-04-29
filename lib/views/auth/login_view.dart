import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/animations/fade_in_animation.dart';

/// شاشة تسجيل الدخول
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _shakeEmail = false;
  bool _shakePassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _shakeEmail = true;
        _shakePassword = true;
      });
      Future.delayed(
        const Duration(milliseconds: 500),
        () => setState(() {
          _shakeEmail = false;
          _shakePassword = false;
        }),
      );
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
    } else {
      SnackBarHelper.showError(context, vm.localizedError(context));
    }
  }

  Future<void> _googleLogin() async {
    final vm = context.read<AuthViewModel>();
    final success = await vm.signInWithGoogle();

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
    } else if (vm.errorCode != null) {
      SnackBarHelper.showError(context, vm.localizedError(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),

                // اللوغو
                const FadeInAnimation(
                  delay: Duration(milliseconds: 100),
                  slideFrom: Offset(0, -0.3),
                  child: Center(child: AppLogo(size: 100)),
                ),

                const SizedBox(height: AppSizes.xl),

                // العنوان
                FadeInAnimation(
                  delay: const Duration(milliseconds: 200),
                  slideFrom: const Offset(0, 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.login,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        l10n.appSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // حقل الإيميل
                FadeInAnimation(
                  delay: const Duration(milliseconds: 300),
                  slideFrom: const Offset(0, 0.3),
                  child: CustomTextField(
                    controller: _emailController,
                    label: l10n.email,
                    hint: l10n.emailHint,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    validator: (v) => Validators.validateEmail(v, context),
                    shake: _shakeEmail,
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // حقل كلمة المرور
                FadeInAnimation(
                  delay: const Duration(milliseconds: 400),
                  slideFrom: const Offset(0, 0.3),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) => CustomTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      hint: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !vm.isPasswordVisible,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      validator: (v) =>
                          Validators.validatePassword(v, context),
                      shake: _shakePassword,
                      suffixWidget: GestureDetector(
                        onTap: vm.togglePasswordVisibility,
                        child: Icon(
                          vm.isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.sm),

                // نسيت كلمة المرور
                FadeInAnimation(
                  delay: const Duration(milliseconds: 450),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.forgotPassword),
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // زر تسجيل الدخول
                FadeInAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) => CustomButton(
                      text: l10n.login,
                      onPressed: _login,
                      isLoading: vm.isLoading,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // فاصل "أو"
                FadeInAnimation(
                  delay: const Duration(milliseconds: 550),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md),
                        child: Text(
                          l10n.or,
                          style: const TextStyle(
                              color: AppColors.lightTextSecondary),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // زر Google
                FadeInAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) => CustomButton(
                      text: l10n.signInGoogle,
                      onPressed: _googleLogin,
                      isLoading: vm.isLoading,
                      isOutlined: true,
                      prefixIcon: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // رابط التسجيل
                FadeInAnimation(
                  delay: const Duration(milliseconds: 650),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dontHaveAccount,
                          style: const TextStyle(
                              color: AppColors.lightTextSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.signup),
                          child: Text(
                            l10n.createAccount,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
