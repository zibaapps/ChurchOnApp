import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tenant_settings_service.dart';
import '../services/remote_config_service.dart';
import 'tenant_providers.dart';
import 'firebase_flag.dart';
import 'accessibility_providers.dart';

Color _parseHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF5A3AFF);
  var raw = hex.replaceAll('#', '').trim();
  if (raw.length == 6) raw = 'FF$raw';
  try {
    return Color(int.parse(raw, radix: 16));
  } catch (_) {
    return const Color(0xFF5A3AFF);
  }
}

final tenantSeedColorProvider = StreamProvider<Color>((ref) async* {
  final churchId = ref.watch(activeChurchIdProvider);
  final firebaseReady = ref.watch(firebaseInitializedProvider);
  final rcSeed = firebaseReady ? _parseHex(RemoteConfigService().themeSeed) : const Color(0xFF5A3AFF);
  if (churchId == null) {
    yield rcSeed;
    return;
  }
  await for (final data in TenantSettingsService().streamChurch(churchId)) {
    final color = _parseHex(data?['themeColor'] as String?);
    yield color == const Color(0xFF5A3AFF) ? rcSeed : color;
  }
});

final tenantThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(tenantSeedColorProvider).value ?? const Color(0xFF5A3AFF);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return applyAccessibility(base, ref);
});

final tenantDarkThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(tenantSeedColorProvider).value ?? const Color(0xFF5A3AFF);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return applyAccessibility(base, ref);
});