import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/services/interchurch_service.dart';
import '../../common/models/interchurch.dart';

class YearProgramScreen extends ConsumerStatefulWidget {
  const YearProgramScreen({super.key});

  @override
  ConsumerState<YearProgramScreen> createState() => _YearProgramScreenState();
}

class _YearProgramScreenState extends ConsumerState<YearProgramScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('No active church')));
    final stream = InterchurchService().streamPublishedProgramEntriesForChurch(churchId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Year Programs'),
        actions: [
          PopupMenuButton<String?>(
            onSelected: (v) => setState(() => _category = v),
            itemBuilder: (context) => <PopupMenuEntry<String?>>[
              const PopupMenuItem(value: null, child: Text('All Categories')),
              const PopupMenuItem(value: 'service', child: Text('Service')),
              const PopupMenuItem(value: 'outreach', child: Text('Outreach')),
              const PopupMenuItem(value: 'conference', child: Text('Conference')),
              const PopupMenuItem(value: 'youth', child: Text('Youth')),
              const PopupMenuItem(value: 'worship', child: Text('Worship')),
              const PopupMenuItem(value: 'training', child: Text('Training')),
              const PopupMenuItem(value: 'other', child: Text('Other')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<List<YearProgramEntry>>(
        stream: stream,
        builder: (context, snap) {
          var items = snap.data ?? const <YearProgramEntry>[];
          if (_category != null) {
            items = items.where((e) => e.category == _category).toList();
          }
          if (items.isEmpty) return const Center(child: Text('No program entries'));
          items.sort((a, b) => (a.startAt ?? DateTime.now()).compareTo(b.startAt ?? DateTime.now()));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final it = items[i];
              final dateRange = _formatRange(it.startAt, it.endAt);
              return Card(
                child: ListTile(
                  title: Text(it.title),
                  subtitle: Text([dateRange, it.location ?? ''].where((e) => e.isNotEmpty).join(' • ')),
                  trailing: it.isInterchurch ? const Icon(Icons.groups) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatRange(DateTime? a, DateTime? b) {
    if (a == null && b == null) return '';
    if (a != null && b == null) return a.toLocal().toString();
    if (a == null && b != null) return b.toLocal().toString();
    return '${a!.toLocal()} - ${b!.toLocal()}';
  }
}