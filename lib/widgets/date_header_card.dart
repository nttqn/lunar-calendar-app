import 'package:flutter/material.dart';

import '../models/day_info.dart';
import '../utils/vi_date.dart';

/// Peach-toned header card showing the selected day's full solar date and
/// its lunar equivalent + year Can-Chi, matching the reference lịch vạn
/// niên app layout.
class DateHeaderCard extends StatelessWidget {
  final DayInfo info;

  const DateHeaderCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ViDate.full(info.solarDate)}, ${info.solarDate.day} '
            'Tháng ${info.solarDate.month}, ${info.solarDate.year}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${info.lunarDay} Tháng ${info.lunarMonth}'
            '${info.isLeapMonth ? " (nhuận)" : ""} Âm lịch, '
            'Năm ${info.yearCanChi}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
