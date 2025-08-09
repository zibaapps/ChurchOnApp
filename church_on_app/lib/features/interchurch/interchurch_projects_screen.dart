import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/interchurch_service.dart';
import '../../common/models/interchurch.dart';
import '../../common/providers/tenant_providers.dart';

class InterchurchProjectsScreen extends ConsumerWidget {
  const InterchurchProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = InterchurchService().streamProjects();
    final churchId = ref.watch(activeChurchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Interchurch Projects')),
      floatingActionButton: churchId == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final svc = InterchurchService();
                final activity = InterchurchActivity(
                  id: 'new',
                  activityType: ActivityType.project,
                  title: 'New Interchurch Project',
                  description: 'Describe the project',
                  leadChurchId: churchId,
                  participants: [churchId],
                  participantStatuses: {churchId: 'accepted'},
                  streams: const {},
                );
                await svc.createActivity(activity);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interchurch project draft created')));
                }
              },
              child: const Icon(Icons.add),
            ),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('K${p.totalGiving.toStringAsFixed(2)}'),
                      IconButton(
                        icon: const Icon(Icons.add_card),
                        onPressed: () async {
                          await InterchurchService().addProjectGiving(p.id, 10);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added K10.00 to total giving')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}