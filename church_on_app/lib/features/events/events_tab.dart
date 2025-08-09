import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/events_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/widgets/upcoming_strip.dart';

class EventsTab extends ConsumerWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UpcomingStrip(),
          const SizedBox(height: 12),
          eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (events) {
              if (events.isEmpty) return const Center(child: Text('No upcoming events'));
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ev = events[i];
                  final attending = user != null && (ev.attendees[user.uid] ?? false);
                  return Card(
                    child: ListTile(
                      title: Text(ev.name),
                      subtitle: Text('${ev.startAt} • ${ev.location ?? ''}'),
                      trailing: ev.allowRsvp && user != null
                          ? FilledButton.tonal(
                              onPressed: () async {
                                final svc = ref.read(eventsServiceProvider);
                                await svc.toggleRsvp(ev.churchId, ev.id, user.uid, !attending);
                              },
                              child: Text(attending ? 'RSVP’d' : 'RSVP'),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}