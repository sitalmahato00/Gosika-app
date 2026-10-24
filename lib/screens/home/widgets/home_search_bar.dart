import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScanTap;
  final VoidCallback? onTap;

  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.onScanTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.secondaryText,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onTap: onTap,
              onChanged: onChanged,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                fontSize: 13.5,
              ),
              decoration: InputDecoration(
                hintText: 'Search for products, brands and more...',
                hintStyle: AppTextStyles.inputHint.copyWith(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          GestureDetector(
            onTap: onScanTap,
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.primaryOrange,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
