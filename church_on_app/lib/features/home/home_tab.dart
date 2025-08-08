import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () => context.push('/ar/scan'),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('AR Church Experience'),
          ),
          const SizedBox(height: 16),
          const _Section(title: 'Featured Sermon'),
          const SizedBox(height: 12),
          const _Section(title: 'Upcoming Events'),
          const SizedBox(height: 12),
          const _Section(title: 'Announcements'),
          const SizedBox(height: 12),
          const _Section(title: 'Church News'),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Church Reports'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/reports'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}