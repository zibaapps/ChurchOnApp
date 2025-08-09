import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/services/chat_service.dart';
import '../../common/models/chat.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) return const Scaffold(body: Center(child: Text('Login and select church')));
    final stream = ChatService().streamThreads(churchId, user.uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<List<ChatThread>>(
        stream: stream,
        builder: (context, snap) {
          final items = snap.data ?? const <ChatThread>[];
          if (items.isEmpty) return const Center(child: Text('No chats'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = items[i];
              return Card(
                child: ListTile(
                  title: Text(t.title),
                  subtitle: Text(t.lastMessage ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed('/chat/${t.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}