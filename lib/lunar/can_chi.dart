import 'lunar_calendar.dart';

/// Can (10 heavenly stems) / Chi (12 earthly branches) sexagenary naming,
/// using the standard formulas from Hồ Ngọc Đức's algorithm reference.
class CanChi {
  CanChi._();

  static const List<String> can = [
    'Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu',
    'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý',
  ];

  static const List<String> chi = [
    'Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ',
    'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi',
  ];

  static int yearCanIndex(int lunarYear) => (lunarYear + 6) % 10;
  static int yearChiIndex(int lunarYear) => (lunarYear + 8) % 12;

  static String yearName(int lunarYear) =>
      '${can[yearCanIndex(lunarYear)]} ${chi[yearChiIndex(lunarYear)]}';

  static int monthCanIndex(int lunarYear, int lunarMonth) =>
      (lunarYear * 12 + lunarMonth + 3) % 10;
  static int monthChiIndex(int lunarMonth) => (lunarMonth + 1) % 12;

  static String monthName(int lunarYear, int lunarMonth) =>
      '${can[monthCanIndex(lunarYear, lunarMonth)]} ${chi[monthChiIndex(lunarMonth)]}';

  /// Julian day number is the canonical key for day Can-Chi — it advances
  /// exactly one sexagenary step per calendar day regardless of month/year
  /// boundaries.
  static int dayCanIndex(int julianDay) => (julianDay + 9) % 10;
  static int dayChiIndex(int julianDay) => (julianDay + 1) % 12;

  static String dayName(int julianDay) =>
      '${can[dayCanIndex(julianDay)]} ${chi[dayChiIndex(julianDay)]}';

  /// Julian day number (noon convention) for a solar date, convenience
  /// wrapper so callers don't need to import [LunarCalendar] just for this.
  static int julianDayFor(int day, int month, int year) =>
      LunarCalendar.jdFromDate(day, month, year);

  /// Chi of a 2-hour block containing [hour] (0-23): 23:00-00:59 is "giờ
  /// Tý" (index 0), 01:00-02:59 is "giờ Sửu" (index 1), etc.
  static int hourChiIndex(int hour) => ((hour + 1) ~/ 2) % 12;

  static int hourCanIndex(int julianDay, int hour) =>
      (dayCanIndex(julianDay) * 2 + hourChiIndex(hour)) % 10;

  static String hourName(int julianDay, int hour) =>
      '${can[hourCanIndex(julianDay, hour)]} ${chi[hourChiIndex(hour)]}';
}
