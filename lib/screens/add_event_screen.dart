import 'package:flutter/material.dart';

import '../models/personal_event.dart';
import '../services/event_repository.dart';
import '../widgets/number_field.dart';

/// Add/edit form for a [PersonalEvent]. Pass [existing] to edit (adds a
/// Delete action); omit it to create a new event.
class AddEventScreen extends StatefulWidget {
  final PersonalEvent? existing;

  const AddEventScreen({super.key, this.existing});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _noteController =
      TextEditingController(text: widget.existing?.note ?? '');

  late bool _isLunar = widget.existing?.isLunar ?? false;
  late int _day = widget.existing?.day ?? DateTime.now().day.clamp(1, 28);
  late int _month = widget.existing?.month ?? DateTime.now().month;
  late TimeOfDay _reminderTime = TimeOfDay(
    hour: widget.existing?.reminderHour ?? 8,
    minute: widget.existing?.reminderMinute ?? 0,
  );

  bool get _isEditing => widget.existing != null;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_isEditing) {
      await EventRepository.instance.updateEvent(
        widget.existing!.copyWith(
          title: title,
          note: _noteController.text.trim(),
          isLunar: _isLunar,
          day: _day,
          month: _month,
          reminderHour: _reminderTime.hour,
          reminderMinute: _reminderTime.minute,
        ),
      );
    } else {
      await EventRepository.instance.createEvent(
        title: title,
        note: _noteController.text.trim(),
        isLunar: _isLunar,
        day: _day,
        month: _month,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await EventRepository.instance.deleteEvent(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxDay = _isLunar ? 30 : 31;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa sự kiện' : 'Thêm sự kiện'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Tên sự kiện'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)'),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Dương lịch')),
              ButtonSegment(value: true, label: Text('Âm lịch')),
            ],
            selected: {_isLunar},
            onSelectionChanged: (s) => setState(() {
              _isLunar = s.first;
              if (_day > maxDay) _day = maxDay;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NumberField(
                  label: 'Ngày',
                  value: _day,
                  min: 1,
                  max: maxDay,
                  onChanged: (v) => setState(() => _day = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NumberField(
                  label: 'Tháng',
                  value: _month,
                  min: 1,
                  max: 12,
                  onChanged: (v) => setState(() => _month = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lặp lại hằng năm vào ngày này (${_isLunar ? "âm lịch" : "dương lịch"}).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Nhắc lúc'),
            trailing: Text(
              _reminderTime.format(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: _pickTime,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
