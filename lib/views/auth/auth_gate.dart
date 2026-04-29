import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/onesignal_service.dart';
import '../../data/services/stories_service.dart';
import '../chats/chats_list_view.dart';
import 'choose_username_view.dart';
import 'login_view.dart';

/// بوابة المصادقة - تقرر تلقائياً أين يذهب المستخدم بناءً على حالته:
/// - غير مصادق → LoginView
/// - مصادق بدون username → ChooseUsernameView
/// - مصادق بـ username → ChatsListView
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _GateLoading();
        }
        if (!authSnap.hasData) return const LoginView();

        final uid = authSnap.data!.uid;
        // ربط OneSignal + تنظيف الحالات المنتهية - مرة واحدة بعد المصادقة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<OneSignalService>().linkUser(uid);
          StoriesService().cleanupExpiredStories();
        });
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AppStrings.colUsers)
              .doc(uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _GateLoading();
            }
            // إذا اختفت وثيقة المستخدم (مثلاً بعد حذف الحساب)، اعرض login
            if (!userSnap.hasData || userSnap.data?.data() == null) {
              return const LoginView();
            }
            final data = userSnap.data!.data() as Map<String, dynamic>;
            final username =
                data[AppStrings.fieldUsername] as String? ?? '';

            if (username.isEmpty) {
              return const ChooseUsernameView();
            }
            return const ChatsListView();
          },
        );
      },
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
