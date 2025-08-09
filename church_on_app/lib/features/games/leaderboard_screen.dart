import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/services/leaderboard_service.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  String _timeframe = 'all'; // all | week | month
  String _game = 'all'; // all | quiz | memory | scramble
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    final svc = LeaderboardService();
    final churchStream = churchId == null
        ? const Stream<List<Map<String, dynamic>>>.empty()
        : svc.streamChurchTopAggregated(churchId, game: _game, timeframe: _timeframe);
    final globalStream = svc.streamGlobalTopAggregated(game: _game, timeframe: _timeframe);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'My Church'), Tab(text: 'Global')]),
        actions: [
          PopupMenuButton<String>(
            initialValue: _timeframe,
            onSelected: (v) => setState(() => _timeframe = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('All Time')),
              PopupMenuItem(value: 'week', child: Text('This Week')),
              PopupMenuItem(value: 'month', child: Text('This Month')),
            ],
            icon: const Icon(Icons.filter_alt),
          ),
          PopupMenuButton<String>(
            initialValue: _game,
            onSelected: (v) => setState(() => _game = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('All Games')),
              PopupMenuItem(value: 'quiz', child: Text('Quiz')),
              PopupMenuItem(value: 'memory', child: Text('Memory')),
              PopupMenuItem(value: 'scramble', child: Text('Scramble')),
            ],
            icon: const Icon(Icons.sports_esports),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _Board(stream: churchStream),
          _Board(stream: globalStream, showOptInHint: user != null),
        ],
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