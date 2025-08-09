import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/services/bible/bible_repository.dart';
import '../../common/providers/tenant_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _q = TextEditingController();
  List<_Result> _results = const [];
  bool _loading = false;

  Future<void> _run() async {
    final query = _q.text.trim();
    if (query.isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    final churchId = ref.read(activeChurchIdProvider);

    final out = <_Result>[];

    // Bible (WEB, limited to cached demo books)
    final repo = BibleRepository();
    for (final book in ['Genesis', 'Psalms', 'John']) {
      if (await repo.hasBookCached(version: 'web', book: book)) {
        final data = await repo.getBook(version: 'web', book: book);
        final chapters = (data['chapters'] as List?) ?? const [];
        for (int c = 0; c < chapters.length; c++) {
          final verses = (chapters[c] as List).cast<dynamic>().map((e) => e.toString()).toList();
          for (int v = 0; v < verses.length; v++) {
            final text = verses[v];
            if (text.toLowerCase().contains(query.toLowerCase())) {
              out.add(_Result('Bible: $book ${c + 1}:$v', text));
            }
          }
        }
      }
    }

    // Sermons titles
    if (churchId != null) {
      final sSnap = await FirebaseFirestore.instance.collection('churches').doc(churchId).collection('sermons').limit(50).get();
      for (final d in sSnap.docs) {
        final title = (d.data()['title'] as String?) ?? '';
        if (title.toLowerCase().contains(query.toLowerCase())) {
          out.add(_Result('Sermon', title));
        }
      }
    }

    setState(() {
      _results = out.take(100).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _q, decoration: const InputDecoration(hintText: 'Search Bible, sermons, notes'))),
                const SizedBox(width: 8),
                FilledButton(onPressed: _loading ? null : _run, child: const Text('Go')),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(title: Text(r.title), subtitle: Text(r.snippet));
              },
            ),
          )
        ],
      ),
    );
  }
}

class _Result {
  _Result(this.title, this.snippet);
  final String title;
  final String snippet;
}