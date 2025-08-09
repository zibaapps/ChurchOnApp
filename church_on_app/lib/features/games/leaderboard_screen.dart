import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/services/leaderboard_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    final svc = LeaderboardService();
    final churchStream = churchId == null ? const Stream<List<Map<String, dynamic>>>.empty() : svc.streamChurchTopAggregated(churchId);
    final globalStream = svc.streamGlobalTopAggregated();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(tabs: [Tab(text: 'My Church'), Tab(text: 'Global')]),
        ),
        body: TabBarView(children: [
          _Board(stream: churchStream),
          _Board(stream: globalStream, showOptInHint: user != null),
        ]),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.stream, this.showOptInHint = false});
  final Stream<List<Map<String, dynamic>>> stream;
  final bool showOptInHint;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        final entries = snap.data ?? const <Map<String, dynamic>>[];
        if (entries.isEmpty) {
          return const Center(child: Text('No scores yet'));
        }
        return Column(
          children: [
            if (showOptInHint)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('To appear globally, opt-in when submitting scores in games.'),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = entries[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(e['userName']?.toString() ?? 'User'),
                    subtitle: e['userId'] != null ? Text(e['userId'].toString()) : null,
                    trailing: Text('Total: ${e['total']}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}