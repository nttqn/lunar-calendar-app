import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../lunar/can_chi.dart';
import '../lunar/hoang_dao.dart';
import '../models/day_info.dart';

class DayDetailSheet extends StatelessWidget {
  final DayInfo info;

  const DayDetailSheet({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final solarLabel = DateFormat("EEEE, 'ngày' d 'tháng' M 'năm' y", 'vi')
        .format(info.solarDate);
    final goodHours = info.goodHourChiIndices;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              solarLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Âm lịch: ${info.lunarDay}/${info.lunarMonth}${info.isLeapMonth ? " (nhuận)" : ""}/${info.lunarYear}',
              style: theme.textTheme.bodyLarge,
            ),
            if (info.holidayName != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(info.holidayName!),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ],
            const SizedBox(height: 16),
            _InfoRow(label: 'Năm', value: info.yearCanChi),
            _InfoRow(label: 'Tháng', value: info.monthCanChi),
            _InfoRow(label: 'Ngày', value: info.dayCanChi),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  info.isGoodDay ? Icons.check_circle : Icons.remove_circle,
                  color: info.isGoodDay ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  info.isGoodDay ? 'Ngày hoàng đạo' : 'Ngày hắc đạo',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: info.isGoodDay ? Colors.green : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Giờ hoàng đạo',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goodHours.map((chiIndex) {
                return Chip(
                  label: Text(
                    '${CanChi.chi[chiIndex]} (${HoangDao.hourRanges[chiIndex]})',
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
