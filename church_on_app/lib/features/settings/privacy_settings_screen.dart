import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/telemetry_service.dart';
import '../../common/services/privacy_service.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool _enabled = true;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _enabled,
            onChanged: (v) async {
              _enabled = v;
              await TelemetryService().setEnabled(v);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analytics ${v ? 'enabled' : 'disabled'}')));
            },
            title: const Text('Allow analytics & crash reports'),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Request data export'),
            onTap: () async {
              await PrivacyService().requestExport();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export requested')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Request account deletion'),
            onTap: () async {
              await PrivacyService().requestDeletion();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deletion requested')));
            },
          ),
        ],
      ),
    );
  }
}