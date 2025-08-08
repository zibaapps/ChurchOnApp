import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/services/interchurch_service.dart';
import '../../common/models/interchurch.dart';

class YearProgramScreen extends ConsumerWidget {
  const YearProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final year = DateTime.now().year;
    if (churchId == null) return const Scaffold(body: Center(child: Text('No active church')));
    final stream = InterchurchService().streamYearProgram(churchId, year);
    return Scaffold(
      appBar: AppBar(title: Text('Year Program $year')),
      body: StreamBuilder<YearProgram>(
        stream: stream,
        builder: (context, snap) {
          final data = snap.data;
          final items = data?.items ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) return const Center(child: Text('No program entries'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final it = items[i];
              return Card(
                child: ListTile(
                  title: Text(it['title']?.toString() ?? ''),
                  subtitle: Text(it['date']?.toString() ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}