import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/events_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/widgets/upcoming_strip.dart';
import '../../common/providers/pagination/events_pager.dart';
import '../../common/providers/analytics_providers.dart';

class EventsTab extends ConsumerWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pager = ref.watch(eventsPagerProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UpcomingStrip(),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final events = pager.items;
            if (pager.loading && events.isEmpty) return const Center(child: CircularProgressIndicator());
            if (events.isEmpty) return const Center(child: Text('No upcoming events'));
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: events.length + (pager.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i >= events.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: OutlinedButton(
                        onPressed: () => ref.read(eventsPagerProvider.notifier).loadMore(),
                        child: pager.loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load more'),
                      ),
                    ),
                  );
                }
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
                              // Analytics
                              await ref.read(analyticsServiceProvider).logRsvp(churchId: ev.churchId, eventId: ev.id, userId: user.uid, attending: !attending);
                            },
                            child: Text(attending ? 'RSVP’d' : 'RSVP'),
                          )
                        : null,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}