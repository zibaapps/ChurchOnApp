import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/news_providers.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(newsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: news.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No news')); 
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = items[i];
              return Card(
                child: ListTile(
                  title: Text(n.headline),
                  subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              );
            },
          );
        },
      ),
    );
  }
}