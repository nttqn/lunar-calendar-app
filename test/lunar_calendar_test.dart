import 'package:flutter_test/flutter_test.dart';
import 'package:amlich/lunar/can_chi.dart';
import 'package:amlich/lunar/lunar_calendar.dart';
import 'package:amlich/models/day_info.dart';

void main() {
  test('DayInfo.isLastDayOfLunarMonth is true exactly on the day before mùng 1', () {
    var d = DateTime(2020, 1, 1);
    final end = DateTime(2027, 1, 1);
    while (d.isBefore(end)) {
      final info = DayInfo.fromSolar(d);
      final next = DayInfo.fromSolar(d.add(const Duration(days: 1)));
      expect(
        info.isLastDayOfLunarMonth,
        next.lunarDay == 1,
        reason: '$d (lunar ${info.lunarDay}/${info.lunarMonth})',
      );
      d = d.add(const Duration(days: 1));
    }
  });

  group('LunarCalendar.solarToLunar - known Tết (lunar 1/1) dates', () {
    final knownTet = {
      DateTime(2023, 1, 22): (2023, 'Quý Mão'),
      DateTime(2024, 2, 10): (2024, 'Giáp Thìn'),
      DateTime(2025, 1, 29): (2025, 'Ất Tỵ'),
      DateTime(2026, 2, 17): (2026, 'Bính Ngọ'),
    };

    knownTet.forEach((solar, expected) {
      test('${solar.year}-${solar.month}-${solar.day} is 1/1 lunar (${expected.$2})', () {
        final (ld, lm, ly, leap) =
            LunarCalendar.solarToLunar(solar.day, solar.month, solar.year);
        expect(ld, 1, reason: 'lunar day');
        expect(lm, 1, reason: 'lunar month');
        expect(leap, isFalse);
        expect(CanChi.yearName(ly), expected.$2);
      });
    });
  });

  test('round trip solar -> lunar -> solar is stable for a range of dates', () {
    var d = DateTime(2000, 1, 1);
    final end = DateTime(2040, 12, 31);
    while (d.isBefore(end)) {
      final (ld, lm, ly, leap) =
          LunarCalendar.solarToLunar(d.day, d.month, d.year);
      final back = LunarCalendar.lunarToSolar(ld, lm, ly, leap);
      expect(back, isNotNull, reason: '$d -> lunar $ld/$lm/$ly leap=$leap');
      expect(back, (d.day, d.month, d.year), reason: '$d round trip');
      d = d.add(const Duration(days: 37)); // sample, not every day
    }
  });

  test('day Can-Chi advances exactly one step per day and cycles every 60 days', () {
    final jd0 = LunarCalendar.jdFromDate(1, 1, 2020);
    final names = <String>{};
    for (var i = 0; i < 60; i++) {
      names.add(CanChi.dayName(jd0 + i));
    }
    expect(names.length, 60, reason: 'all 60 sexagenary combinations appear exactly once');
    expect(CanChi.dayName(jd0), CanChi.dayName(jd0 + 60), reason: 'cycle repeats after 60 days');
  });

  test('year Can-Chi known references', () {
    expect(CanChi.yearName(1984), 'Giáp Tý');
    expect(CanChi.yearName(2024), 'Giáp Thìn');
    expect(CanChi.yearName(2025), 'Ất Tỵ');
  });
}
