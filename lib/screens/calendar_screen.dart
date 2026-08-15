import 'package:flutter/material.dart';

import '../models/day_info.dart';
import '../widgets/banner_ad_widget.dart';
import 'day_detail_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  static const List<String> _weekdayLabels = [
    'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN',
  ];

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() => _displayedMonth = DateTime(now.year, now.month));
  }

  List<DateTime> _gridDays() {
    final first = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final leading = first.weekday - DateTime.monday;
    final start = first.subtract(Duration(days: leading));
    final lastOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final trailing = DateTime.sunday - lastOfMonth.weekday;
    final end = lastOfMonth.add(Duration(days: trailing));

    final days = <DateTime>[];
    var d = start;
    while (!d.isAfter(end)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  void _openDetail(DayInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DayDetailSheet(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _gridDays();
    final weekCount = days.length ~/ 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Âm Dương'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Hôm nay',
            onPressed: _goToday,
          ),
        ],
      ),
      body: Column(
        children: [
          _MonthHeader(
            month: _displayedMonth,
            onPrev: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          Row(
            children: _weekdayLabels
                .map((l) => Expanded(
                      child: Center(
                        child: Text(
                          l,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: l == 'CN'
                                ? Colors.red
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const Divider(height: 1),
          Expanded(
            child: Column(
              children: List.generate(weekCount, (w) {
                return Expanded(
                  child: Row(
                    children: List.generate(7, (d) {
                      final date = days[w * 7 + d];
                      final inMonth = date.month == _displayedMonth.month;
                      final info = DayInfo.fromSolar(date);
                      return Expanded(
                        child: _DayCell(
                          date: date,
                          info: info,
                          inMonth: inMonth,
                          isSunday: d == 6,
                          onTap: () => _openDetail(info),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
          const SafeArea(top: false, child: BannerAdWidget()),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Text(
            'Tháng ${month.month} - ${month.year}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final DayInfo info;
  final bool inMonth;
  final bool isSunday;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.info,
    required this.inMonth,
    required this.isSunday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirstLunarDay = info.lunarDay == 1;
    final baseColor = !inMonth
        ? theme.disabledColor
        : isSunday
            ? Colors.red
            : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: info.isToday
                  ? BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: info.isToday ? theme.colorScheme.onPrimary : baseColor,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              isFirstLunarDay ? 'T${info.lunarMonth}' : '${info.lunarDay}',
              style: TextStyle(
                fontSize: 10,
                color: !inMonth
                    ? theme.disabledColor
                    : isFirstLunarDay
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                fontWeight: isFirstLunarDay ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (info.holidayName != null)
              Container(
                margin: const EdgeInsets.only(top: 1),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
