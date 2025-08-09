import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderService {
  ReminderService() : _plugin = FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  bool _inited = false;

  Future<void> _ensureInit() async {
    if (_inited) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: android);
    await _plugin.initialize(init);
    _inited = true;
  }

  Future<void> scheduleReminder({required DateTime when, required String title, required String body}) async {
    await _ensureInit();
    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Event reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    // Fallback: show immediately (web/tests). For mobile, consider a platform channel or timezone package to schedule.
    await _plugin.show(
      title.hashCode ^ body.hashCode ^ when.millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: 'reminder',
    );
  }
}