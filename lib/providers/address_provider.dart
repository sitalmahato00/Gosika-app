import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/address.dart';
import '../services/address_service.dart';

final addressServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressService(apiClient);
});

final addressListProvider = StateNotifierProvider<AddressListNotifier, AsyncValue<List<CustomerAddress>>>((ref) {
  final service = ref.watch(addressServiceProvider);
  return AddressListNotifier(service);
});

class AddressListNotifier extends StateNotifier<AsyncValue<List<CustomerAddress>>> {
  final AddressService _service;

  AddressListNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    state = const AsyncValue.loading();
    try {
      final addresses = await _service.getAddresses();
      state = AsyncValue.data(addresses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAddress(Map<String, dynamic> data) async {
    try {
      await _service.createAddress(data);
      await fetchAddresses();
    } catch (e) {
      // Re-throw or handle
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _service.deleteAddress(id);
      await fetchAddresses();
    } catch (e) {
      // Handle
    }
  }
}
