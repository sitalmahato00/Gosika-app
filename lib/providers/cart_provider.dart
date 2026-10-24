import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

final cartServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CartService(apiClient);
});

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  final service = ref.watch(cartServiceProvider);
  return CartNotifier(service);
});

class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  final CartService _service;

  CartNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _service.getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    try {
      await _service.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );
      await fetchCart();
    } catch (e) {
      // Re-throw or handle error
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await _service.updateQuantity(itemId, quantity);
      await fetchCart();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await _service.removeItem(itemId);
      await fetchCart();
    } catch (e) {
      // Handle error
    }
  }
}
