import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';

class ModerationScreen extends ConsumerStatefulWidget {
  const ModerationScreen({super.key});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen> {
  String? _status; // null = any

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('No active church')));
    final annRef = FirebaseFirestore.instance.collection('churches').doc(churchId).collection('announcements');
    final newsRef = FirebaseFirestore.instance.collection('churches').doc(churchId).collection('news');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              const Text('Status:'),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Any')),
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'published', child: Text('Published')),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
            ]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: (_status == null ? annRef : annRef.where('status', isEqualTo: _status)).orderBy('publishedAt', descending: true).snapshots(),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? const [];
              return Column(children: [
                for (final d in docs)
                  Card(
                    child: ListTile(
                      title: Text(d.data()['title']?.toString() ?? ''),
                      subtitle: Text('Status: ${d.data()['status'] ?? 'unknown'}'),
                      trailing: Wrap(spacing: 8, children: [
                        TextButton(onPressed: () => d.reference.update({'status': 'draft'}), child: const Text('Unpublish')),
                        FilledButton(onPressed: () => d.reference.update({'status': 'published'}), child: const Text('Publish')),
                      ]),
                    ),
                  ),
              ]);
            },
          ),
          const SizedBox(height: 16),
          const Text('News', style: TextStyle(fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: (_status == null ? newsRef : newsRef.where('status', isEqualTo: _status)).orderBy('publishedAt', descending: true).snapshots(),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? const [];
              return Column(children: [
                for (final d in docs)
                  Card(
                    child: ListTile(
                      title: Text(d.data()['headline']?.toString() ?? ''),
                      subtitle: Text('Status: ${d.data()['status'] ?? 'unknown'}'),
                      trailing: Wrap(spacing: 8, children: [
                        TextButton(onPressed: () => d.reference.update({'status': 'draft'}), child: const Text('Unpublish')),
                        FilledButton(onPressed: () => d.reference.update({'status': 'published'}), child: const Text('Publish')),
                      ]),
                    ),
                  ),
              ]);
            },
          ),
        ],
      ),
    );
  }
}