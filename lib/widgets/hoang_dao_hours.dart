import 'package:flutter/material.dart';

import '../lunar/can_chi.dart';
import '../lunar/hoang_dao.dart';
import '../models/day_info.dart';
import 'zodiac_icon.dart';

/// "Giờ Hoàng Đạo" section: the 6 auspicious 2-hour blocks for the
/// selected day, each shown with a zodiac icon, Chi name, and time range.
class HoangDaoHours extends StatelessWidget {
  final DayInfo info;

  const HoangDaoHours({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = info.goodHourChiIndices;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giờ Hoàng Đạo',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            childAspectRatio: 2.4,
            children: hours.map((chiIndex) => _HourTile(chiIndex: chiIndex)).toList(),
          ),
        ],
      ),
    );
  }
}

class _HourTile extends StatelessWidget {
  final int chiIndex;

  const _HourTile({required this.chiIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(ZodiacIcon.emoji[chiIndex], style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 6),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CanChi.chi[chiIndex],
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '(${HoangDao.hourRanges[chiIndex]})',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}
