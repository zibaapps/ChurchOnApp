import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

import 'router.dart';
import '../common/providers/theme_providers.dart';
import '../common/providers/tenant_providers.dart';
import '../common/services/domain_service.dart';
import '../common/providers/accessibility_providers.dart';
import '../common/providers/app_init_providers.dart';
import '../common/providers/notifications_providers.dart';

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

    // Initialize core services (Firestore persistence, messaging, remote config)
    ref.watch(appInitProvider);

    // Re-apply notification topics when prefs or active church changes
    ref.listen(notificationPrefsProvider, (_, __) {
      ref.read(notificationManagerProvider).apply();
    });
    ref.listen(activeChurchIdProvider, (_, __) {
      ref.read(notificationManagerProvider).apply();
    });

    final scale = ref.watch(textScaleProvider);
    return MaterialApp.router(
      title: 'Church On App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ref.watch(tenantThemeProvider),
      darkTheme: ref.watch(tenantDarkThemeProvider),
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
          child: child,
        );
      },
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