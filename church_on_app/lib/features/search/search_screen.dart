import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/services/bible/bible_repository.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _q = TextEditingController();
  List<_Result> _results = const [];
  bool _loading = false;
  List<String> _recent = const [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('searches')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    setState(() => _recent = snap.docs.map((d) => (d.data()['query'] as String?) ?? '').where((q) => q.isNotEmpty).toList());
  }

  Future<void> _saveQuery() async {
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    final q = _q.text.trim();
    if (user == null || q.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('searches').add({
      'query': q,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    await _loadRecent();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved search')));
  }

  Future<void> _clearRecent() async {
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (user == null) return;
    final col = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('searches');
    final snap = await col.get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
    await _loadRecent();
  }

  Future<void> _run() async {
    final query = _q.text.trim();
    if (query.isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    final churchId = ref.read(activeChurchIdProvider);
    final user = ref.read(currentUserStreamProvider).valueOrNull;

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

    // My notes (bible_annotations type note)
    if (user != null) {
      try {
        final notes = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bible_annotations')
            .where('type', isEqualTo: 'note')
            .limit(200)
            .get();
        for (final d in notes.docs) {
          final text = (d.data()['text'] as String?) ?? '';
          if (text.toLowerCase().contains(query.toLowerCase())) {
            out.add(_Result('My Note', text));
          }
        }
      } catch (_) {}
    }

    setState(() {
      _results = out.take(100).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _q, decoration: const InputDecoration(hintText: 'Search Bible, sermons, notes'))),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _loading ? null : _saveQuery, child: const Text('Save')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _loading ? null : _run, child: const Text('Go')),
              ],
            ),
          ),
          if (_recent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final s in _recent)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(s),
                                onPressed: () {
                                  _q.text = s;
                                  _run();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(onPressed: _clearRecent, child: const Text('Clear')),
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