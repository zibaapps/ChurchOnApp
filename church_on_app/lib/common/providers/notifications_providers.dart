import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/tenant_providers.dart';
import '../providers/auth_providers.dart';

class NotificationPrefs {
  const NotificationPrefs({
    this.news = true,
    this.events = true,
    this.announcements = true,
    this.sermons = true,
    this.prayers = true,
    this.testimonies = true,
    this.giving = false,
  });
  final bool news;
  final bool events;
  final bool announcements;
  final bool sermons;
  final bool prayers;
  final bool testimonies;
  final bool giving;

  NotificationPrefs copyWith({bool? news, bool? events, bool? announcements, bool? sermons, bool? prayers, bool? testimonies, bool? giving}) =>
      NotificationPrefs(
        news: news ?? this.news,
        events: events ?? this.events,
        announcements: announcements ?? this.announcements,
        sermons: sermons ?? this.sermons,
        prayers: prayers ?? this.prayers,
        testimonies: testimonies ?? this.testimonies,
        giving: giving ?? this.giving,
      );
}

final notificationPrefsProvider = StateProvider<NotificationPrefs>((ref) => const NotificationPrefs());

final notificationManagerProvider = Provider<NotificationManager>((ref) => NotificationManager(ref));

class NotificationManager {
  NotificationManager(this._ref);
  final Ref _ref;

  Future<void> apply() async {
    final churchId = _ref.read(activeChurchIdProvider);
    final user = _ref.read(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) return;
    final prefs = _ref.read(notificationPrefsProvider);
    final fcm = FirebaseMessaging.instance;

    final topics = <String, bool>{
      'news_$churchId': prefs.news,
      'events_$churchId': prefs.events,
      'announcements_$churchId': prefs.announcements,
      'sermons_$churchId': prefs.sermons,
      'prayers_$churchId': prefs.prayers,
      'testimonies_$churchId': prefs.testimonies,
      'giving_$churchId': prefs.giving,
    };
    for (final entry in topics.entries) {
      if (entry.value) {
        await fcm.subscribeToTopic(entry.key);
      } else {
        await fcm.unsubscribeFromTopic(entry.key);
      }
    }
  }
}