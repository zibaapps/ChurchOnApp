import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/remote_config_service.dart';
import '../games/leaderboard_screen.dart';

class ConnectTab extends ConsumerWidget {
  const ConnectTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rc = RemoteConfigService();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(title: const Text('Chat Rooms'), subtitle: const Text('Join your groups and connect'), leading: const Icon(Icons.forum)),
        if (rc.proGlobalLeaderboard)
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Global Leaderboard'),
              subtitle: const Text('See top scorers globally'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
            ),
          ),
      ],
    );
  }
}