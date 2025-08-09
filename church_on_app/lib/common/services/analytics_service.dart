import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics}) : _analytics = analytics ?? FirebaseAnalytics.instance;
  final FirebaseAnalytics _analytics;

  Future<void> logSermonView({required String churchId, required String sermonId, String? title}) async {
    await _analytics.logEvent(name: 'sermon_view', parameters: {
      'churchId': churchId,
      'sermonId': sermonId,
      if (title != null) 'title': title,
    });
  }

  Future<void> logGiveStart({required String churchId, required String userId, required double amount, required String method}) async {
    await _analytics.logEvent(name: 'give_start', parameters: {
      'churchId': churchId,
      'userId': userId,
      'amount': amount,
      'method': method,
    });
  }

  Future<void> logGiveSuccess({required String churchId, required String userId, required double amount, required String method, String? reference}) async {
    await _analytics.logEvent(name: 'give_success', parameters: {
      'churchId': churchId,
      'userId': userId,
      'amount': amount,
      'method': method,
      if (reference != null) 'reference': reference,
    });
  }

  Future<void> logRsvp({required String churchId, required String eventId, required String userId, required bool attending}) async {
    await _analytics.logEvent(name: 'event_rsvp', parameters: {
      'churchId': churchId,
      'eventId': eventId,
      'userId': userId,
      'attending': attending,
    });
  }
}