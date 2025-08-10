import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectTab extends StatelessWidget {
  const ConnectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _CardTile(icon: Icons.forum, label: 'Chat Rooms', route: '/connect/chat', color: Colors.indigo),
          _CardTile(icon: Icons.volunteer_activism, label: 'Testimonies', route: '/connect/testimonies', color: Colors.green),
          _CardTile(icon: Icons.hail, label: 'Prayer Requests', route: '/connect/prayers', color: Colors.purple),
          _CardTile(icon: Icons.sports_esports, label: 'Bible Quiz', route: '/connect/games', color: Colors.orange),
          _CardTile(icon: Icons.extension, label: 'Memory Match', route: '/connect/games/memory', color: Colors.teal),
          _CardTile(icon: Icons.shuffle, label: 'Verse Scramble', route: '/connect/games/scramble', color: Colors.pink),
          _CardTile(icon: Icons.emoji_events, label: 'Leaderboard', route: '/connect/games/leaderboard', color: Colors.blue),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.icon, required this.label, required this.route, required this.color});
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.15),
      child: InkWell(
        onTap: () => context.go(route),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}