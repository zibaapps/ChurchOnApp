import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/upcoming_strip.dart';

class ConnectTab extends StatelessWidget {
  const ConnectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          UpcomingStrip(),
          SizedBox(height: 12),
          _Tile('Chat Rooms', route: '/connect/chat'),
          _Tile('Testimonies', route: '/connect/testimonies'),
          _Tile('Prayer Requests', route: '/connect/prayers'),
          _Tile('Bible Quiz (Games)', route: '/connect/games'),
          _Tile('Memory Match', route: '/connect/games/memory'),
          _Tile('Verse Scramble', route: '/connect/games/scramble'),
          _Tile('Leaderboard', route: '/connect/games/leaderboard'),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.title, {this.route});
  final String title;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: route == null ? null : () => context.go(route!),
      ),
    );
  }
}