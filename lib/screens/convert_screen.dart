import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../lunar/lunar_calendar.dart';
import '../models/day_info.dart';
import '../widgets/max_width_body.dart';
import '../widgets/number_field.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  DateTime _solarPick = DateTime.now();

  int _lunarDay = DateTime.now().day.clamp(1, 30);
  int _lunarMonth = DateTime.now().month;
  int _lunarYear = DateTime.now().year;
  bool _lunarLeap = false;
  (int, int, int)? _lunarToSolarResult;
  bool _lunarToSolarInvalid = false;

  Future<void> _pickSolarDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _solarPick,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _solarPick = picked);
  }

  void _convertLunarToSolar() {
    final result = LunarCalendar.lunarToSolar(
      _lunarDay,
      _lunarMonth,
      _lunarYear,
      _lunarLeap,
    );
    setState(() {
      _lunarToSolarResult = result;
      _lunarToSolarInvalid = result == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final solarInfo = DayInfo.fromSolar(_solarPick);

    return Scaffold(
      appBar: AppBar(title: const Text('Chuyển đổi ngày')),
      body: MaxWidthBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Dương lịch → Âm lịch',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(DateFormat("dd/MM/yyyy", 'vi').format(_solarPick)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickSolarDate,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Âm lịch: ${solarInfo.lunarDay}/${solarInfo.lunarMonth}'
                  '${solarInfo.isLeapMonth ? " (nhuận)" : ""}/${solarInfo.lunarYear}\n'
                  'Năm ${solarInfo.yearCanChi} - Tháng ${solarInfo.monthCanChi} - Ngày ${solarInfo.dayCanChi}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Âm lịch → Dương lịch',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    label: 'Ngày',
                    value: _lunarDay,
                    min: 1,
                    max: 30,
                    onChanged: (v) => setState(() => _lunarDay = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberField(
                    label: 'Tháng',
                    value: _lunarMonth,
                    min: 1,
                    max: 12,
                    onChanged: (v) => setState(() => _lunarMonth = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: NumberField(
                    label: 'Năm',
                    value: _lunarYear,
                    min: 1900,
                    max: 2100,
                    onChanged: (v) => setState(() => _lunarYear = v),
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tháng nhuận'),
              value: _lunarLeap,
              onChanged: (v) => setState(() => _lunarLeap = v ?? false),
            ),
            FilledButton(
              onPressed: _convertLunarToSolar,
              child: const Text('Chuyển đổi'),
            ),
            const SizedBox(height: 8),
            if (_lunarToSolarInvalid)
              Text(
                'Tháng $_lunarMonth năm $_lunarYear không phải tháng nhuận.',
                style: const TextStyle(color: Colors.red),
              )
            else if (_lunarToSolarResult != null)
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Dương lịch: ${_lunarToSolarResult!.$1}/${_lunarToSolarResult!.$2}/${_lunarToSolarResult!.$3}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
