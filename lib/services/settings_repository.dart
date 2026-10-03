import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/font_scale.dart';

/// App-wide user preferences (currently just font size). A `ChangeNotifier`
/// singleton, same shape as `EventRepository`, so screens can listen via
/// `ListenableBuilder` without a state-management package.
class SettingsRepository extends ChangeNotifier {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  static const String _prefsKey = 'font_scale_option';

  FontScaleOption _fontScale = FontScaleOption.small;
  FontScaleOption get fontScale => _fontScale;
  double get fontScaleFactor => _fontScale.factor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _fontScale = FontScaleOption.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => FontScaleOption.small,
      );
      notifyListeners();
    }
  }

  Future<void> setFontScale(FontScaleOption option) async {
    if (option == _fontScale) return;
    _fontScale = option;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, option.name);
  }
}
