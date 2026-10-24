import '../core/api_client.dart';
import '../models/geo_models.dart';

class GeoService {
  final ApiClient _apiClient;

  GeoService(this._apiClient);

  Future<List<Province>> getProvinces() async {
    final response = await _apiClient.dio.get('/platform/provinces');
    final List data = response.data['data'];
    return data.map((e) => Province.fromJson(e)).toList();
  }

  Future<List<District>> getDistricts(int provinceId) async {
    final response = await _apiClient.dio.get('/platform/districts', queryParameters: {
      'province_id': provinceId,
    });
    final List data = response.data['data'];
    return data.map((e) => District.fromJson(e)).toList();
  }

  Future<List<Municipality>> getMunicipalities(int districtId) async {
    final response = await _apiClient.dio.get('/platform/municipalities', queryParameters: {
      'district_id': districtId,
    });
    final List data = response.data['data'];
    return data.map((e) => Municipality.fromJson(e)).toList();
  }
}
