import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tenant_settings_service.dart';
import 'tenant_providers.dart';

final tenantSettingsStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) {
    return const Stream.empty();
  }
  return TenantSettingsService().streamChurch(churchId);
});

final tenantDisplayNameProvider = Provider<String>((ref) {
  final data = ref.watch(tenantSettingsStreamProvider).valueOrNull;
  return (data?['name'] as String?) ?? 'Church On App';
});

final tenantIconUrlProvider = Provider<String?>((ref) {
  final data = ref.watch(tenantSettingsStreamProvider).valueOrNull;
  return data?['iconUrl'] as String?;
});