import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';

class AnnotationsScreen extends ConsumerWidget {
  const AnnotationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: Text('Sign in')));
    final col = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('bible_annotations').orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(title: const Text('My Annotations')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) return const Center(child: Text('No annotations yet'));
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