import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tenant_providers.dart';
import '../services/events_service.dart';
import '../services/interchurch_service.dart';
import '../models/event.dart';
import '../models/interchurch.dart';

class UpcomingStrip extends ConsumerWidget {
  const UpcomingStrip({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const SizedBox.shrink();
    final eventsStream = EventsService().streamUpcomingEvents(churchId, limit: 20);
    final interStream = InterchurchService().streamActivitiesForParticipant(churchId);

    return SizedBox(
      height: 92,
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
                    );
                  } else {
                    final e = ev[i];
                    return _ChipCard(
                      label: e.name,
                      sub: _fmt(e.startAt),
                      color: Colors.teal,
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
  const _ChipCard({required this.label, required this.sub, required this.color});
  final String label;
  final String sub;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
        ],
      ),
    );
  }
}