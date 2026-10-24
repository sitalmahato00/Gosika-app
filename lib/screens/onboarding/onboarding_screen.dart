import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/decorative_background.dart';
import '../../shared/widgets/primary_auth_button.dart';

class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      imagePath: AppAssets.onboardingDiscover,
      title: "Discover Products You'll Love",
      description:
          "Explore a world of amazing products, all in one place. Find what you need and discover something new.",
    ),
    OnboardingItem(
      imagePath: AppAssets.onboardingSecure,
      title: "Shop Conveniently & Securely",
      description:
          "Enjoy a seamless shopping experience with secure payments and easy checkout.",
    ),
    OnboardingItem(
      imagePath: AppAssets.onboardingTracking,
      title: "Track Your Orders",
      description:
          "Stay updated from checkout to delivery and know when your order arrives.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/location-permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: DecorativeBackground(
        child: Column(
          children: [
            // Header with Skip action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main PageView area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = (constraints.maxHeight * 0.52)
                            .clamp(180.0, 320.0);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Standalone Illustration Image (No white card background)
                            SizedBox(
                              height: imageHeight,
                              width: double.infinity,
                              child: Image.asset(
                                item.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 80,
                                      color: AppColors.primaryOrange,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.45,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Indicators & Action Button Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryOrange
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Button
                  PrimaryAuthButton(
                    text: _currentPage == _items.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
