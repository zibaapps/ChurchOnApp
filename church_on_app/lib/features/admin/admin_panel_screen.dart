import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      'Users', 'Sermons', 'Testimonies', 'Prayer Requests',
      'Announcements', 'Events', 'QR Check-in'
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () => context.push('/admin/add-sermon'),
            icon: const Icon(Icons.library_add),
            label: const Text('Add Sermon'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/admin/add-event'),
            icon: const Icon(Icons.event_available),
            label: const Text('Add Event'),
          ),
          const SizedBox(height: 16),
          ...items.map((t) => Card(child: ListTile(title: Text(t), trailing: const Icon(Icons.chevron_right)))).toList(),
        ],
      ),
    );
  }
}