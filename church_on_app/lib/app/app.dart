import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

import 'router.dart';
import '../common/providers/theme_providers.dart';
import '../common/providers/tenant_providers.dart';

class ChurchOnApp extends ConsumerWidget {
  const ChurchOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-select church by domain on web
    if (kIsWeb) {
      try {
        final uri = Uri.base; // avoids dart:html
        final host = uri.host;
        final parts = host.split('.');
        if (parts.length > 2) {
          final sub = parts.first;
          ref.read(activeChurchIdProvider.notifier).state ??= sub;
        }
      } catch (_) {}
    }

    return MaterialApp.router(
      title: 'Church On App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ref.watch(tenantThemeProvider),
      darkTheme: ref.watch(tenantDarkThemeProvider),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
      ],
    );
  }
}