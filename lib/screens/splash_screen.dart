import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../shared/widgets/decorative_background.dart';
import '../shared/widgets/gosika_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _logoController.forward();
    _checkDestination();
  }

  Future<void> _checkDestination() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!onboardingCompleted) {
      if (mounted) context.go('/onboarding');
    } else {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        if (mounted) context.go('/');
      } else {
        if (mounted) context.go('/welcome');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: DecorativeBackground(
        child: Stack(
          children: [
            // Centered Logo & Tagline (Larger 120 size)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const GosikaLogo(
                    logoSize: 120,
                    showTagline: true,
                  ),
                ),
              ),
            ),

            // Three gently animated orange loading dots
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.3;
                      final double value =
                          (_dotsController.value + delay) % 1.0;
                      final double scale = 0.6 + (0.4 * (1.0 - (value - 0.5).abs() * 2));
                      final double opacity = 0.3 + (0.7 * (1.0 - (value - 0.5).abs() * 2));

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10 * scale,
                        height: 10 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
