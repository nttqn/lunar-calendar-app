/// User-selectable app-wide text size. [small] is the original/default
/// size the app always had; [medium]/[large] scale every Text widget up
/// via a MediaQuery textScaler override in main.dart.
enum FontScaleOption { small, medium, large }

extension FontScaleOptionX on FontScaleOption {
  double get factor {
    switch (this) {
      case FontScaleOption.small:
        return 1.0;
      case FontScaleOption.medium:
        return 1.15;
      case FontScaleOption.large:
        return 1.3;
    }
  }

  String get label {
    switch (this) {
      case FontScaleOption.small:
        return 'Nhỏ (mặc định)';
      case FontScaleOption.medium:
        return 'Vừa';
      case FontScaleOption.large:
        return 'Lớn';
    }
  }
}
