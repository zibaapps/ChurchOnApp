import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/accessibility_providers.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highContrast = ref.watch(highContrastProvider);
    final textScale = ref.watch(textScaleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: highContrast,
            onChanged: (v) => ref.read(highContrastProvider.notifier).state = v,
            title: const Text('High contrast'),
          ),
          const SizedBox(height: 8),
          Text('Text size: ${(textScale * 100).round()}%'),
          Slider(
            min: 0.8,
            max: 1.6,
            divisions: 8,
            value: textScale,
            onChanged: (v) => ref.read(textScaleProvider.notifier).state = v,
          ),
        ],
      ),
    );
  }
}