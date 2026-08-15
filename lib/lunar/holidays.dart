/// Fixed-date Vietnamese holidays, both solar and lunar calendar.
class Holiday {
  final int month;
  final int day;
  final String name;

  const Holiday(this.month, this.day, this.name);
}

class Holidays {
  Holidays._();

  /// Keyed by solar (dương lịch) month/day.
  static const List<Holiday> solar = [
    Holiday(1, 1, 'Tết Dương lịch'),
    Holiday(2, 14, "Lễ Valentine"),
    Holiday(3, 8, 'Quốc tế Phụ nữ'),
    Holiday(4, 30, 'Giải phóng miền Nam'),
    Holiday(5, 1, 'Quốc tế Lao động'),
    Holiday(6, 1, 'Quốc tế Thiếu nhi'),
    Holiday(9, 2, 'Quốc khánh'),
    Holiday(10, 20, 'Ngày Phụ nữ Việt Nam'),
    Holiday(11, 20, 'Ngày Nhà giáo Việt Nam'),
    Holiday(12, 24, 'Lễ Giáng sinh (đêm)'),
    Holiday(12, 25, 'Lễ Giáng sinh'),
  ];

  /// Keyed by lunar (âm lịch) month/day.
  static const List<Holiday> lunar = [
    Holiday(1, 1, 'Tết Nguyên Đán'),
    Holiday(1, 15, 'Tết Nguyên Tiêu (Rằm tháng Giêng)'),
    Holiday(3, 3, 'Tết Hàn Thực'),
    Holiday(3, 10, 'Giỗ Tổ Hùng Vương'),
    Holiday(4, 15, 'Lễ Phật Đản'),
    Holiday(5, 5, 'Tết Đoan Ngọ'),
    Holiday(7, 15, 'Lễ Vu Lan'),
    Holiday(8, 15, 'Tết Trung Thu'),
    Holiday(10, 15, 'Tết Hạ Nguyên'),
    Holiday(12, 23, 'Ông Táo về trời'),
    Holiday(12, 30, 'Giao thừa'),
  ];

  static String? forSolar(int month, int day) {
    for (final h in solar) {
      if (h.month == month && h.day == day) return h.name;
    }
    return null;
  }

  static String? forLunar(int month, int day) {
    for (final h in lunar) {
      if (h.month == month && h.day == day) return h.name;
    }
    return null;
  }
}
