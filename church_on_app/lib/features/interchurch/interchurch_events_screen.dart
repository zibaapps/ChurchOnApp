import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/interchurch_service.dart';
import '../../common/models/interchurch.dart';
import '../../common/providers/tenant_providers.dart';

class InterchurchEventsScreen extends ConsumerWidget {
  const InterchurchEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = InterchurchService().streamEvents();
    final churchId = ref.watch(activeChurchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Interchurch Events')),
      floatingActionButton: churchId == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                // Minimal quick-create as interchurch activity
                final svc = InterchurchService();
                final activity = InterchurchActivity(
                  id: 'new',
                  activityType: ActivityType.event,
                  title: 'New Interchurch Event',
                  description: 'Describe the event',
                  leadChurchId: churchId,
                  participants: [churchId],
                  participantStatuses: {churchId: 'accepted'},
                  startAt: DateTime.now().add(const Duration(days: 7)),
                  endAt: DateTime.now().add(const Duration(days: 7, hours: 2)),
                  location: 'TBD',
                  streams: const {},
                );
                await svc.createActivity(activity);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interchurch event draft created')));
                }
              },
              child: const Icon(Icons.add),
            ),
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
              final accepted = e.participatingChurchIds.length;
              return Card(
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.date.toLocal()} • ${e.location ?? ''}'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Chip(label: Text('Interchurch')),
                          if ((e.participatingChurchIds).isNotEmpty) Chip(label: Text('${e.participatingChurchIds.length} churches')),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.groups, size: 18),
                      const SizedBox(width: 6),
                      Text('$accepted'),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use the + button to create an interchurch event, then invite churches.')));
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