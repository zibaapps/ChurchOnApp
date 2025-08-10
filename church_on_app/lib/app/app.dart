import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

import 'router.dart';
import '../common/providers/theme_providers.dart';
import '../common/providers/tenant_providers.dart';
import '../common/services/domain_service.dart';

class ChurchOnApp extends ConsumerWidget {
  const ChurchOnApp({super.key});

  Future<void> _bootstrapDomain(WidgetRef ref) async {
    if (!kIsWeb) return;
    final current = ref.read(activeChurchIdProvider);
    if (current != null) return;
    try {
      final id = await DomainService().resolveChurchIdFromHost();
      if (id != null && ref.read(activeChurchIdProvider) == null) {
        ref.read(activeChurchIdProvider.notifier).state = id;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _bootstrapDomain(ref);
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