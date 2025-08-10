import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../../common/providers/news_providers.dart';
import '../../common/providers/pagination/news_pager.dart';

final christianNewsFutureProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  try {
    final resp = await http.get(Uri.parse('https://www.christianitytoday.com/ct/rss.xml'));
    if (resp.statusCode != 200) return const [];
    final doc = xml.XmlDocument.parse(resp.body);
    final items = <Map<String, String>>[];
    for (final item in doc.findAllElements('item').take(10)) {
      final title = item.findElements('title').isNotEmpty ? item.findElements('title').first.text : '';
      final link = item.findElements('link').isNotEmpty ? item.findElements('link').first.text : '';
      items.add({'title': title, 'link': link});
    }
    return items;
  } catch (_) {
    return const [];
  }
});

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pager = ref.watch(newsPagerProvider);
    final christian = ref.watch(christianNewsFutureProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: Builder(builder: (context) {
        final items = pager.items;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Your Church News', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (pager.loading && items.isEmpty) const Center(child: CircularProgressIndicator()),
            ...items.map((n) => Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.article, color: Colors.white)),
                    title: Text(n.headline),
                    subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                )),
            if (pager.hasMore)
              Center(
                child: OutlinedButton(
                  onPressed: () => ref.read(newsPagerProvider.notifier).loadMore(),
                  child: pager.loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load more'),
                ),
              ),
            const SizedBox(height: 16),
            Text('Christian News (external)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            christian.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => Column(
                children: list
                    .map(
                      (e) => Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: ListTile(
                          title: Text(e['title'] ?? ''),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => _launch(context, e['link']),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(newsPagerProvider.notifier).loadInitial(),
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  void _launch(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open: $url')));
  }
}