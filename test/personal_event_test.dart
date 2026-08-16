import 'package:flutter_test/flutter_test.dart';
import 'package:amlich/lunar/lunar_calendar.dart';
import 'package:amlich/models/personal_event.dart';

void main() {
  group('PersonalEvent.nextOccurrence - solar events', () {
    test('stays in the current year if the date has not passed yet', () {
      const event = PersonalEvent(id: '1', title: 'x', isLunar: false, day: 25, month: 12);
      final next = event.nextOccurrence(from: DateTime(2026, 1, 1));
      expect(next, DateTime(2026, 12, 25));
    });

    test('rolls to next year if the date already passed', () {
      const event = PersonalEvent(id: '1', title: 'x', isLunar: false, day: 1, month: 1);
      final next = event.nextOccurrence(from: DateTime(2026, 6, 1));
      expect(next, DateTime(2027, 1, 1));
    });

    test('today counts as upcoming, not passed', () {
      const event = PersonalEvent(id: '1', title: 'x', isLunar: false, day: 15, month: 8);
      final next = event.nextOccurrence(from: DateTime(2026, 8, 15));
      expect(next, DateTime(2026, 8, 15));
    });
  });

  group('PersonalEvent.nextOccurrence - lunar events', () {
    test('resolves via LunarCalendar and rolls to next lunar year once passed', () {
      const event = PersonalEvent(id: '1', title: 'Tết', isLunar: true, day: 1, month: 1);
      final from = DateTime(2025, 2, 1); // after Tết 2025 (29 Jan 2025)

      final (_, _, currentLunarYear, _) =
          LunarCalendar.solarToLunar(from.day, from.month, from.year);
      final expected = LunarCalendar.lunarToSolar(1, 1, currentLunarYear + 1, false)!;

      final next = event.nextOccurrence(from: from);
      expect(next, DateTime(expected.$3, expected.$2, expected.$1));
    });

    test('a lunar date still upcoming this lunar year is not rolled forward', () {
      const event = PersonalEvent(id: '1', title: 'Trung Thu', isLunar: true, day: 15, month: 8);
      // Just after Tết 2026 (17 Feb 2026), so "this lunar year" is 2026 and
      // month 8 (~Sept) genuinely hasn't happened yet.
      final from = DateTime(2026, 3, 1);

      final (_, _, currentLunarYear, _) =
          LunarCalendar.solarToLunar(from.day, from.month, from.year);
      final expected = LunarCalendar.lunarToSolar(15, 8, currentLunarYear, false)!;

      final next = event.nextOccurrence(from: from);
      expect(next, DateTime(expected.$3, expected.$2, expected.$1));
    });
  });

  test('nextOccurrences returns count strictly-increasing future dates', () {
    const event = PersonalEvent(id: '1', title: 'x', isLunar: true, day: 20, month: 3);
    final occurrences = event.nextOccurrences(count: 5, from: DateTime(2026, 1, 1));
    expect(occurrences.length, 5);
    for (var i = 1; i < occurrences.length; i++) {
      expect(occurrences[i].isAfter(occurrences[i - 1]), isTrue);
    }
  });

  group('PersonalEvent - one-time (non-recurring) events', () {
    test('repeatsYearly is false once a year is set', () {
      const event = PersonalEvent(id: '1', title: 'x', isLunar: false, day: 1, month: 1, year: 2030);
      expect(event.repeatsYearly, isFalse);
    });

    test('an upcoming one-time solar event resolves to its exact date', () {
      const event = PersonalEvent(id: '1', title: 'Đám cưới', isLunar: false, day: 20, month: 12, year: 2026);
      final next = event.nextOccurrence(from: DateTime(2026, 1, 1));
      expect(next, DateTime(2026, 12, 20));
    });

    test('a past one-time solar event has no next occurrence', () {
      const event = PersonalEvent(id: '1', title: 'Đám cưới', isLunar: false, day: 20, month: 1, year: 2020);
      final next = event.nextOccurrence(from: DateTime(2026, 1, 1));
      expect(next, isNull);
    });

    test('a one-time lunar event resolves via LunarCalendar, not a recurring search', () {
      const event = PersonalEvent(id: '1', title: 'Giỗ', isLunar: true, day: 10, month: 3, year: 2027);
      final expected = LunarCalendar.lunarToSolar(10, 3, 2027, false)!;
      final next = event.nextOccurrence(from: DateTime(2026, 1, 1));
      expect(next, DateTime(expected.$3, expected.$2, expected.$1));
    });

    test('nextOccurrences returns a single date for an upcoming one-time event', () {
      const event = PersonalEvent(id: '1', title: 'x', isLunar: false, day: 1, month: 6, year: 2030);
      final occurrences = event.nextOccurrences(from: DateTime(2026, 1, 1));
      expect(occurrences, [DateTime(2030, 6, 1)]);
    });

    test('nextOccurrences returns empty for a past one-time event', () {
      const event = PersonalEvent(id: '1', title: 'x', isLunar: false, day: 1, month: 6, year: 2010);
      final occurrences = event.nextOccurrences(from: DateTime(2026, 1, 1));
      expect(occurrences, isEmpty);
    });
  });
}
