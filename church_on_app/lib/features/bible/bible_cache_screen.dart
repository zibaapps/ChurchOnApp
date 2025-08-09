import 'package:flutter/material.dart';

import '../../common/services/bible/bible_repository.dart';

class BibleCacheScreen extends StatefulWidget {
  const BibleCacheScreen({super.key});

  @override
  State<BibleCacheScreen> createState() => _BibleCacheScreenState();
}

class _BibleCacheScreenState extends State<BibleCacheScreen> {
  final BibleRepository _repo = BibleRepository();
  final List<String> _books = const ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Psalms', 'John'];
  final String _version = 'web';
  late Future<List<_BookStatus>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_BookStatus>> _load() async {
    final out = <_BookStatus>[];
    for (final b in _books) {
      final has = await _repo.hasBookCached(version: _version, book: b);
      out.add(_BookStatus(book: b, cached: has));
    }
    return out;
  }

  Future<void> _delete(String book) async {
    await _repo.evictBook(version: _version, book: book);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Cache')),
      body: FutureBuilder<List<_BookStatus>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = items[i];
              return ListTile(
                title: Text(s.book),
                trailing: s.cached
                    ? IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(s.book))
                    : const Text('Not cached'),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookStatus {
  const _BookStatus({required this.book, required this.cached});
  final String book;
  final bool cached;
}