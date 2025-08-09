import 'package:flutter/material.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});
  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> with SingleTickerProviderStateMixin {
  final Map<String, List<String>> _bible = const {
    'John': [
      'In the beginning was the Word, and the Word was with God, and the Word was God.',
      'He was with God in the beginning.',
      'Through him all things were made; without him nothing was made that has been made.',
    ],
    'Psalm': [
      'The Lord is my shepherd, I lack nothing.',
      'He makes me lie down in green pastures, he leads me beside quiet waters,',
      'he refreshes my soul.',
    ],
  };
  late TabController _tab;
  String _book = 'John';
  int _chapter = 1;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verses = _bible[_book] ?? const <String>[];
    final filtered = _query.isEmpty
        ? verses
        : verses.where((v) => v.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible & Resources'),
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Read'), Tab(text: 'Resources')]),
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
                      value: _book,
                      items: _bible.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => _book = v ?? 'John'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search in chapter', border: OutlineInputBorder()),
                        onChanged: (v) => setState(() => _query = v),
                      ),
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
                  ),
                ),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('YouVersion (Bible.com)'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _open(context, 'https://www.bible.com'),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Bible Project'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _open(context, 'https://bibleproject.com'),
              ),
              ListTile(
                leading: const Icon(Icons.book_online),
                title: const Text('Blue Letter Bible'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _open(context, 'https://www.blueletterbible.org'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open: $url')));
  }
}