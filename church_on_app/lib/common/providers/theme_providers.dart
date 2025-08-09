import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tenant_settings_service.dart';
import 'tenant_providers.dart';

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
  if (churchId == null) {
    yield const Color(0xFF5A3AFF);
    return;
  }
  await for (final data in TenantSettingsService().streamChurch(churchId)) {
    final color = _parseHex(data?['themeColor'] as String?);
    yield color;
  }
});

final tenantThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(tenantSeedColorProvider).value ?? const Color(0xFF5A3AFF);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  return ThemeData(useMaterial3: true, colorScheme: scheme);
});

final tenantDarkThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(tenantSeedColorProvider).value ?? const Color(0xFF5A3AFF);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
  return ThemeData(useMaterial3: true, colorScheme: scheme);
});