import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../common/services/bible/bible_repository.dart';
import '../../common/services/bible/bible_service.dart';
import '../../common/providers/analytics_providers.dart';
import '../../common/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BibleScreen extends ConsumerStatefulWidget {
  const BibleScreen({super.key});
  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final BibleRepository _repo = BibleRepository();
  final List<String> _books = const ['Genesis', 'Psalms', 'John'];
  final List<String> _versions = const ['web']; // try NIV if licensed later

  late TabController _tab;
  String _book = 'John';
  int _chapter = 1;
  String _query = '';
  String _version = 'web';
  bool _downloading = false;
  bool _speaking = false;
  List<String> _verses = const [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadChapter();
  }

  Future<void> _loadChapter() async {
    final has = await _repo.hasBookCached(version: _version, book: _book);
    if (!has) {
      setState(() => _downloading = true);
      await _repo.cacheBook(version: _version, book: _book);
      setState(() => _downloading = false);
    }
    final verses = await _repo.getChapter(version: _version, book: _book, chapter: _chapter);
    setState(() => _verses = verses);
    // analytics
    await ref.read(analyticsServiceProvider).logBibleRead(version: _version, book: _book, chapter: _chapter);
  }

  @override
  void dispose() {
    _tab.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    if (_verses.isEmpty) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    setState(() => _speaking = true);
    await ref.read(analyticsServiceProvider).logBibleTtsPlay(version: _version, book: _book, chapter: _chapter);
    for (final v in _filtered()) {
      if (!_speaking) break;
      await _tts.speak(v);
      await _tts.awaitSpeakCompletion(true);
    }
    setState(() => _speaking = false);
  }

  List<String> _filtered() => _query.isEmpty
      ? _verses
      : _verses.where((v) => v.toLowerCase().contains(_query.toLowerCase())).toList();

  Future<void> _bookmark(int verseIndex) async {
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (user == null) return;
    await BibleService().addBookmark(uid: user.uid, version: _version, book: _book, chapter: _chapter, verse: verseIndex + 1);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmarked')));
  }

  Future<void> _highlight(int verseIndex) async {
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (user == null) return;
    await BibleService().addHighlight(uid: user.uid, version: _version, book: _book, chapter: _chapter, verse: verseIndex + 1, colorHex: '#FFF59D');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Highlighted')));
  }

  Future<void> _note(int verseIndex) async {
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (user == null) return;
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'Your note')), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      await BibleService().addNote(uid: user.uid, version: _version, book: _book, chapter: _chapter, verse: verseIndex + 1, text: controller.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible & Resources'),
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Read'), Tab(text: 'Resources'), Tab(text: 'Plans')]),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _version,
                      items: _versions.map((v) => DropdownMenuItem(value: v, child: Text(v.toUpperCase()))).toList(),
                      onChanged: (v) async {
                        setState(() => _version = v ?? 'web');
                        await _loadChapter();
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _book,
                      items: _books.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) async {
                        setState(() => _book = v ?? 'John');
                        await _loadChapter();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Download book',
                      onPressed: _downloading
                          ? null
                          : () async {
                              setState(() => _downloading = true);
                              await _repo.cacheBook(version: _version, book: _book);
                              setState(() => _downloading = false);
                            },
                      icon: _downloading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download)
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search in chapter', border: OutlineInputBorder()),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: _speaking ? 'Stop' : 'Play',
                      onPressed: _speaking
                          ? () {
                              setState(() => _speaking = false);
                              _tts.stop();
                            }
                          : _speak,
                      icon: Icon(_speaking ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(filtered[i]),
                    trailing: Wrap(spacing: 8, children: [
                      IconButton(tooltip: 'Bookmark', icon: const Icon(Icons.bookmark_add_outlined), onPressed: () => _bookmark(i)),
                      IconButton(tooltip: 'Highlight', icon: const Icon(Icons.border_color_outlined), onPressed: () => _highlight(i)),
                      IconButton(tooltip: 'Note', icon: const Icon(Icons.note_add_outlined), onPressed: () => _note(i)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ListTile(leading: Icon(Icons.menu_book), title: Text('YouVersion (Bible.com)'), trailing: Icon(Icons.open_in_new)),
              ListTile(leading: Icon(Icons.book_online), title: Text('Blue Letter Bible'), trailing: Icon(Icons.open_in_new)),
              ListTile(leading: Icon(Icons.interpreter_mode), title: Text('Greek/Hebrew Tools'), trailing: Icon(Icons.open_in_new)),
              ListTile(leading: Icon(Icons.search), title: Text('Concordance (External)'), trailing: Icon(Icons.open_in_new)),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ListTile(leading: Icon(Icons.today), title: Text('30-day New Testament Plan')),
              ListTile(leading: Icon(Icons.auto_stories), title: Text('Psalms & Proverbs 60-day Plan')),
              ListTile(leading: Icon(Icons.bedtime), title: Text('Daily Devotional: Morning & Evening')),
            ],
          ),
        ],
      ),
    );
  }
}