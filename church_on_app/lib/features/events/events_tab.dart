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
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final days = nextMonth.difference(first).inDays;
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final pager = ref.watch(eventsPagerProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    final events = pager.items;

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
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                    ),
                    Text('${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1.2),
                  itemCount: _daysInMonth(_focusedMonth).length,
                  itemBuilder: (context, i) {
                    final day = _daysInMonth(_focusedMonth)[i];
                    final hasEvent = events.any((e) => e.startAt.year == day.year && e.startAt.month == day.month && e.startAt.day == day.day);
                    final selected = _selectedDay != null && day.year == _selectedDay!.year && day.month == _selectedDay!.month && day.day == _selectedDay!.day;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : hasEvent
                                  ? Theme.of(context).colorScheme.secondaryContainer
                                  : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('${day.day}', style: TextStyle(color: selected ? Colors.white : null)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          Builder(builder: (context) {
            final filtered = _selectedDay == null
                ? events
                : events.where((e) => e.startAt.year == _selectedDay!.year && e.startAt.month == _selectedDay!.month && e.startAt.day == _selectedDay!.day).toList();
            if (pager.loading && events.isEmpty) return const Center(child: CircularProgressIndicator());
            if (filtered.isEmpty) return const Center(child: Text('No events'));
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: filtered.length + (pager.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i >= filtered.length) {
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
                final ev = filtered[i];
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