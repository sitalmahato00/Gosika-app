import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum SocialProvider { google, facebook }

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onTap;
  final bool isEnabled;

  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onTap,
    this.isEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = provider == SocialProvider.google;
    final label = isGoogle ? 'Google' : 'Facebook';

    return OutlinedButton(
      onPressed: () {
        if (!isEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label Sign-In is not configured yet.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primaryText,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (onTap != null) {
          onTap!();
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryText,
        backgroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.border, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGoogle
              ? const GoogleLogoIcon()
              : const Icon(Icons.facebook_rounded, color: Color(0xFF1877F2), size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    // Blue section (Right bar and arc)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + r, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        0,
        -0.85,
        false,
      )
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red section (Top arc)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -0.85,
        -1.7,
        false,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow section (Left arc)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -2.55,
        -1.2,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green section (Bottom arc)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -3.75,
        -1.7,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, paint);

    // White inner cutout for 'G' shape
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.52, paint);

    // Blue horizontal bar in G
    paint.color = const Color(0xFF4285F4);
    final barRect = Rect.fromLTRB(cx, cy - r * 0.22, cx + r * 0.9, cy + r * 0.22);
    canvas.drawRect(barRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
