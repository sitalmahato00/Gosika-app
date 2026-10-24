import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;

  const DecorativeBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base cream background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.creamBackground,
        ),

        // Artwork background overlay (assets/images/splash_bg.png)
        Positioned.fill(
          child: Image.asset(
            AppAssets.splashBg,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              final size = MediaQuery.of(context).size;
              return Stack(
                children: [
                  Positioned(
                    top: -size.width * 0.25,
                    right: -size.width * 0.2,
                    child: Container(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightPeach.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -size.width * 0.3,
                    left: -size.width * 0.2,
                    child: Container(
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightPeach.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Main content inside SafeArea
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}
