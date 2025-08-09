import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tenant_providers.dart';
import '../providers/events_providers.dart';
import '../providers/auth_providers.dart';
import '../services/events_service.dart';
import '../services/interchurch_service.dart';
import '../models/event.dart';
import '../models/interchurch.dart';
import '../services/reminder_service.dart';

class UpcomingStrip extends ConsumerWidget {
  const UpcomingStrip({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (churchId == null) return const SizedBox.shrink();
    final eventsStream = EventsService().streamUpcomingEvents(churchId, limit: 20);
    final interStream = InterchurchService().streamActivitiesForParticipant(churchId);

    return SizedBox(
      height: 100,
      child: StreamBuilder<List<EventItem>>(
        stream: eventsStream,
        builder: (context, evSnap) {
          return StreamBuilder<List<InterchurchActivity>>(
            stream: interStream,
            builder: (context, icSnap) {
              final ev = evSnap.data ?? const <EventItem>[];
              final ic = (icSnap.data ?? const <InterchurchActivity>[])
                  .where((a) => a.startAt != null && a.startAt!.isAfter(DateTime.now()))
                  .toList()
                ..sort((a, b) => a.startAt!.compareTo(b.startAt!));
              if (ev.isEmpty && ic.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ev.length + ic.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isInter = i >= ev.length;
                  if (isInter) {
                    final a = ic[i - ev.length];
                    return _ChipCard(
                      label: a.title,
                      sub: 'Interchurch • ${_fmt(a.startAt)}',
                      color: Colors.indigo,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(a.title),
                            content: Text(_fmt(a.startAt)),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      onRemind: a.startAt == null
                          ? null
                          : () async {
                              final when = a.startAt!.subtract(const Duration(minutes: 15));
                              await ReminderService().scheduleReminder(
                                when: when,
                                title: 'Upcoming Interchurch: ${a.title}',
                                body: 'Starts at ${_fmt(a.startAt)}',
                              );
                            },
                    );
                  } else {
                    final e = ev[i];
                    final attending = user != null && (e.attendees[user.uid] ?? false);
                    return _ChipCard(
                      label: e.name,
                      sub: _fmt(e.startAt),
                      color: Colors.teal,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(e.name),
                            content: Text('${_fmt(e.startAt)} • ${e.location ?? ''}'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                              if (user != null && e.allowRsvp)
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await ref.read(eventsServiceProvider).toggleRsvp(e.churchId, e.id, user.uid, !attending);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(attending ? 'RSVP removed' : 'RSVP added')));
                                  },
                                  child: Text(attending ? 'Cancel RSVP' : 'RSVP'),
                                ),
                            ],
                          ),
                        );
                      },
                      onRemind: () async {
                        final when = e.startAt.subtract(const Duration(minutes: 15));
                        await ReminderService().scheduleReminder(
                          when: when,
                          title: 'Upcoming Event: ${e.name}',
                          body: 'Starts at ${_fmt(e.startAt)}',
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  String _fmt(DateTime? dt) => dt == null ? '' : '${dt.toLocal()}'.split('.').first;
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({required this.label, required this.sub, required this.color, this.onTap, this.onRemind});
  final String label;
  final String sub;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onRemind;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            if (onRemind != null)
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(onPressed: onRemind, icon: const Icon(Icons.alarm), label: const Text('Remind')),
              ),
          ],
        ),
      ),
    );
  }
}