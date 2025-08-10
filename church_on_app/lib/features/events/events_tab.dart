import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/events_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/widgets/upcoming_strip.dart';
import '../../common/providers/pagination/events_pager.dart';
import '../../common/providers/analytics_providers.dart';

class EventsTab extends ConsumerStatefulWidget {
  const EventsTab({super.key});

  @override
  ConsumerState<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends ConsumerState<EventsTab> {
  bool _calendar = false;

  @override
  Widget build(BuildContext context) {
    final pager = ref.watch(eventsPagerProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: Icon(_calendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _calendar = !_calendar),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UpcomingStrip(),
          const SizedBox(height: 12),
          if (_calendar)
            Container(
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: const Text('Calendar view coming soon'),
            )
          else
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
                          child: pager.loading
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Load more'),
                        ),
                      ),
                    );
                  }
                  final ev = events[i];
                  final attending = user != null && (ev.attendees[user.uid] ?? false);
                  return Card(
                    color: attending ? Theme.of(context).colorScheme.secondaryContainer : null,
                    child: ListTile(
                      title: Text(ev.name),
                      subtitle: Text('${ev.startAt} • ${ev.location ?? ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (attending)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(12)),
                              child: const Text('RSVP’d', style: TextStyle(color: Colors.white)),
                            ),
                          const SizedBox(width: 8),
                          ev.allowRsvp && user != null
                              ? FilledButton.tonal(
                                  onPressed: () async {
                                    final svc = ref.read(eventsServiceProvider);
                                    await svc.toggleRsvp(ev.churchId, ev.id, user.uid, !attending);
                                    await ref.read(analyticsServiceProvider).logRsvp(churchId: ev.churchId, eventId: ev.id, userId: user.uid, attending: !attending);
                                  },
                                  child: Text(attending ? 'Cancel' : 'RSVP'),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
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