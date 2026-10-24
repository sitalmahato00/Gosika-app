import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  ProductVariant? _selectedVariant;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    final isWishlisted = ref.watch(wishlistProvider).maybeWhen(
          data: (items) => items.any((item) => item.id == widget.productId),
          orElse: () => false,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: kNavy),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? const Color(0xFFFF5722) : kNavy,
            ),
            onPressed: () {
              ref.read(wishlistProvider.notifier).toggleWishlist(widget.productId);
            },
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (_selectedVariant == null && product.variants.isNotEmpty) {
            _selectedVariant = product.variants.first;
          }

          final imageList = product.images.isNotEmpty ? product.images : [product.image ?? ''];
          final discount = (product.compareAtPrice != null && product.compareAtPrice! > product.price)
              ? (((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100).round()
              : 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: PageView.builder(
                        itemCount: imageList.length,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: imageList[index],
                            fit: BoxFit.cover,
                            httpHeaders: const {'User-Agent': 'Mozilla/5.0'},
                            placeholder: (context, url) => Container(color: Colors.grey[100]),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${imageList.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Discount Badge
                      if (discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5722),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),

                      // Title
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kNavy, height: 1.25),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Verified
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < product.ratingAvg.floor() ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber[700],
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '(${product.ratingCount} reviews)',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 12, color: Colors.blue),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formatNPR(_selectedVariant?.price ?? product.price),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
                          ),
                          if (product.compareAtPrice != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              formatNPR(product.compareAtPrice),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Perks Section
                      Row(
                        children: [
                          _buildPerkCard(Icons.local_shipping_outlined, 'Free Shipping', 'On orders above रु1,000'),
                          const SizedBox(width: 8),
                          _buildPerkCard(Icons.payments_outlined, 'Cash on Delivery', 'Available'),
                          const SizedBox(width: 8),
                          _buildPerkCard(Icons.published_with_changes, '7 Days Return', 'Easy return policy'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Variants
                      if (product.variants.isNotEmpty) ...[
                        const Text('Select Variant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: product.variants.map((v) {
                            final isSelected = _selectedVariant?.id == v.id;
                            return ChoiceChip(
                              label: Text(v.name ?? 'Default'),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedVariant = v);
                              },
                              selectedColor: const Color(0xFFFF5722),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description
                      const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        product.description ?? product.shortDescription ?? 'Handcrafted product made with standard quality materials.',
                        style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 13),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722)))),
        error: (err, stack) => Center(child: Text('Error loading product: $err')),
      ),
      bottomSheet: productAsync.maybeWhen(
        data: (product) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                        icon: const Icon(Icons.remove, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Add to Cart Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(cartProvider.notifier).addItem(
                              productId: product.id,
                              variantId: _selectedVariant?.id,
                              quantity: _quantity,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item added to cart!'),
                              backgroundColor: Color(0xFFFF5722),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildPerkCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF5722), size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kNavy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
