import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/services/leaderboard_service.dart';

class VerseScrambleScreen extends ConsumerStatefulWidget {
  const VerseScrambleScreen({super.key});
  @override
  ConsumerState<VerseScrambleScreen> createState() => _VerseScrambleScreenState();
}

class _VerseScrambleScreenState extends ConsumerState<VerseScrambleScreen> {
  final _controller = TextEditingController();
  final _verses = const [
    'God is love',
    'The Lord is my shepherd',
    'I can do all things',
    'Trust in the Lord',
    'In the beginning God created',
    'Be strong and courageous',
    'Seek first the kingdom of God',
    'Jesus wept',
    'Love your neighbor as yourself',
  ];
  late String _target;
  late String _scrambled;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    final v = _verses[Random().nextInt(_verses.length)];
    _target = v.toLowerCase();
    final parts = v.split(' ');
    parts.shuffle();
    _scrambled = parts.join(' ');
    _controller.clear();
    setState(() {});
  }

  Future<void> _submitScore() async {
    final churchId = ref.read(activeChurchIdProvider);
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) return;
    bool optIn = false;
    bool shareName = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Score'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                value: optIn,
                onChanged: (v) => setState(() => optIn = v ?? false),
                title: const Text('Opt-in to Global Leaderboard'),
              ),
              if (optIn)
                SwitchListTile(
                  value: shareName,
                  onChanged: (v) => setState(() => shareName = v),
                  title: const Text('Show my name globally (otherwise Anonymous)'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Submit')),
        ],
      ),
    );
    await LeaderboardService().submitScore(
      churchId: churchId,
      userId: user.uid,
      userName: user.displayName ?? 'User',
      game: 'scramble',
      score: _score,
      optInGlobal: optIn,
      shareNameGlobal: shareName,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score submitted')));
    }
  }

  void _check() async {
    if (_controller.text.trim().toLowerCase() == _target) {
      _score++;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correct!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Try again')));
    }
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verse Scramble (Score: $_score)'), actions: [
        IconButton(icon: const Icon(Icons.emoji_events_outlined), onPressed: _submitScore),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Text(_scrambled, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Type the verse in order', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: FilledButton(onPressed: _check, child: const Text('Submit'))),
                const SizedBox(width: 12),
                IconButton(onPressed: _next, icon: const Icon(Icons.arrow_forward)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}