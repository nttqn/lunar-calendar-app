/// Emoji stand-in for a Chi (earthly branch) zodiac icon — avoids needing
/// bundled image assets for the 12 animals shown next to each "giờ hoàng
/// đạo" entry.
class ZodiacIcon {
  ZodiacIcon._();

  /// Indexed 0=Tý..11=Hợi, matching [CanChi.chi].
  static const List<String> emoji = [
    '🐭', '🐂', '🐯', '🐱', '🐉', '🐍',
    '🐴', '🐐', '🐵', '🐔', '🐶', '🐷',
  ];
}
