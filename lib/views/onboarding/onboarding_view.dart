import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_gate.dart';

/// شاشة الإعداد التعريفي - 3 شاشات تفاعلية مع أنيميشن باستخدام أيقونات Material
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    // أنيميشن خلفية مستمر للحلقات الدوارة
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // حفظ علم الإعداد التعريفي حتى لا يظهر مجدداً
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.keyOnboardingDone, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AuthGate(),
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isArabic = t.locale.languageCode == 'ar';

    final pages = [
      _OnboardingPageData(
        icon: Icons.chat_bubble_rounded,
        title: isArabic ? 'تواصل مع أصدقائك' : 'Connect with Friends',
        subtitle: isArabic
            ? 'ابدأ سوالف ممتعة مع أصدقائك في أي وقت ومن أي مكان'
            : 'Start fun conversations with your friends anytime, anywhere',
        gradient: const [Color(0xFFFF6B35), Color(0xFFE63946)],
        decorIcons: const [Icons.favorite, Icons.tag_faces],
      ),
      _OnboardingPageData(
        icon: Icons.groups_rounded,
        title: isArabic ? 'مجموعات وحالات' : 'Groups & Stories',
        subtitle: isArabic
            ? 'أنشئ مجموعات مع أصدقائك وشارك حالاتك اليومية'
            : 'Create groups with friends and share your daily stories',
        gradient: const [Color(0xFFE63946), Color(0xFFFFB627)],
        decorIcons: const [Icons.auto_awesome, Icons.celebration],
      ),
      _OnboardingPageData(
        icon: Icons.shield_rounded,
        title: isArabic ? 'خصوصية وأمان' : 'Privacy & Security',
        subtitle: isArabic
            ? 'محادثاتك آمنة، تحكم كامل بخصوصيتك ومن يراك'
            : 'Your chats are secure, full control over your privacy',
        gradient: const [Color(0xFFFFB627), Color(0xFFFF6B35)],
        decorIcons: const [Icons.lock, Icons.verified_user],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ===== زر التخطي =====
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    isArabic ? 'تخطي' : 'Skip',
                    style: GoogleFonts.cairo(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // ===== الصفحات =====
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardingPage(
                  data: pages[i],
                  animController: _bgAnimController,
                ),
              ),
            ),

            // ===== مؤشر الصفحات =====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: Colors.grey.withValues(alpha: 0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                  spacing: 8,
                ),
              ),
            ),

            // ===== زر التالي / ابدأ الآن =====
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pages[_currentPage].gradient,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: pages[_currentPage]
                          .gradient[0]
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: _nextPage,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2
                                ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                                : (isArabic ? 'التالي' : 'Next'),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isArabic
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final List<IconData> decorIcons;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.decorIcons,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final AnimationController animController;

  const _OnboardingPage({
    required this.data,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ===== الرسم التوضيحي المتحرك =====
          AnimatedBuilder(
            animation: animController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // الحلقة الخارجية الدوارة
                  Transform.rotate(
                    angle: animController.value * 6.28,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            data.gradient[0].withValues(alpha: 0.3),
                            data.gradient[1].withValues(alpha: 0.1),
                            data.gradient[0].withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // دائرة خلفية
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          data.gradient[0].withValues(alpha: 0.15),
                          data.gradient[1].withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // أيقونات زخرفية تطفو حول الأيقونة
                  ...List.generate(data.decorIcons.length, (i) {
                    final angle =
                        (i * math.pi) + (animController.value * 1.5);
                    final distance = 130.0 + (animController.value * 10);
                    return Transform.translate(
                      offset: Offset(
                        distance * math.cos(angle),
                        distance * math.sin(angle),
                      ),
                      child: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          data.decorIcons[i],
                          color: data.gradient[0],
                          size: 28,
                        ),
                      ),
                    );
                  }),
                  // الأيقونة الرئيسية
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: data.gradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: data.gradient[0].withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 60),

          // ===== العنوان مع تدرّج =====
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: data.gradient).createShader(bounds),
            child: Text(
              data.title,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // ===== الوصف =====
          Text(
            data.subtitle,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.7),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
