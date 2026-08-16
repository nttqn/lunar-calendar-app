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

  /// Whether this is the last day of its lunar month (29th or 30th
  /// depending on month length) — the day right before the next mùng 1.
  bool get isLastDayOfLunarMonth {
    final tomorrow = DayInfo.fromSolar(solarDate.add(const Duration(days: 1)));
    return tomorrow.lunarDay == 1;
  }

  /// Mùng 1 (start of lunar month), Rằm (mid-month), or the last day of the
  /// lunar month — the three days lunar calendars traditionally call out.
  bool get isNotableLunarDay =>
      lunarDay == 1 || lunarDay == 15 || isLastDayOfLunarMonth;

  /// The Can-Chi name of the current wall-clock 2-hour block, using this
  /// day's Can as the anchor (i.e. "if it were this hour, on this day").
  String get currentHourCanChi => CanChi.hourName(julianDay, DateTime.now().hour);
}
