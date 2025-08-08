import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/sermons_providers.dart';

class SermonsTab extends ConsumerWidget {
  const SermonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(sermonsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sermons')),
      body: sermonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sermons) {
          if (sermons.isEmpty) return const Center(child: Text('No sermons yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sermons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = sermons[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(s.title),
                  subtitle: Text(s.mediaType.toUpperCase()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/sermons/${s.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}