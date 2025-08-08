import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/admin/add-announcement'),
            icon: const Icon(Icons.campaign),
            label: const Text('Add Announcement'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/admin/add-news'),
            icon: const Icon(Icons.newspaper),
            label: const Text('Add News'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/admin/add-report'),
            icon: const Icon(Icons.description),
            label: const Text('Add Report'),
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
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Invite Cards'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/invites'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Tenant Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/admin/tenant-settings'),
          ),
        ],
      ),
    );
  }
}