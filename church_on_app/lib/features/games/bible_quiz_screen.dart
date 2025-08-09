import 'package:flutter/material.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/services/leaderboard_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BibleQuizScreen extends ConsumerStatefulWidget {
  const BibleQuizScreen({super.key});
  @override
  ConsumerState<BibleQuizScreen> createState() => _BibleQuizScreenState();
}

class _BibleQuizScreenState extends ConsumerState<BibleQuizScreen> {
  int _q = 0;
  int _score = 0;
  bool _done = false;

  final List<_Question> _questions = const [
    _Question(
      prompt: 'Who led the Israelites out of Egypt?',
      choices: ['Moses', 'David', 'Paul', 'Elijah'],
      answerIndex: 0,
    ),
    _Question(
      prompt: 'Where was Jesus born?',
      choices: ['Nazareth', 'Jerusalem', 'Bethlehem', 'Capernaum'],
      answerIndex: 2,
    ),
    _Question(
      prompt: 'How many books are in the Bible?',
      choices: ['39', '27', '66', '73'],
      answerIndex: 2,
    ),
  ];

  void _pick(int idx) {
    if (_done) return;
    if (idx == _questions[_q].answerIndex) {
      _score++;
    }
    if (_q + 1 >= _questions.length) {
      setState(() => _done = true);
    } else {
      setState(() => _q++);
    }
  }

  Future<void> _submitScore() async {
    final churchId = ref.read(activeChurchIdProvider);
    final user = ref.read(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) return;
    bool optIn = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Score'),
        content: StatefulBuilder(
          builder: (context, setState) => CheckboxListTile(
            value: optIn,
            onChanged: (v) => setState(() => optIn = v ?? false),
            title: const Text('Opt-in to Global Leaderboard'),
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
      game: 'quiz',
      score: _score,
      optInGlobal: optIn,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score submitted')));
    }
  }

  void _reset() {
    setState(() {
      _q = 0;
      _score = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Quiz')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _done
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Score: $_score / ${_questions.length}', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _submitScore, child: const Text('Submit Score')),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _reset, child: const Text('Play Again')),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_questions[_q].prompt, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    for (int i = 0; i < _questions[_q].choices.length; i++) ...[
                      SizedBox(
                        width: 280,
                        child: OutlinedButton(
                          onPressed: () => _pick(i),
                          child: Text(_questions[_q].choices[i]),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _Question {
  const _Question({required this.prompt, required this.choices, required this.answerIndex});
  final String prompt;
  final List<String> choices;
  final int answerIndex;
}