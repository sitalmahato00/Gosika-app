import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/platform_config.dart';
import '../services/platform_service.dart';

final platformServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlatformService(apiClient);
});

final platformConfigProvider = FutureProvider<PlatformConfig>((ref) async {
  final service = ref.watch(platformServiceProvider);
  return service.getConfig();
});
