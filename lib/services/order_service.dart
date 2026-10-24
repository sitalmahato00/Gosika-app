import '../core/api_client.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  Future<PaginatedResponse<Order>> getOrders({int page = 1, String? status}) async {
    final response = await _apiClient.dio.get('/orders', queryParameters: {
      'page': page,
      'status': status,
    }..removeWhere((k, v) => v == null));
    
    final List data = response.data['data'];
    // Assuming catalog_service's PaginationMeta is reusable or similar
    // For now, simple list
    return PaginatedResponse(
      data: data.map((e) => Order.fromJson(e)).toList(),
      meta: PaginationMeta.fromJson(response.data['meta']),
    );
  }

  Future<Order> getOrderDetail(String id) async {
    final response = await _apiClient.dio.get('/orders/$id');
    return Order.fromJson(response.data['data']);
  }

  Future<List<OrderTracking>> getTracking(String id) async {
    final response = await _apiClient.dio.get('/orders/$id/tracking');
    final List data = response.data['data'];
    return data.map((e) => OrderTracking.fromJson(e)).toList();
  }

  Future<void> cancelOrder(String id, String reason) async {
    await _apiClient.dio.post('/orders/$id/cancel', data: {'reason': reason});
  }
}
