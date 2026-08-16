import 'package:flutter/material.dart';

import '../models/day_info.dart';
import '../models/personal_event.dart';
import '../utils/vi_date.dart';

/// Compact inline card below the calendar grid: selected day's full date +
/// lunar date on the left, hoàng đạo/hắc đạo verdict, and Giờ/Ngày/Tháng
/// Can-Chi stacked on the right. Any personal events on this day are listed
/// underneath.
class DayDetailPanel extends StatelessWidget {
  final DayInfo info;
  final List<PersonalEvent> events;

  const DayDetailPanel({super.key, required this.info, this.events = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lunarLine = '${info.lunarDay} Tháng ${info.lunarMonth}'
        '${info.isLeapMonth ? " (nhuận)" : ""} Năm ${info.yearCanChi}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ViDate.full(info.solarDate)}, ${info.solarDate.day} '
                        'Tháng ${info.solarDate.month}, ${info.solarDate.year}',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(lunarLine, style: theme.textTheme.bodySmall),
                      if (info.holidayName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          info.holidayName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: info.isGoodDay ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            info.isGoodDay ? 'Ngày hoàng đạo' : 'Ngày hắc đạo',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: info.isGoodDay
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Giờ ${info.currentHourCanChi}',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text('Ngày ${info.dayCanChi}',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text('Tháng ${info.monthCanChi}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            if (events.isNotEmpty) ...[
              const Divider(height: 20),
              ...events.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.title,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
