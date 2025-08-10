import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';

class PrayerRequestsScreen extends ConsumerWidget {
  const PrayerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (churchId == null) return const Scaffold(body: Center(child: Text('Select a church')));
    final col = FirebaseFirestore.instance.collection('churches').doc(churchId).collection('prayers');
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? const [];
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              final mine = data['userId'] == user?.uid;
              final answered = data['answered'] == true;
              return Card(
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(data['body'] ?? ''),
                  trailing: Wrap(spacing: 8, children: [
                    if (answered) const Icon(Icons.check, color: Colors.green),
                    if (mine)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => d.reference.delete(),
                      ),
                    IconButton(
                      icon: Icon(answered ? Icons.undo : Icons.check_circle_outline),
                      onPressed: () => d.reference.update({'answered': !answered}),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (user == null) return;
          final title = TextEditingController();
          final body = TextEditingController();
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Prayer Request'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(controller: body, maxLines: 5, decoration: const InputDecoration(labelText: 'Details')),
              ]),
              actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit'))],
            ),
          );
          if (ok == true && title.text.trim().isNotEmpty) {
            await col.add({
              'userId': user.uid,
              'title': title.text.trim(),
              'body': body.text.trim(),
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'answered': false,
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}