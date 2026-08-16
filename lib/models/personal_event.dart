import '../lunar/lunar_calendar.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A user-created event anchored to a day/month (solar or lunar) —
/// birthdays, anniversaries, giỗ, etc. When [year] is null the event
/// repeats every year on that day/month; when [year] is set it's a
/// one-time event on that exact date and has no occurrence after it.
class PersonalEvent {
  final String id;
  final String title;
  final String? note;
  final bool isLunar;
  final int day; // 1-31 (solar) or 1-30 (lunar)
  final int month; // 1-12
  final int? year; // null = repeats yearly; set = one-time only
  final int reminderHour;
  final int reminderMinute;

  const PersonalEvent({
    required this.id,
    required this.title,
    this.note,
    required this.isLunar,
    required this.day,
    required this.month,
    this.year,
    this.reminderHour = 8,
    this.reminderMinute = 0,
  });

  bool get repeatsYearly => year == null;

  PersonalEvent copyWith({
    String? title,
    String? note,
    bool? isLunar,
    int? day,
    int? month,
    bool clearYear = false,
    int? year,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return PersonalEvent(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      isLunar: isLunar ?? this.isLunar,
      day: day ?? this.day,
      month: month ?? this.month,
      year: clearYear ? null : (year ?? this.year),
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'isLunar': isLunar,
        'day': day,
        'month': month,
        'year': year,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  factory PersonalEvent.fromJson(Map<String, dynamic> json) => PersonalEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        note: json['note'] as String?,
        isLunar: json['isLunar'] as bool,
        day: json['day'] as int,
        month: json['month'] as int,
        year: json['year'] as int?,
        reminderHour: json['reminderHour'] as int? ?? 8,
        reminderMinute: json['reminderMinute'] as int? ?? 0,
      );

  /// Resolves this event's lunar day/month in [lunarYear] to a solar date.
  /// Note: if [day] doesn't exist in a short lunar month that year (e.g.
  /// day 30 in a 29-day month), this rolls into the 1st of the next lunar
  /// month — the same behavior `LunarCalendar.lunarToSolar` already has
  /// for any lunar date, not a special case introduced here.
  DateTime? _lunarOccurrenceInYear(int lunarYear) {
    final result = LunarCalendar.lunarToSolar(day, month, lunarYear, false);
    if (result == null) return null;
    final (d, m, y) = result;
    return DateTime(y, m, d);
  }

  /// The next time this event falls on/after [from] (defaults to now), or
  /// null if it's a one-time event whose date has already passed.
  DateTime? nextOccurrence({DateTime? from}) {
    final base = _dateOnly(from ?? DateTime.now());

    if (year != null) {
      final occurrence =
          isLunar ? _lunarOccurrenceInYear(year!) : DateTime(year!, month, day);
      if (occurrence == null || occurrence.isBefore(base)) return null;
      return occurrence;
    }

    if (!isLunar) {
      var candidate = DateTime(base.year, month, day);
      if (candidate.isBefore(base)) {
        candidate = DateTime(base.year + 1, month, day);
      }
      return candidate;
    }

    final (_, _, currentLunarYear, _) =
        LunarCalendar.solarToLunar(base.day, base.month, base.year);
    var lunarYear = currentLunarYear;
    var candidate = _lunarOccurrenceInYear(lunarYear);
    while (candidate == null || candidate.isBefore(base)) {
      lunarYear += 1;
      candidate = _lunarOccurrenceInYear(lunarYear);
    }
    return candidate;
  }

  /// The next [count] occurrences on/after [from], used to pre-schedule
  /// several years of reminders at once (see NotificationService). A
  /// one-time event has at most one occurrence (empty list if it already
  /// passed).
  List<DateTime> nextOccurrences({int count = 5, DateTime? from}) {
    if (year != null) {
      final occurrence = nextOccurrence(from: from);
      return occurrence == null ? [] : [occurrence];
    }

    final base = _dateOnly(from ?? DateTime.now());
    final result = <DateTime>[];
    var cursor = base;
    for (var i = 0; i < count; i++) {
      final occurrence = nextOccurrence(from: cursor)!;
      result.add(occurrence);
      cursor = occurrence.add(const Duration(days: 1));
    }
    return result;
  }
}
