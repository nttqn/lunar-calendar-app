import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/personal_event.dart';

/// Schedules local reminder notifications for [PersonalEvent]s.
///
/// There's no backend/push service behind this app, so true infinite yearly
/// recurrence isn't possible with local notifications alone. The workaround:
/// schedule the next few years' occurrences as individual one-off
/// notifications whenever an event is added/edited, and top those up again
/// every time the app starts ([EventRepository.rescheduleAll]). As long as
/// the user opens the app at least once every few years, reminders keep
/// working. `kIsWeb` guards keep every entry point a no-op on web/desktop,
/// mirroring the pattern in `ads_service.dart`.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int occurrencesPerEvent = 5;
  static const String _channelId = 'personal_events';
  static const String _channelName = 'Nhắc sự kiện cá nhân';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  int _notificationId(String eventId, int occurrenceIndex) =>
      Object.hash(eventId, occurrenceIndex) & 0x7fffffff;

  Future<void> scheduleEvent(PersonalEvent event) async {
    if (kIsWeb || !_initialized) return;
    await cancelEvent(event.id);

    final occurrences = event.nextOccurrences(count: occurrencesPerEvent);
    for (var i = 0; i < occurrences.length; i++) {
      final date = occurrences[i];
      final scheduled = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        event.reminderHour,
        event.reminderMinute,
      );
      // Skip occurrences whose reminder time has already passed today.
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _plugin.zonedSchedule(
        _notificationId(event.id, i),
        event.title,
        event.note?.isNotEmpty == true
            ? event.note
            : (event.isLunar ? 'Sự kiện âm lịch hằng năm' : 'Sự kiện dương lịch hằng năm'),
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelEvent(String eventId) async {
    if (kIsWeb) return;
    for (var i = 0; i < occurrencesPerEvent; i++) {
      await _plugin.cancel(_notificationId(eventId, i));
    }
  }
}
