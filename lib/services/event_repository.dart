import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/day_info.dart';
import '../models/personal_event.dart';
import 'notification_service.dart';

/// In-memory + `shared_preferences`-persisted store of the user's personal
/// events. A `ChangeNotifier` so screens can listen via `ListenableBuilder`
/// without pulling in a state-management package.
class EventRepository extends ChangeNotifier {
  EventRepository._();
  static final EventRepository instance = EventRepository._();

  static const String _prefsKey = 'personal_events';

  List<PersonalEvent> _events = [];
  List<PersonalEvent> get events => List.unmodifiable(_events);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _events = decoded
          .map((e) => PersonalEvent.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_events.map((e) => e.toJson()).toList()),
    );
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_events.length}';

  Future<void> addEvent(PersonalEvent event) async {
    _events.add(event);
    notifyListeners();
    await _persist();
    await NotificationService.instance.scheduleEvent(event);
  }

  /// Builds a new event with a fresh id and adds it. Leave [year] null for
  /// an event that repeats every year; set it for a one-time event.
  Future<void> createEvent({
    required String title,
    String? note,
    required bool isLunar,
    required int day,
    required int month,
    int? year,
    int reminderHour = 8,
    int reminderMinute = 0,
  }) {
    return addEvent(PersonalEvent(
      id: _newId(),
      title: title,
      note: note,
      isLunar: isLunar,
      day: day,
      month: month,
      year: year,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    ));
  }

  Future<void> updateEvent(PersonalEvent updated) async {
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    _events[index] = updated;
    notifyListeners();
    await _persist();
    await NotificationService.instance.scheduleEvent(updated);
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
    await NotificationService.instance.cancelEvent(id);
  }

  /// Events that fall on the given calendar day (matched by lunar or solar
  /// day/month depending on how each event was created). A one-time event
  /// (non-null `year`) additionally only matches that exact year, since it
  /// doesn't recur.
  List<PersonalEvent> eventsOn(DayInfo info) {
    return _events.where((e) {
      if (e.isLunar) {
        if (e.day != info.lunarDay || e.month != info.lunarMonth) return false;
        return e.year == null || e.year == info.lunarYear;
      }
      if (e.day != info.solarDate.day || e.month != info.solarDate.month) {
        return false;
      }
      return e.year == null || e.year == info.solarDate.year;
    }).toList();
  }

  /// Re-schedules notifications for every event — called on app startup to
  /// top up occurrences consumed since the last launch (see
  /// NotificationService's doc comment for why this is necessary).
  Future<void> rescheduleAll() async {
    for (final event in _events) {
      await NotificationService.instance.scheduleEvent(event);
    }
  }
}
