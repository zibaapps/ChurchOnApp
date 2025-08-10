import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/news_providers.dart';
import '../../common/providers/pagination/news_pager.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pager = ref.watch(newsPagerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: Builder(builder: (context) {
        final items = pager.items;
        if (pager.loading && items.isEmpty) return const Center(child: CircularProgressIndicator());
        if (items.isEmpty) return const Center(child: Text('No news'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length + (pager.hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            if (i >= items.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: OutlinedButton(
                    onPressed: () => ref.read(newsPagerProvider.notifier).loadMore(),
                    child: pager.loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load more'),
                  ),
                ),
              );
            }
            final n = items[i];
            return Card(
              child: ListTile(
                title: Text(n.headline),
                subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            );
          },
        );
      }),
    );
  }
}