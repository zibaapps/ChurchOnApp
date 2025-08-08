import 'package:flutter/material.dart';

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(items[index]),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}