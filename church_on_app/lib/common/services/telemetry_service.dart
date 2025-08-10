import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class TelemetryService {
  TelemetryService({FirebaseAnalytics? analytics, FirebaseCrashlytics? crash})
      : _analytics = analytics ?? FirebaseAnalytics.instance,
        _crash = crash ?? FirebaseCrashlytics.instance;
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crash;

  Future<void> setEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    await _crash.setCrashlyticsCollectionEnabled(enabled);
  }
}