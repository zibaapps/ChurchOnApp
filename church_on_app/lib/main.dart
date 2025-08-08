import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dart';
import 'common/providers/firebase_flag.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // Attempt to initialize Firebase with default options. Replace with FlutterFire options later.
    await Firebase.initializeApp();
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
      child: const ChurchOnApp(),
    ));
  }, (error, stack) {
    // Best-effort Crashlytics reporting
    try {
      FirebaseCrashlytics.instance.recordError(error, stack);
    } catch (_) {}
  });
}
