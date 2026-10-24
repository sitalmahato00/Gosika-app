import '../core/api_client.dart';
import '../models/cart.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  Future<Cart> getCart() async {
    final response = await _apiClient.dio.get('/cart');
    return Cart.fromJson(response.data['data']);
  }

  Future<void> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    await _apiClient.dio.post('/cart/items', data: {
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
    });
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    await _apiClient.dio.put('/cart/items/$itemId', data: {
      'quantity': quantity,
    });
  }

  Future<void> removeItem(String itemId) async {
    await _apiClient.dio.delete('/cart/items/$itemId');
  }

  Future<void> clearCart() async {
    await _apiClient.dio.delete('/cart');
  }
}
