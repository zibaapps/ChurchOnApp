import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/testimony_service.dart';
import '../../common/models/testimony.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';

class TestimoniesScreen extends ConsumerWidget {
  const TestimoniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('Select a church')));
    return Scaffold(
      appBar: AppBar(title: const Text('Testimonies')),
      body: StreamBuilder<List<Testimony>>(
        stream: TestimonyService().streamApproved(churchId),
        builder: (context, snap) {
          final items = snap.data ?? const <Testimony>[];
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = items[i];
              return Card(
                child: ListTile(
                  title: Text(t.title),
                  subtitle: Text(t.body),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.favorite, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text('${t.likes}'),
                    IconButton(icon: const Icon(Icons.thumb_up_alt_outlined), onPressed: () => TestimonyService().like(churchId, t.id)),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = ref.read(currentUserStreamProvider).valueOrNull;
          if (user == null) return;
          final title = TextEditingController();
          final body = TextEditingController();
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Share your testimony'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(controller: body, maxLines: 5, decoration: const InputDecoration(labelText: 'Story')),
              ]),
              actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit'))],
            ),
          );
          if (ok == true && title.text.trim().isNotEmpty) {
            await TestimonyService().submit(
              churchId,
              Testimony(id: 'new', churchId: churchId, userId: user.uid, title: title.text.trim(), body: body.text.trim(), createdAt: DateTime.now()),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}