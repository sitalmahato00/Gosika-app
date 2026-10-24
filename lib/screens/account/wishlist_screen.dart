import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Wishlist', style: TextStyle(fontWeight: FontWeight.bold, color: kNavy, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kNavy),
            onPressed: () {
              // Option to clear wishlist if needed
            },
          ),
        ],
      ),
      body: wishlistAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kNavy)),
                  const SizedBox(height: 6),
                  const Text('Save items you love for later.', style: TextStyle(color: kMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.64,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(product: product);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722))),
        ),
        error: (e, s) => Center(child: Text('Error loading wishlist: $e')),
      ),
    );
  }
}
