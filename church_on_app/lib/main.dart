import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dart';
import 'common/providers/firebase_flag.dart';
import 'firebase_options.dart';
import 'common/providers/app_init_providers.dart';
import 'common/providers/tenant_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // Initialize Firebase with provided options (web) or default (mobile when added)
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseInitialized = true;

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Ignore if Crashlytics not available
      try {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      } catch (_) {}
    };
  } catch (_) {
    // Continue without Firebase so the app can still run in dev without config
    firebaseInitialized = false;
  }

  runZonedGuarded(() {
    runApp(ProviderScope(
      overrides: [
        firebaseInitializedProvider.overrideWithValue(firebaseInitialized),
      ],
      child: const _AppWithInit(),
    ));
  }, (error, stack) {
    // Best-effort Crashlytics reporting
    try {
      FirebaseCrashlytics.instance.recordError(error, stack);
    } catch (_) {}
  });
}

class _AppWithInit extends ConsumerWidget {
  const _AppWithInit();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appInitProvider);
    ref.watch(tenantBootstrapProvider);
    return const ChurchOnApp();
  }
}
