import 'package:flutter_test/flutter_test.dart';
import 'package:amlich/models/font_scale.dart';

void main() {
  test('small is the original/default size (factor 1.0, no visual change)', () {
    expect(FontScaleOption.small.factor, 1.0);
  });

  test('medium and large are strictly larger than small, and ordered', () {
    expect(FontScaleOption.medium.factor, greaterThan(FontScaleOption.small.factor));
    expect(FontScaleOption.large.factor, greaterThan(FontScaleOption.medium.factor));
  });

  test('every option has a non-empty label', () {
    for (final option in FontScaleOption.values) {
      expect(option.label, isNotEmpty);
    }
  });
}
