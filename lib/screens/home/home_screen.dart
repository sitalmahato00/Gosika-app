import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../models/deal_product.dart';
import '../../models/product.dart';
import '../../providers/catalog_provider.dart';
import 'widgets/category_carousel.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/modern_product_card.dart';
import 'widgets/promo_banner.dart';
import 'widgets/section_header.dart';
import 'widgets/trust_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<ModernProductData> _fallbackDeals = [
    ModernProductData(
      id: 'watermelon-1kg',
      title: 'Fresh Watermelon 1kg',
      subtitle: 'Fresh & Juicy',
      imageUrl:
          'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400',
      currentPrice: 'Rs. 1,200',
      oldPrice: 'Rs. 2,000',
      discountBadge: '-40%',
      rating: 4.5,
      reviewsCount: 120,
    ),
    ModernProductData(
      id: 'backpack-50l',
      title: 'Hiking Backpack 50L',
      subtitle: 'For Your Next Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      currentPrice: 'Rs. 3,750',
      oldPrice: 'Rs. 5,000',
      discountBadge: '-25%',
      rating: 4.6,
      reviewsCount: 210,
    ),
    ModernProductData(
      id: 'wireless-headphones',
      title: 'Wireless Headphones',
      subtitle: 'Noise Cancelling',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      currentPrice: 'Rs. 4,500',
      oldPrice: 'Rs. 6,000',
      discountBadge: '-25%',
      rating: 4.8,
      reviewsCount: 340,
    ),
    ModernProductData(
      id: 'running-shoes',
      title: 'Pro Running Shoes',
      subtitle: 'Ultra Lightweight',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      currentPrice: 'Rs. 3,200',
      oldPrice: 'Rs. 4,500',
      discountBadge: '-28%',
      rating: 4.7,
      reviewsCount: 185,
    ),
  ];

  static const List<ModernProductData> _fallbackFeatured = [
    ModernProductData(
      id: 'green-hoodie',
      title: 'Green Comfort Hoodie',
      subtitle: 'Premium Cotton Blend',
      imageUrl:
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=400',
      currentPrice: 'Rs. 2,400',
      oldPrice: 'Rs. 3,000',
      discountBadge: '-20%',
      rating: 4.6,
      reviewsCount: 88,
    ),
    ModernProductData(
      id: 'smart-watch',
      title: 'Fitness Smart Watch',
      subtitle: 'Heart & Sleep Tracker',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      currentPrice: 'Rs. 5,800',
      oldPrice: 'Rs. 6,800',
      discountBadge: '-15%',
      rating: 4.9,
      reviewsCount: 412,
    ),
    ModernProductData(
      id: 'women-handbag',
      title: "Women's Leather Handbag",
      subtitle: 'Elegant & Spacious',
      imageUrl:
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400',
      currentPrice: 'Rs. 3,500',
      oldPrice: 'Rs. 5,000',
      discountBadge: '-30%',
      rating: 4.5,
      reviewsCount: 96,
    ),
    ModernProductData(
      id: 'classic-sneakers',
      title: 'White Classic Sneakers',
      subtitle: 'Everyday Casual',
      imageUrl:
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=400',
      currentPrice: 'Rs. 4,200',
      oldPrice: 'Rs. 5,400',
      discountBadge: '-22%',
      rating: 4.7,
      reviewsCount: 150,
    ),
  ];

  ModernProductData _mapDealProduct(DealProduct deal) {
    final img = ApiClient.apiImage(deal.imageUrl);
    final disc = deal.discountPercentage > 0 ? '-${deal.discountPercentage}%' : '';

    return ModernProductData(
      id: deal.id,
      title: deal.name,
      subtitle: deal.brandName ?? 'Best Deal',
      imageUrl: img.isNotEmpty
          ? img
          : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      currentPrice: formatNPR(deal.price),
      oldPrice: deal.compareAtPrice != null ? formatNPR(deal.compareAtPrice) : null,
      discountBadge: disc,
      rating: deal.ratingAvg > 0 ? deal.ratingAvg : 4.5,
      reviewsCount: deal.ratingCount > 0 ? deal.ratingCount : 120,
    );
  }

  ModernProductData _mapProduct(Product product) {
    final img = ApiClient.apiImage(product.image);
    final discPercentage = (product.compareAtPrice != null && product.compareAtPrice! > product.price)
        ? (((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100).round()
        : 0;

    return ModernProductData(
      id: product.id,
      title: product.name,
      subtitle: product.shortDescription ?? 'Featured Item',
      imageUrl: img.isNotEmpty
          ? img
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      currentPrice: formatNPR(product.price),
      oldPrice: product.compareAtPrice != null ? formatNPR(product.compareAtPrice) : null,
      discountBadge: discPercentage > 0 ? '-$discPercentage%' : '',
      rating: product.ratingAvg > 0 ? product.ratingAvg : 4.6,
      reviewsCount: product.ratingCount > 0 ? product.ratingCount : 90,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaTopPadding = MediaQuery.of(context).padding.top;

    final campaignsAsync = ref.watch(campaignsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final dealsAsync = ref.watch(dealsProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          ref.invalidate(campaignsProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(dealsProvider);
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(allProductsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              // 1. HERO REGION WITH HIMALAYAN BACKGROUND
              Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.white.withValues(alpha: 0.1),
                          AppColors.creamBackground.withValues(alpha: 0.85),
                          AppColors.creamBackground,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.75, 1.0],
                      ),
                    ),
                    child: Image.asset(
                      AppAssets.homeBg,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppAssets.splashBg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Header and Search Bar
                  Padding(
                    padding: EdgeInsets.only(top: mediaTopPadding + 4),
                    child: Column(
                      children: [
                        HomeHeader(
                          onCartTap: () => context.push('/cart'),
                          onNotificationTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No new notifications'),
                                backgroundColor: AppColors.darkText,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        HomeSearchBar(
                          onTap: () => context.push('/search'),
                          onScanTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('QR Scanner ready'),
                                backgroundColor: AppColors.primaryOrange,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. IMAGE-BASED CATEGORY CARDS (Live API / Fallback)
              categoriesAsync.when(
                data: (categories) => CategoryCarousel(apiCategories: categories),
                loading: () => const CategoryCarousel(),
                error: (err, stack) => const CategoryCarousel(),
              ),

              const SizedBox(height: 18),

              // 3. PROMOTIONAL BANNER SECTION (Real API Banners)
              campaignsAsync.when(
                data: (campaigns) => PromoBanner(campaigns: campaigns),
                loading: () => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
                error: (err, stack) => const PromoBanner(),
              ),

              const SizedBox(height: 22),

              // 4. BEST DEALS SECTION
              SectionHeader(
                title: 'Best Deals',
                iconEmoji: '🔥',
                onSeeAllTap: () => context.push('/shop'),
              ),
              const SizedBox(height: 12),

              dealsAsync.when(
                data: (deals) {
                  final list = deals.isNotEmpty
                      ? deals.map(_mapDealProduct).toList()
                      : _fallbackDeals;
                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ModernProductCard(product: list[index]),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _fallbackDeals.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ModernProductCard(product: _fallbackDeals[index]),
                      );
                    },
                  ),
                ),
                error: (err, stack) => SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _fallbackDeals.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ModernProductCard(product: _fallbackDeals[index]),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 5. DELIVERY / TRUST BANNER
              const TrustBanner(),

              const SizedBox(height: 22),

              // 6. FEATURED PRODUCTS SECTION
              SectionHeader(
                title: 'Featured Products',
                iconEmoji: '👑',
                onSeeAllTap: () => context.push('/shop'),
              ),
              const SizedBox(height: 12),

              featuredAsync.when(
                data: (products) {
                  final list = products.isNotEmpty
                      ? products.map(_mapProduct).toList()
                      : _fallbackFeatured;
                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ModernProductCard(product: list[index]),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _fallbackFeatured.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ModernProductCard(product: _fallbackFeatured[index]),
                      );
                    },
                  ),
                ),
                error: (err, stack) => SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _fallbackFeatured.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ModernProductCard(product: _fallbackFeatured[index]),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
