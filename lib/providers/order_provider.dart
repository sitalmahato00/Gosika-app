import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderService(apiClient);
});

final orderDetailProvider = FutureProvider.family<Order, String>((ref, id) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrderDetail(id);
});

final orderTrackingProvider = FutureProvider.family<List<OrderTracking>, String>((ref, id) async {
  final service = ref.watch(orderServiceProvider);
  return service.getTracking(id);
});

class OrderListState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrderListState({this.orders = const [], this.isLoading = false, this.error});
}

class OrderListNotifier extends StateNotifier<OrderListState> {
  final OrderService _service;
  final String? status;

  OrderListNotifier(this._service, this.status) : super(OrderListState()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = OrderListState(isLoading: true, orders: state.orders);
    try {
      final response = await _service.getOrders(status: status);
      state = OrderListState(orders: response.data, isLoading: false);
    } catch (e) {
      state = OrderListState(error: e.toString(), isLoading: false, orders: state.orders);
    }
  }
}

final orderListProvider = StateNotifierProvider.family<OrderListNotifier, OrderListState, String?>((ref, status) {
  final service = ref.watch(orderServiceProvider);
  return OrderListNotifier(service, status);
});
