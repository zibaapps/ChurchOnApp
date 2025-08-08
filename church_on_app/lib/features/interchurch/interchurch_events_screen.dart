import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/interchurch_service.dart';
import '../../common/models/interchurch.dart';

class InterchurchEventsScreen extends ConsumerWidget {
  const InterchurchEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = InterchurchService().streamEvents();
    return Scaffold(
      appBar: AppBar(title: const Text('Interchurch Events')),
      body: StreamBuilder<List<InterchurchEvent>>(
        stream: stream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <InterchurchEvent>[];
          if (items.isEmpty) return const Center(child: Text('No interchurch events'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = items[i];
              return Card(
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Text('${e.date.toLocal()} • ${e.location ?? ''}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}