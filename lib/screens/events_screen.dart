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
                'Chưa có sự kiện nào.\nBấm + để thêm sự kiện (sinh nhật, giỗ...).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          events.sort(
            (a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = event.nextOccurrence();
    final daysUntil = next
        .difference(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ))
        .inDays;
    final dateLabel = event.isLunar
        ? '${event.day}/${event.month} Âm lịch, lặp lại hằng năm'
        : '${event.day}/${event.month} Dương lịch, lặp lại hằng năm';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(Icons.event, color: Colors.blue.shade700),
      ),
      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(dateLabel),
      trailing: Chip(
        label: Text(daysUntil == 0 ? 'Hôm nay' : 'Còn $daysUntil ngày'),
        backgroundColor: daysUntil == 0
            ? Colors.orange.shade100
            : theme.colorScheme.surfaceContainerHighest,
        visualDensity: VisualDensity.compact,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AddEventScreen(existing: event)),
      ),
    );
  }
}
