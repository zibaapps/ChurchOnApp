import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/announcements_providers.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anns = ref.watch(announcementsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: anns.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No announcements'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                child: ListTile(
                  title: Text(a.title),
                  subtitle: Text(a.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              );
            },
          );
        },
      ),
    );
  }
}