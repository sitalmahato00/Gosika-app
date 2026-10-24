import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/product.dart';

class CategoryItem {
  final String id;
  final String name;
  final String imageUrl;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class CategoryCarousel extends StatelessWidget {
  final List<Category>? apiCategories;

  const CategoryCarousel({
    super.key,
    this.apiCategories,
  });

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(
      id: 'electronics',
      name: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300',
    ),
    CategoryItem(
      id: 'fashion',
      name: 'Fashion',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
    ),
    CategoryItem(
      id: 'home-living',
      name: 'Home &\nLiving',
      imageUrl:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=300',
    ),
    CategoryItem(
      id: 'food-beverages',
      name: 'Food &\nBeverages',
      imageUrl:
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300',
    ),
    CategoryItem(
      id: 'beauty-health',
      name: 'Beauty &\nHealth',
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=300',
    ),
    CategoryItem(
      id: 'more',
      name: 'More',
      imageUrl:
          'https://images.unsplash.com/photo-1544816155-12df9643f363?w=300',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<CategoryItem> items = (apiCategories != null && apiCategories!.isNotEmpty)
        ? apiCategories!.map((c) {
            final img = ApiClient.apiImage(c.image);
            return CategoryItem(
              id: c.id,
              name: c.name,
              imageUrl: img.isNotEmpty
                  ? img
                  : 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=300',
            );
          }).toList()
        : defaultCategories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 92,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final cat = items[index];
            return GestureDetector(
              onTap: () {
                if (cat.id.length > 5) {
                  context.push('/categories/${cat.id}?name=${Uri.encodeComponent(cat.name)}');
                } else {
                  context.push('/shop');
                }
              },
              child: Container(
                width: 72,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small Circular Image Container
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.paleOrange,
                        border: Border.all(
                          color: AppColors.primaryOrange.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        cat.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.shopping_bag,
                          color: AppColors.primaryOrange,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Label underneath
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
