import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/theme/app_themes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/moderation_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/onesignal_service.dart';
import 'data/services/presence_service.dart';
import 'data/services/storage_service.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'viewmodels/account_settings_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/chats_viewmodel.dart';
import 'viewmodels/locale_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/users_viewmodel.dart';
import 'widgets/common/connection_status_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===== ضروري قبل أوّل إطار =====
  // Firebase: AuthGate يبدأ بـ StreamBuilder على authStateChanges فوراً.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // اللغة: MaterialApp يقرأ locale/fontFamily منها مباشرة. تأجيلها يُسبّب
  // وميض لغوي قصير في أوّل تشغيل لأجهزة ذات لغة إنجليزية.
  final localeVM = LocaleViewModel();
  await localeVM.initialize();

  // قفل اتجاه الشاشة (سريع، يمنع ومضة landscape على الأجهزة اللوحية)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ===== تشغيل التطبيق فوراً =====
  runApp(SawalifApp(localeVM: localeVM));

  // ===== التهيئة المؤجَّلة (بعد أوّل إطار) =====
  // كل ما لا يحتاجه الـ splash / Login: تنسيق التواريخ والإشعارات.
  // unawaited لأننا لا نحتاج نتائجها هنا.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeDeferredServices());
  });
}

Future<void> _initializeDeferredServices() async {
  try {
    // تنسيق التواريخ (مطلوب في chat list وما بعدها — تأجيله بضع
    // مئات الميلي ثانية آمن لأنّ الـ AuthGate/Login لا يعرضان أي تاريخ).
    await Future.wait([
      initializeDateFormatting('ar', null),
      initializeDateFormatting('en', null),
    ]);

    // الإشعارات المحلية + FCM channel
    await NotificationService().initialize();

    // OneSignal (الأبطأ — كان يضيف ~500-1000ms إلى التشغيل البارد)
    await OneSignalService().initialize();
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[Startup] deferred init error: $e\n$st');
    }
  }
}

/// نقطة الدخول الرئيسية لتطبيق سوالف
class SawalifApp extends StatefulWidget {
  final LocaleViewModel localeVM;
  const SawalifApp({super.key, required this.localeVM});

  @override
  State<SawalifApp> createState() => _SawalifAppState();
}

class _SawalifAppState extends State<SawalifApp> with WidgetsBindingObserver {
  final PresenceService _presence = PresenceService();
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Init/dispose presence مع تغيّر حالة المصادقة.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _presence.initializePresence();
      } else {
        _presence.disposePresence();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _presence.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _presence.setOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ===== إعداد الـ Services =====
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();
    final notificationService = NotificationService();
    final oneSignalService = OneSignalService();

    // ===== إعداد الـ Repositories =====
    final userRepository = UserRepository(
      firestoreService: firestoreService,
      storageService: storageService,
    );

    final authRepository = AuthRepository(
      authService: authService,
      firestoreService: firestoreService,
      notificationService: notificationService,
      oneSignalService: oneSignalService,
    );

    final chatRepository = ChatRepository(
      firestoreService: firestoreService,
      storageService: storageService,
      userRepository: userRepository,
      oneSignalService: oneSignalService,
    );

    return MultiProvider(
      providers: [
        // ===== ViewModels =====
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        // اللغة - تم تهيئتها في main() قبل runApp
        ChangeNotifierProvider.value(value: widget.localeVM),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatsViewModel(repository: chatRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UsersViewModel(repository: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountSettingsViewModel(repository: authRepository),
        ),

        // ===== Repositories (للوصول المباشر من الـ Views) =====
        Provider.value(value: chatRepository),
        Provider.value(value: userRepository),
        Provider.value(value: authRepository),
        Provider.value(value: oneSignalService),
        Provider<ModerationService>(create: (_) => ModerationService()),
      ],
      child: Consumer2<ThemeViewModel, LocaleViewModel>(
        builder: (context, themeVm, localeVm, _) {
          // تحديد الثيم الفعلي (مع دعم وضع النظام)
          final isDark = themeVm.themeMode == ThemeMode.dark ||
              (themeVm.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          final activeTheme = isDark
              ? AppThemes.dark(localeVm.fontFamily)
              : AppThemes.light(localeVm.fontFamily);

          // تطبيق ألوان شريط الحالة وشريط التنقل
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: activeTheme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp(
            title: 'Sawalif',
            debugShowCheckedModeBanner: false,

            // ===== الثيم مع انيميشن انتقال سلس =====
            themeMode: themeVm.themeMode,
            theme: AppThemes.light(localeVm.fontFamily),
            darkTheme: AppThemes.dark(localeVm.fontFamily),
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeInOut,

            // ===== اللغة والـ Localization =====
            locale: localeVm.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ===== التوجيه =====
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            builder: (context, child) => ConnectionStatusBanner(
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
