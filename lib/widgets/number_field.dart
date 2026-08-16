import 'package:flutter/material.dart';

/// Small labeled numeric input, clamped to [min]-[max], used anywhere a
/// day/month/year needs typing in (date converter, event day/month picker).
class NumberField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: '$value',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, isDense: true),
      onChanged: (text) {
        final n = int.tryParse(text);
        if (n != null && n >= min && n <= max) onChanged(n);
      },
    );
  }
}
