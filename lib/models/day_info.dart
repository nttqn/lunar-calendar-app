import '../lunar/can_chi.dart';
import '../lunar/hoang_dao.dart';
import '../lunar/holidays.dart';
import '../lunar/lunar_calendar.dart';

/// Everything the UI needs to describe a single solar day: its lunar
/// equivalent, Can-Chi names, hoàng đạo verdict, and any holiday.
class DayInfo {
  final DateTime solarDate;
  final int lunarDay;
  final int lunarMonth;
  final int lunarYear;
  final bool isLeapMonth;
  final int julianDay;
  final String? holidayName;

  const DayInfo({
    required this.solarDate,
    required this.lunarDay,
    required this.lunarMonth,
    required this.lunarYear,
    required this.isLeapMonth,
    required this.julianDay,
    required this.holidayName,
  });

  factory DayInfo.fromSolar(DateTime date) {
    final (ld, lm, ly, leap) =
        LunarCalendar.solarToLunar(date.day, date.month, date.year);
    final jd = LunarCalendar.jdFromDate(date.day, date.month, date.year);
    final holiday =
        Holidays.forSolar(date.month, date.day) ?? Holidays.forLunar(lm, ld);
    return DayInfo(
      solarDate: date,
      lunarDay: ld,
      lunarMonth: lm,
      lunarYear: ly,
      isLeapMonth: leap,
      julianDay: jd,
      holidayName: holiday,
    );
  }

  String get yearCanChi => CanChi.yearName(lunarYear);
  String get monthCanChi => CanChi.monthName(lunarYear, lunarMonth);
  String get dayCanChi => CanChi.dayName(julianDay);

  bool get isGoodDay => HoangDao.isGoodDay(lunarMonth, julianDay);
  List<int> get goodHourChiIndices => HoangDao.goodHourChiIndices(julianDay);

  /// Short "d/m" lunar label, e.g. "15/8" or "1/8 (nhuận)" for a leap month.
  String get lunarShortLabel =>
      isLeapMonth ? '$lunarDay/$lunarMonth nh' : '$lunarDay/$lunarMonth';

  bool get isToday {
    final now = DateTime.now();
    return solarDate.year == now.year &&
        solarDate.month == now.month &&
        solarDate.day == now.day;
  }
}
