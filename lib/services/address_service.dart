import '../core/api_client.dart';
import '../models/address.dart';

class AddressService {
  final ApiClient _apiClient;

  AddressService(this._apiClient);

  Future<List<CustomerAddress>> getAddresses() async {
    final response = await _apiClient.dio.get('/customer/addresses');
    final List data = response.data['data'];
    return data.map((e) => CustomerAddress.fromJson(e)).toList();
  }

  Future<void> createAddress(Map<String, dynamic> data) async {
    await _apiClient.dio.post('/customer/addresses', data: data);
  }

  Future<void> updateAddress(String id, Map<String, dynamic> data) async {
    await _apiClient.dio.put('/customer/addresses/$id', data: data);
  }

  Future<void> deleteAddress(String id) async {
    await _apiClient.dio.delete('/customer/addresses/$id');
  }

  Future<void> setDefaultAddress(String id) async {
    await _apiClient.dio.put('/customer/addresses/$id/default');
  }
}
