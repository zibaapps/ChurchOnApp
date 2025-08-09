import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/services/chat_service.dart';
import '../../common/models/chat.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.threadId});
  final String threadId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) return const Scaffold(body: Center(child: Text('Login and select church')));
    final stream = ChatService().streamMessages(churchId, widget.threadId);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: stream,
              builder: (context, snap) {
                final items = snap.data ?? const <ChatMessage>[];
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final m = items[i];
                    final isMe = m.senderUid == user.uid;
                    return Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(m.text),
                          ),
                        ),
                        _ReactionRow(
                          messageId: m.id,
                          currentUid: user.uid,
                          churchId: churchId,
                          threadId: widget.threadId,
                          reactions: m.reactions,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.all(12), hintText: 'Message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final txt = _text.text.trim();
                    if (txt.isEmpty) return;
                    final msg = ChatMessage(id: 'new', senderUid: user.uid, text: txt, sentAt: DateTime.now());
                    await ChatService().sendMessage(churchId, widget.threadId, msg);
                    _text.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ReactionRow extends StatelessWidget {
  const _ReactionRow({
    required this.messageId,
    required this.currentUid,
    required this.churchId,
    required this.threadId,
    required this.reactions,
  });

  final String messageId;
  final String currentUid;
  final String churchId;
  final String threadId;
  final Map<String, List<String>> reactions;

  static const List<String> emojis = ['🙏', '🙌', '🎶', '❤️', '🔥', '🕊️'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final e in emojis)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => ChatService().toggleReaction(
                churchId: churchId,
                threadId: threadId,
                messageId: messageId,
                emoji: e,
                uid: currentUid,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e),
                    const SizedBox(width: 4),
                    Text('${(reactions[e] ?? const <String>[]).length}')
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}