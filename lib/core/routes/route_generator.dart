import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'app_routes.dart';
import '../../views/splash/splash_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/signup_view.dart';
import '../../views/auth/forgot_password_view.dart';
import '../../views/chats/chats_list_view.dart';
import '../../views/chat/chat_view.dart';
import '../../views/users/search_user_view.dart';
import '../../views/qr/qr_scanner_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/profile/edit_profile_view.dart';
import '../../views/settings/settings_view.dart';
import '../../views/settings/language_view.dart';
import '../../views/settings/theme_view.dart';
import '../../views/settings/account_settings_view.dart';
import '../../views/settings/change_password_view.dart';
import '../../views/settings/delete_account_view.dart';
import '../../views/auth/choose_username_view.dart';
import '../../views/auth/auth_gate.dart';
import '../../views/groups/create_group_view.dart';
import '../../views/groups/group_info_view.dart';
import '../../views/moderation/blocked_users_view.dart';
import '../../views/about/about_view.dart';
import '../../data/models/chat_model.dart';

/// مولد المسارات مع أنيميشنز انتقال مخصصة
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashView(), settings);

      case AppRoutes.onboarding:
        return _slideUpRoute(const OnboardingView(), settings);

      case AppRoutes.login:
        return _slideRoute(const LoginView(), settings);

      case AppRoutes.signup:
        return _slideRoute(const SignupView(), settings);

      case AppRoutes.forgotPassword:
        return _slideRoute(const ForgotPasswordView(), settings);

      case AppRoutes.chatsList:
        return _fadeRoute(const ChatsListView(), settings);

      case AppRoutes.chat:
        final chatModel = settings.arguments as ChatModel;
        return _slideRoute(ChatView(chat: chatModel), settings);

      case AppRoutes.usersList:
      case AppRoutes.searchUser:
        return _slideRoute(const SearchUserView(), settings);

      case AppRoutes.qrScanner:
        return _slideUpRoute(const QrScannerView(), settings);

      case AppRoutes.profile:
        return _slideRoute(const ProfileView(), settings);

      case AppRoutes.editProfile:
        return _slideRoute(const EditProfileView(), settings);

      case AppRoutes.settings:
        return _slideRoute(const SettingsView(), settings);

      case AppRoutes.languageSettings:
        return _slideRoute(const LanguageView(), settings);

      case AppRoutes.themeSettings:
        return _slideRoute(const ThemeView(), settings);

      case AppRoutes.accountSettings:
        return _slideRoute(const AccountSettingsView(), settings);

      case AppRoutes.changePassword:
        return _slideRoute(const ChangePasswordView(), settings);

      case AppRoutes.deleteAccount:
        return _slideRoute(const DeleteAccountView(), settings);

      case AppRoutes.chooseUsername:
        return _fadeRoute(const ChooseUsernameView(), settings);

      case AppRoutes.authGate:
        return _fadeRoute(const AuthGate(), settings);

      case AppRoutes.createGroup:
        return _slideUpRoute(const CreateGroupView(), settings);

      case AppRoutes.groupInfo:
        final groupId = settings.arguments as String;
        return _slideRoute(GroupInfoView(groupId: groupId), settings);

      case AppRoutes.blockedUsers:
        return _slideRoute(const BlockedUsersView(), settings);

      case AppRoutes.about:
        return _slideRoute(const AboutView(), settings);

      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Builder(
                builder: (context) =>
                    Text(AppLocalizations.of(context).pageNotFound),
              ),
            ),
          ),
          settings,
        );
    }
  }

  /// انتقال Fade
  /// Curves.easeOutCubic أكثر "snappy" من easeInOut، و250ms يُحسّن الإحساس
  /// بالاستجابة على الأجهزة المتوسطة.
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// انتقال Slide من اليمين
  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final begin = Offset(isRtl ? -1.0 : 1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// انتقال Slide من الأسفل
  static PageRouteBuilder _slideUpRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
