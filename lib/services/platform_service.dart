import '../core/api_client.dart';
import '../models/platform_config.dart';

class PlatformService {
  final ApiClient _apiClient;

  PlatformService(this._apiClient);

  Future<PlatformConfig> getConfig() async {
    final response = await _apiClient.dio.get('/platform/config');
    return PlatformConfig.fromJson(response.data['data']);
  }
}
