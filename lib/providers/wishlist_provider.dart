import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';

final wishlistServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WishlistService(apiClient);
});

final wishlistProvider = StateNotifierProvider<WishlistNotifier, AsyncValue<List<Product>>>((ref) {
  final service = ref.watch(wishlistServiceProvider);
  return WishlistNotifier(service);
});

class WishlistNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final WishlistService _service;

  WishlistNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    state = const AsyncValue.loading();
    try {
      final items = await _service.getWishlist();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final currentItems = state.value ?? [];
    final isExist = currentItems.any((e) => e.id == productId);

    try {
      if (isExist) {
        await _service.removeFromWishlist(productId);
      } else {
        await _service.addToWishlist(productId);
      }
      await fetchWishlist();
    } catch (e) {
      // Handle error
    }
  }

  bool isWishlisted(String productId) {
    return state.value?.any((e) => e.id == productId) ?? false;
  }
}
