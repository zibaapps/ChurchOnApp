import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/sermons_providers.dart';
import '../../common/providers/pagination/sermons_pager.dart';

class SermonsTab extends ConsumerStatefulWidget {
  const SermonsTab({super.key});

  @override
  ConsumerState<SermonsTab> createState() => _SermonsTabState();
}

class _SermonsTabState extends ConsumerState<SermonsTab> {
  String _query = '';
  String _filter = 'all'; // all | audio | video

  @override
  Widget build(BuildContext context) {
    final pager = ref.watch(sermonsPagerProvider);
    final items = pager.items.where((s) {
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty || s.title.toLowerCase().contains(q);
      final matchesType = _filter == 'all' || s.mediaType == _filter;
      return matchesQuery && matchesType;
    }).toList();

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search sermons...', border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('All'), selected: _filter == 'all', onSelected: (_) => setState(() => _filter = 'all')),
                ChoiceChip(label: const Text('Video'), selected: _filter == 'video', onSelected: (_) => setState(() => _filter = 'video')),
                ChoiceChip(label: const Text('Audio'), selected: _filter == 'audio', onSelected: (_) => setState(() => _filter = 'audio')),
              ],
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (pager.loading && items.isEmpty) return const Center(child: CircularProgressIndicator());
              if (items.isEmpty) return const Center(child: Text('No sermons yet'));
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
                          onPressed: () => ref.read(sermonsPagerProvider.notifier).loadMore(),
                          child: pager.loading
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Load more'),
                        ),
                      ),
                    );
                  }
                  final s = items[i];
                  final tag = 'sermon_${s.id}';
                  return Card(
                    child: ListTile(
                      leading: s.thumbnailUrl != null && s.thumbnailUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(s.thumbnailUrl!, width: 56, height: 56, fit: BoxFit.cover),
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Icon(s.mediaType == 'audio' ? Icons.audiotrack : Icons.play_circle, color: Colors.white),
                            ),
                      title: Text(s.title),
                      subtitle: Text(s.mediaType.toUpperCase()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/sermons/${s.id}', extra: tag),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}