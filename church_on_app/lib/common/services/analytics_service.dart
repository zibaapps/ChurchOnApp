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

  Future<void> logBibleRead({required String version, required String book, required int chapter}) async {
    await _analytics.logEvent(name: 'bible_read', parameters: {
      'version': version,
      'book': book,
      'chapter': chapter,
    });
  }

  Future<void> logBibleTtsPlay({required String version, required String book, required int chapter}) async {
    await _analytics.logEvent(name: 'bible_tts_play', parameters: {
      'version': version,
      'book': book,
      'chapter': chapter,
    });
  }

  Future<void> logPlanProgress({required String userId, required String planId, required int streak}) async {
    await _analytics.logEvent(name: 'plan_progress', parameters: {
      'userId': userId,
      'planId': planId,
      'streak': streak,
    });
  }

  Future<void> logPlanComplete({required String userId, required String planId}) async {
    await _analytics.logEvent(name: 'plan_complete', parameters: {
      'userId': userId,
      'planId': planId,
    });
  }

  Future<void> logReportView({required String churchId, required String reportId, required String type}) async {
    await _analytics.logEvent(name: 'report_view', parameters: {
      'churchId': churchId,
      'reportId': reportId,
      'type': type,
    });
  }
}