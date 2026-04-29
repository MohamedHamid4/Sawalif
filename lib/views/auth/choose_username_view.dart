import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/animations/fade_in_animation.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// حالة التحقق من توفر اسم المستخدم
enum _UsernameStatus { idle, checking, available, taken, invalid }

/// شاشة اختيار اسم المستخدم - للمستخدمين القدامى الذين سجّلوا قبل نظام @username
/// لا يمكن الرجوع منها (PopScope) - يجب على المستخدم اختيار اسم
class ChooseUsernameView extends StatefulWidget {
  const ChooseUsernameView({super.key});

  @override
  State<ChooseUsernameView> createState() => _ChooseUsernameViewState();
}

class _ChooseUsernameViewState extends State<ChooseUsernameView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  Timer? _debounce;
  _UsernameStatus _status = _UsernameStatus.idle;
  String _lastChecked = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    _debounce?.cancel();
    final username = Validators.normalizeUsername(raw);
    if (Validators.validateUsername(username, context) != null) {
      setState(() => _status = _UsernameStatus.invalid);
      return;
    }
    setState(() => _status = _UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final available = await context
          .read<AuthRepository>()
          .isUsernameAvailable(username);
      if (!mounted) return;
      if (Validators.normalizeUsername(_usernameController.text) != username) {
        return;
      }
      setState(() {
        _lastChecked = username;
        _status = available
            ? _UsernameStatus.available
            : _UsernameStatus.taken;
      });
    });
  }

  String? _validate(String? raw) {
    final l10n = AppLocalizations.of(context);
    final username = Validators.normalizeUsername(raw ?? '');
    final formatError = Validators.validateUsername(username, context);
    if (formatError != null) return formatError;
    if (_status == _UsernameStatus.taken) return l10n.usernameTaken;
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final username = Validators.normalizeUsername(_usernameController.text);

    if (_status == _UsernameStatus.checking || _lastChecked != username) {
      SnackBarHelper.showInfo(context, l10n.checkingUsername);
      return;
    }
    if (_status != _UsernameStatus.available) {
      SnackBarHelper.showError(context, l10n.usernameTaken);
      return;
    }

    final uid = context.read<AuthViewModel>().currentUid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await context.read<UserRepository>().setUsername(uid, username);
      // AuthGate (StreamBuilder على وثيقة المستخدم) سيكتشف التغيير
      // ويعرض ChatsListView تلقائياً - لا حاجة للتنقل اليدوي
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackBarHelper.showError(context, l10n.errorUnknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          SnackBarHelper.showInfo(context, l10n.usernameCannotSkip);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.xxl),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 100),
                    slideFrom: const Offset(0, 0.3),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      ),
                      child: const Icon(Icons.alternate_email_rounded,
                          size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 200),
                    slideFrom: const Offset(0, 0.3),
                    child: Text(
                      l10n.chooseUsernameTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 250),
                    slideFrom: const Offset(0, 0.3),
                    child: Text(
                      l10n.chooseUsernameSubtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 300),
                    slideFrom: const Offset(0, 0.3),
                    child: CustomTextField(
                      controller: _usernameController,
                      label: l10n.username,
                      hint: l10n.usernameHint,
                      prefixIcon: Icons.alternate_email_rounded,
                      textInputAction: TextInputAction.done,
                      onChanged: _onChanged,
                      onSubmitted: (_) => _save(),
                      validator: _validate,
                    ),
                  ),
                  _buildStatus(l10n),
                  const SizedBox(height: AppSizes.xl),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: CustomButton(
                      text: l10n.saveUsername,
                      onPressed: _save,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(AppLocalizations l10n) {
    switch (_status) {
      case _UsernameStatus.checking:
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.xs),
          child: Row(children: [
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
          ]),
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
}
