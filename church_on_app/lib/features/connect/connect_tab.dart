import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectTab extends StatelessWidget {
  const ConnectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Tile('Chat Rooms', route: '/connect/chat'),
          _Tile('Testimonies', route: '/connect/testimonies'),
          _Tile('Prayer Requests', route: '/connect/prayers'),
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