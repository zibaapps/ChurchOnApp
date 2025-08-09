import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/tenant_providers.dart';
import '../providers/auth_providers.dart';

class NotificationPrefs {
  const NotificationPrefs({this.news = true, this.events = true, this.announcements = true});
  final bool news;
  final bool events;
  final bool announcements;

  NotificationPrefs copyWith({bool? news, bool? events, bool? announcements}) =>
      NotificationPrefs(news: news ?? this.news, events: events ?? this.events, announcements: announcements ?? this.announcements);
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