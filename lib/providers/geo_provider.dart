import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/geo_models.dart';
import '../services/geo_service.dart';

final geoServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GeoService(apiClient);
});

final provincesProvider = FutureProvider<List<Province>>((ref) async {
  final service = ref.watch(geoServiceProvider);
  return service.getProvinces();
});

final districtsProvider = FutureProvider.family<List<District>, int>((ref, provinceId) async {
  final service = ref.watch(geoServiceProvider);
  return service.getDistricts(provinceId);
});

final municipalitiesProvider = FutureProvider.family<List<Municipality>, int>((ref, districtId) async {
  final service = ref.watch(geoServiceProvider);
  return service.getMunicipalities(districtId);
});
