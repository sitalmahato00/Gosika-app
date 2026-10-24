import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class GosikaLogo extends StatelessWidget {
  final double logoSize;
  final bool showTagline;
  final bool isHorizontal;

  const GosikaLogo({
    super.key,
    this.logoSize = 72,
    this.showTagline = true,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoBadge = Container(
      width: logoSize,
      height: logoSize,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(logoSize * 0.08),
      child: Image.asset(
        AppAssets.logo,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.shopping_bag_rounded,
          color: AppColors.primaryOrange,
          size: logoSize * 0.55,
        ),
      ),
    );

    final titleAndTagline = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isHorizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'GOSIKA',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primaryOrange,
            fontSize: (logoSize * 0.40).clamp(20.0, 38.0),
            letterSpacing: 2.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 2),
          Text(
            'Shop Smarter, Live Better',
            style: AppTextStyles.tagline.copyWith(
              fontSize: (logoSize * 0.18).clamp(11.0, 14.0),
            ),
          ),
        ],
      ],
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoBadge,
          const SizedBox(width: 14),
          titleAndTagline,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoBadge,
        SizedBox(height: logoSize * 0.18),
        titleAndTagline,
      ],
    );
  }
}
