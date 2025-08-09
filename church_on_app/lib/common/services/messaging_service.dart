import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingService {
  MessagingService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  static final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      await _messaging.requestPermission();
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _fln.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;
      await _fln.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('default', 'Notifications', importance: Importance.defaultImportance),
        ),
      );
    });
  }

  Future<void> subscribeToChurchTopics(String churchId) async {
    // Topics per church for announcements/news
    final topics = ['church_$churchId', 'church_${churchId}_ann', 'church_${churchId}_news'];
    for (final t in topics) {
      try {
        await _messaging.subscribeToTopic(t);
      } catch (_) {}
    }
  }
}