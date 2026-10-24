import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/deal_product.dart';
import '../core/api_client.dart';
import '../providers/wishlist_provider.dart';

class DealProductCard extends ConsumerWidget {
  final DealProduct product;
  final VoidCallback? onAddToCart;
  final double? width;

  const DealProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discount = product.discountPercentage;

    final isWishlisted = ref.watch(wishlistProvider).maybeWhen(
          data: (items) => items.any((item) => item.id == product.id),
          orElse: () => false,
        );

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        width: width ?? 175,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: CachedNetworkImage(
                    imageUrl: ApiClient.apiImage(product.imageUrl),
                    fit: BoxFit.cover,
                    httpHeaders: const {'User-Agent': 'Mozilla/5.0'},
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 28),
                          const SizedBox(height: 2),
                          Text(
                            'No Image',
                            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5722),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Wishlist button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isWishlisted ? const Color(0xFFFF5722) : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rating Row
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.ratingAvg.floor() ? Icons.star : Icons.star_border,
                          size: 12,
                          color: Colors.amber[700],
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.ratingCount})',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price Row + Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.compareAtPrice != null && product.compareAtPrice! > product.price)
                            Text(
                              formatNPR(product.compareAtPrice!),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            formatNPR(product.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.2)),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 16,
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ],
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
