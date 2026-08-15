import 'can_chi.dart';

/// Traditional "hoàng đạo" (auspicious) / "hắc đạo" (inauspicious) lookup
/// tables from Vietnamese folk almanacs (lịch vạn niên). These are fixed
/// reference tables, not computed astronomy — implemented here from the
/// commonly published version of the tables. Different printed almanacs
/// occasionally disagree on a handful of entries, so treat this as a
/// good-faith default rather than an authoritative source; worth spot
/// checking against a printed almanac before relying on it for anything
/// important.
class HoangDao {
  HoangDao._();

  /// Chi index (of the day) -> list of Chi indices (of the hour) that are
  /// "giờ hoàng đạo" (auspicious 2-hour blocks) on that day.
  static const Map<int, List<int>> _hourGroups = {
    0: [0, 1, 3, 6, 8, 9], // Ngày Tý
    6: [0, 1, 3, 6, 8, 9], // Ngày Ngọ
    1: [2, 3, 5, 8, 10, 11], // Ngày Sửu
    7: [2, 3, 5, 8, 10, 11], // Ngày Mùi
    2: [0, 1, 4, 5, 7, 10], // Ngày Dần
    8: [0, 1, 4, 5, 7, 10], // Ngày Thân
    3: [0, 2, 3, 6, 7, 9], // Ngày Mão
    9: [0, 2, 3, 6, 7, 9], // Ngày Dậu
    4: [2, 4, 5, 8, 9, 11], // Ngày Thìn
    10: [2, 4, 5, 8, 9, 11], // Ngày Tuất
    5: [1, 4, 6, 7, 10, 11], // Ngày Tỵ
    11: [1, 4, 6, 7, 10, 11], // Ngày Hợi
  };

  /// Lunar month (1-12) -> list of Chi indices (of the day) that are
  /// "ngày hoàng đạo" (auspicious days) in that month.
  static const Map<int, List<int>> _dayGroups = {
    1: [0, 1, 5, 7, 10, 11],
    7: [0, 1, 5, 7, 10, 11],
    2: [0, 2, 3, 6, 7, 9],
    8: [0, 2, 3, 6, 7, 9],
    3: [2, 4, 5, 8, 9, 11],
    9: [2, 4, 5, 8, 9, 11],
    4: [1, 4, 6, 7, 10, 11],
    10: [1, 4, 6, 7, 10, 11],
    5: [0, 1, 3, 6, 8, 9],
    11: [0, 1, 3, 6, 8, 9],
    6: [2, 3, 5, 8, 10, 11],
    12: [2, 3, 5, 8, 10, 11],
  };

  /// Whether the given lunar [lunarMonth] + solar [julianDay] combination
  /// is a "ngày hoàng đạo" (auspicious day).
  static bool isGoodDay(int lunarMonth, int julianDay) {
    final dayChi = CanChi.dayChiIndex(julianDay);
    return (_dayGroups[lunarMonth] ?? const []).contains(dayChi);
  }

  /// The 6 auspicious 2-hour blocks (as hour-Chi indices, 0=Tý..11=Hợi)
  /// for the day identified by [julianDay].
  static List<int> goodHourChiIndices(int julianDay) {
    final dayChi = CanChi.dayChiIndex(julianDay);
    return _hourGroups[dayChi] ?? const [];
  }

  /// Human-readable label + time range for each of the 12 two-hour blocks,
  /// indexed by hour-Chi index (0=Tý..11=Hợi).
  static const List<String> hourRanges = [
    '23h-1h', '1h-3h', '3h-5h', '5h-7h', '7h-9h', '9h-11h',
    '11h-13h', '13h-15h', '15h-17h', '17h-19h', '19h-21h', '21h-23h',
  ];
}
