import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';

class AnnotationsScreen extends ConsumerStatefulWidget {
  const AnnotationsScreen({super.key});
  @override
  ConsumerState<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends ConsumerState<AnnotationsScreen> {
  String? _type; // note | highlight | bookmark | null
  String _book = 'Any';
  final List<String> _books = const ['Any', 'Genesis', 'Psalms', 'John'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: Text('Sign in')));
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bible_annotations')
        .orderBy('createdAt', descending: true);
    if (_type != null) q = q.where('type', isEqualTo: _type);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Annotations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              const Text('Type:'),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Any')),
                  DropdownMenuItem(value: 'bookmark', child: Text('Bookmark')),
                  DropdownMenuItem(value: 'highlight', child: Text('Highlight')),
                  DropdownMenuItem(value: 'note', child: Text('Note')),
                ],
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(width: 16),
              const Text('Book:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _book,
                items: _books.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _book = v ?? 'Any'),
              ),
            ]),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          final docs = (snap.data?.docs ?? const []).where((d) {
            if (_book == 'Any') return true;
            return (d.data()['book']?.toString() ?? '') == _book;
          }).toList();
          if (docs.isEmpty) return const Center(child: Text('No annotations'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final x = d.data();
              final type = x['type']?.toString() ?? '';
              final ref = '${x['version']} ${x['book']} ${x['chapter']}:${x['verse']}';
              final text = (x['text'] as String?) ?? '';
              return ListTile(
                leading: Icon(type == 'note' ? Icons.note : type == 'highlight' ? Icons.border_color : Icons.bookmark),
                title: Text(ref),
                subtitle: Text(text),
                trailing: IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => d.reference.delete()),
              );
            },
          );
        },
      ),
    );
  }
}