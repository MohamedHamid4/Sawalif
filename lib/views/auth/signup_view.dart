import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/animations/fade_in_animation.dart';

/// حالة التحقق من توفر اسم المستخدم
enum _UsernameStatus { idle, checking, available, taken, invalid }

/// شاشة إنشاء حساب جديد
class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Timer? _usernameDebounce;
  _UsernameStatus _usernameStatus = _UsernameStatus.idle;
  String _lastCheckedUsername = '';

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String raw) {
    _usernameDebounce?.cancel();
    final normalized = Validators.normalizeUsername(raw);

    // إذا كان شكل الاسم غير صالح، لا نفحص الخادم
    if (Validators.validateUsername(normalized, context) != null) {
      setState(() => _usernameStatus = _UsernameStatus.invalid);
      return;
    }

    setState(() => _usernameStatus = _UsernameStatus.checking);

    _usernameDebounce = Timer(const Duration(milliseconds: 300), () async {
      final available = await context
          .read<AuthViewModel>()
          .isUsernameAvailable(normalized);
      if (!mounted) return;
      // إذا تغيّر الاسم خلال الانتظار، تجاهل النتيجة
      if (Validators.normalizeUsername(_usernameController.text) != normalized) {
        return;
      }
      setState(() {
        _lastCheckedUsername = normalized;
        _usernameStatus =
            available ? _UsernameStatus.available : _UsernameStatus.taken;
      });
    });
  }

  String? _usernameValidator(String? value) {
    final l10n = AppLocalizations.of(context);
    final formatError = Validators.validateUsername(
      value == null ? null : Validators.normalizeUsername(value),
      context,
    );
    if (formatError != null) return formatError;
    if (_usernameStatus == _UsernameStatus.taken) return l10n.usernameTaken;
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final username = Validators.normalizeUsername(_usernameController.text);

    // إذا لم نُتم فحص التوفر بعد، انتظر التحقق
    if (_usernameStatus == _UsernameStatus.checking ||
        _lastCheckedUsername != username) {
      SnackBarHelper.showInfo(context, l10n.checkingUsername);
      return;
    }
    if (_usernameStatus != _UsernameStatus.available) {
      SnackBarHelper.showError(context, l10n.usernameTaken);
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.signUp(
      name: _nameController.text.trim(),
      username: username,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
    } else {
      SnackBarHelper.showError(context, vm.localizedError(context));
    }
  }

  Widget _buildUsernameStatus(AppLocalizations l10n) {
    switch (_usernameStatus) {
      case _UsernameStatus.checking:
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.xs),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                l10n.checkingUsername,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      case _UsernameStatus.available:
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.xs),
          child: Text(
            l10n.usernameAvailable,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case _UsernameStatus.taken:
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.xs),
          child: Text(
            l10n.usernameTaken,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case _UsernameStatus.idle:
      case _UsernameStatus.invalid:
        return const SizedBox.shrink();
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
                const SizedBox(height: AppSizes.md),

                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSizes.md),

                FadeInAnimation(
                  delay: const Duration(milliseconds: 100),
                  slideFrom: const Offset(0, 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.createAccount,
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

                // ===== الاسم الكامل =====
                FadeInAnimation(
                  delay: const Duration(milliseconds: 200),
                  slideFrom: const Offset(0, 0.3),
                  child: CustomTextField(
                    controller: _nameController,
                    label: l10n.name,
                    hint: l10n.nameHint,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.validateName(v, context),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ===== اسم المستخدم =====
                FadeInAnimation(
                  delay: const Duration(milliseconds: 250),
                  slideFrom: const Offset(0, 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _usernameController,
                        label: l10n.username,
                        hint: l10n.usernameHint,
                        prefixIcon: Icons.alternate_email_rounded,
                        textInputAction: TextInputAction.next,
                        onChanged: _onUsernameChanged,
                        validator: _usernameValidator,
                      ),
                      _buildUsernameStatus(l10n),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ===== الإيميل =====
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
                    validator: (v) => Validators.validateEmail(v, context),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

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
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.validatePassword(v, context),
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

                const SizedBox(height: AppSizes.md),

                FadeInAnimation(
                  delay: const Duration(milliseconds: 500),
                  slideFrom: const Offset(0, 0.3),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) => CustomTextField(
                      controller: _confirmPasswordController,
                      label: l10n.confirmPassword,
                      hint: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !vm.isConfirmPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signup(),
                      validator: (v) => Validators.validateConfirmPassword(
                          v, _passwordController.text, context),
                      suffixWidget: GestureDetector(
                        onTap: vm.toggleConfirmPasswordVisibility,
                        child: Icon(
                          vm.isConfirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                FadeInAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) => CustomButton(
                      text: l10n.createAccount,
                      onPressed: _signup,
                      isLoading: vm.isLoading,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                FadeInAnimation(
                  delay: const Duration(milliseconds: 650),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.haveAccount,
                          style: const TextStyle(
                              color: AppColors.lightTextSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            l10n.login,
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

