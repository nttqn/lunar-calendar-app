/// Vietnamese weekday naming — the colloquial "Hai/Ba/Tư/Năm/Sáu/Bảy/CN"
/// short form and the full "Thứ Hai/.../Chủ Nhật" form used in headers.
class ViDate {
  ViDate._();

  /// Indexed by [DateTime.weekday] - 1 (1=Monday..7=Sunday).
  static const List<String> shortWeekday = [
    'Hai', 'Ba', 'Tư', 'Năm', 'Sáu', 'Bảy', 'CN',
  ];

  static const List<String> fullWeekday = [
    'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật',
  ];

  static String short(DateTime date) => shortWeekday[date.weekday - 1];
  static String full(DateTime date) => fullWeekday[date.weekday - 1];
}
