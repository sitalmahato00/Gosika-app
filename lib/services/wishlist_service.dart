import '../core/api_client.dart';
import '../models/product.dart';

class WishlistService {
  final ApiClient _apiClient;

  WishlistService(this._apiClient);

  Future<List<Product>> getWishlist() async {
    final response = await _apiClient.dio.get('/wishlist');
    final List data = response.data['data'];
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<void> addToWishlist(String productId) async {
    await _apiClient.dio.post('/wishlist/items', data: {'product_id': productId});
  }

  Future<void> removeFromWishlist(String productId) async {
    await _apiClient.dio.delete('/wishlist/items', data: {'product_id': productId});
  }

  Future<bool> getStatus(String productId) async {
    final response = await _apiClient.dio.get('/wishlist/status/$productId');
    return response.data['data']['is_wishlisted'] ?? false;
  }
}
