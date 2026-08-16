import 'package:flutter/material.dart';

import '../models/personal_event.dart';
import '../services/event_repository.dart';
import 'add_event_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sự kiện cá nhân')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEventScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: EventRepository.instance,
        builder: (context, _) {
          final events = [...EventRepository.instance.events];
          if (events.isEmpty) {
            return Center(
              child: Text(
                'Chưa có sự kiện nào.\nBấm + để thêm sự kiện (sinh nhật, giỗ...).\nGiữ một sự kiện để xóa nhanh.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          // Past one-time events (nextOccurrence == null) sort to the end.
          final farFuture = DateTime(9999);
          events.sort(
            (a, b) => (a.nextOccurrence() ?? farFuture)
                .compareTo(b.nextOccurrence() ?? farFuture),
          );
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: events.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _EventTile(event: events[i]),
          );
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final PersonalEvent event;

  const _EventTile({required this.event});

  Future<void> _showQuickActions(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('Xóa sự kiện'),
            ],
          ),
        ),
      ],
    );
    if (selected != 'delete' || !context.mounted) return;

    await EventRepository.instance.deleteEvent(event.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa "${event.title}"'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          // Re-adds with the same id, which also re-schedules its reminders.
          onPressed: () => EventRepository.instance.addEvent(event),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = event.nextOccurrence();
    final daysUntil = next
        ?.difference(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ))
        .inDays;
    final calendarLabel = event.isLunar ? 'Âm lịch' : 'Dương lịch';
    final dateLabel = event.repeatsYearly
        ? '${event.day}/${event.month} $calendarLabel, lặp lại hằng năm'
        : '${event.day}/${event.month}/${event.year} $calendarLabel, một lần';

    Widget trailingChip;
    if (daysUntil == null) {
      trailingChip = Chip(
        label: const Text('Đã qua'),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        visualDensity: VisualDensity.compact,
      );
    } else {
      trailingChip = Chip(
        label: Text(daysUntil == 0 ? 'Hôm nay' : 'Còn $daysUntil ngày'),
        backgroundColor: daysUntil == 0
            ? Colors.orange.shade100
            : theme.colorScheme.surfaceContainerHighest,
        visualDensity: VisualDensity.compact,
      );
    }

    return GestureDetector(
      onLongPressStart: (details) => _showQuickActions(context, details.globalPosition),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(Icons.event, color: Colors.blue.shade700),
        ),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dateLabel),
        trailing: trailingChip,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEventScreen(existing: event)),
        ),
      ),
    );
  }
}
