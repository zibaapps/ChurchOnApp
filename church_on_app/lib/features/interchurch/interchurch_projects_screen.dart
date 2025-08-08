import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/interchurch_service.dart';
import '../../common/models/interchurch.dart';

class InterchurchProjectsScreen extends ConsumerWidget {
  const InterchurchProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = InterchurchService().streamProjects();
    return Scaffold(
      appBar: AppBar(title: const Text('Interchurch Projects')),
      body: StreamBuilder<List<InterchurchProject>>(
        stream: stream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <InterchurchProject>[];
          if (items.isEmpty) return const Center(child: Text('No projects'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = items[i];
              return Card(
                child: ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.description ?? ''),
                  trailing: Text('Total: K${p.totalGiving.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}