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
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('Announcements'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/announcements'),
          ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('News'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/news'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Reports'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/reports'),
          ),
        ],
      ),
    );
  }
}