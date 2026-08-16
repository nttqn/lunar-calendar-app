import 'package:flutter/material.dart';

import '../models/day_info.dart';
import '../services/event_repository.dart';
import '../utils/vi_date.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/date_header_card.dart';
import '../widgets/day_detail_panel.dart';
import '../widgets/hoang_dao_hours.dart';

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
  late DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  static const double _rowHeight = 56;

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EventRepository.instance,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final days = _gridDays();
    final weekCount = days.length ~/ 7;
    final selectedInfo = DayInfo.fromSolar(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Âm Dương'),
        actions: [
          TextButton.icon(
            onPressed: _goToday,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: const Text('HÔM NAY'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  DateHeaderCard(info: selectedInfo),
                  _MonthNavRow(
                    month: _displayedMonth,
                    onPrev: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                  ),
                  Row(
                    children: ViDate.shortWeekday
                        .map((l) => Expanded(
                              child: Center(
                                child: Text(
                                  l,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: l == 'CN'
                                        ? Colors.red
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const Divider(height: 1),
                  Column(
                    children: List.generate(weekCount, (w) {
                      return SizedBox(
                        height: _rowHeight,
                        child: Row(
                          children: List.generate(7, (d) {
                            final date = days[w * 7 + d];
                            final inMonth =
                                date.month == _displayedMonth.month;
                            final info = DayInfo.fromSolar(date);
                            final isSelected = date.year == _selectedDate.year &&
                                date.month == _selectedDate.month &&
                                date.day == _selectedDate.day;
                            final hasEvent = EventRepository.instance
                                .eventsOn(info)
                                .isNotEmpty;
                            return Expanded(
                              child: _DayCell(
                                date: date,
                                info: info,
                                inMonth: inMonth,
                                isSunday: d == 6,
                                isSelected: isSelected,
                                hasEvent: hasEvent,
                                onTap: () => _selectDate(date),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  const _LegendRow(),
                  DayDetailPanel(
                    info: selectedInfo,
                    events: EventRepository.instance.eventsOn(selectedInfo),
                  ),
                  HoangDaoHours(info: selectedInfo),
                  const BannerAdWidget(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthNavRow extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavRow({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Text(
            'Tháng ${month.month} - ${month.year}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget item(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 14,
        runSpacing: 4,
        children: [
          item(Colors.red, 'Ngày lễ'),
          item(Colors.green, 'Ngày hoàng đạo'),
          item(Colors.blue, 'Sự kiện cá nhân'),
          item(Colors.grey, 'Ngày hắc đạo'),
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
  final bool isSelected;
  final bool hasEvent;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.info,
    required this.inMonth,
    required this.isSunday,
    required this.isSelected,
    required this.hasEvent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirstLunarDay = info.lunarDay == 1;
    final isRam = info.lunarDay == 15;
    final isLastDay = info.isLastDayOfLunarMonth;

    final baseColor = !inMonth
        ? theme.disabledColor
        : isSunday || info.holidayName != null
            ? Colors.red
            : theme.colorScheme.onSurface;

    // Mùng 1 gets the most prominent treatment (filled pill, "d/m" label);
    // Rằm and the last day of the month get a lighter highlight — all three
    // are the days Vietnamese lunar calendars traditionally call out.
    Widget lunarLabel;
    if (isFirstLunarDay) {
      lunarLabel = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: inMonth ? Colors.orange.shade600 : theme.disabledColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${info.lunarDay}/${info.lunarMonth}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (isRam || isLastDay) {
      lunarLabel = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: inMonth ? Colors.orange.shade100 : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${info.lunarDay}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: inMonth ? Colors.orange.shade800 : theme.disabledColor,
          ),
        ),
      );
    } else {
      lunarLabel = Text(
        '${info.lunarDay}',
        style: TextStyle(
          fontSize: 10,
          color: !inMonth ? theme.disabledColor : theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: info.isToday
                  ? BoxDecoration(
                      color: Colors.orange.shade600,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: info.isToday ? Colors.white : baseColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            lunarLabel,
            if (info.holidayName != null || hasEvent)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (info.holidayName != null) const _Dot(Colors.red),
                    if (info.holidayName != null && hasEvent)
                      const SizedBox(width: 3),
                    if (hasEvent) const _Dot(Colors.blue),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
