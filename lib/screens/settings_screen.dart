import 'package:flutter/material.dart';

import '../models/font_scale.dart';
import '../services/settings_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListenableBuilder(
        listenable: SettingsRepository.instance,
        builder: (context, _) {
          final current = SettingsRepository.instance.fontScale;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Cỡ chữ',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Áp dụng cho toàn bộ ứng dụng.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Card(
                child: RadioGroup<FontScaleOption>(
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      SettingsRepository.instance.setFontScale(value);
                    }
                  },
                  child: Column(
                    children: FontScaleOption.values
                        .map(
                          (option) => RadioListTile<FontScaleOption>(
                            title: Text(
                              option.label,
                              style: TextStyle(fontSize: 15 * option.factor),
                            ),
                            value: option,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
