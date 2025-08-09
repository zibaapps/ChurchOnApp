import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Placeholder static leaderboard
    final entries = const [
      {'name': 'Mary', 'score': 15},
      {'name': 'John', 'score': 12},
      {'name': 'Paul', 'score': 10},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final e = entries[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(e['name'].toString()),
            trailing: Text('Score: ${e['score']}'),
          );
        },
      ),
    );
  }
}