import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/sermons_providers.dart';
import '../../common/providers/pagination/sermons_pager.dart';

class SermonsTab extends ConsumerWidget {
  const SermonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pager = ref.watch(sermonsPagerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => context.push('/bible'),
            tooltip: 'Bible & Resources',
          ),
        ],
      ),
      body: Builder(builder: (context) {
        final sermons = pager.items;
        if (pager.loading && sermons.isEmpty) return const Center(child: CircularProgressIndicator());
        if (sermons.isEmpty) return const Center(child: Text('No sermons yet'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: sermons.length + (pager.hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            if (i >= sermons.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: OutlinedButton(
                    onPressed: () => ref.read(sermonsPagerProvider.notifier).loadMore(),
                    child: pager.loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load more'),
                  ),
                ),
              );
            }
            final s = sermons[i];
            final tag = 'sermon_${s.id}';
            return Card(
              child: ListTile(
                leading: Hero(tag: tag, child: const Icon(Icons.play_circle_outline)),
                title: Text(s.title),
                subtitle: Text(s.mediaType.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/sermons/${s.id}', extra: tag),
              ),
            );
          },
        );
      }),
    );
  }
}