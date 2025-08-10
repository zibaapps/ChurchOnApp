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
    _Question(prompt: 'Who led the Israelites out of Egypt?', choices: ['Moses', 'David', 'Paul', 'Elijah'], answerIndex: 0),
    _Question(prompt: 'Where was Jesus born?', choices: ['Nazareth', 'Jerusalem', 'Bethlehem', 'Capernaum'], answerIndex: 2),
    _Question(prompt: 'How many books are in the Bible?', choices: ['39', '27', '66', '73'], answerIndex: 2),
    _Question(prompt: 'Who built the ark?', choices: ['Noah', 'Abraham', 'Jacob', 'Solomon'], answerIndex: 0),
    _Question(prompt: 'First miracle of Jesus?', choices: ['Walking on water', 'Feeding 5000', 'Water to wine', 'Healing leper'], answerIndex: 2),
    _Question(prompt: 'Who was swallowed by a great fish?', choices: ['Jonah', 'Job', 'Peter', 'John'], answerIndex: 0),
    _Question(prompt: 'Paul’s original name?', choices: ['Peter', 'Saul', 'John', 'Barnabas'], answerIndex: 1),
    _Question(prompt: 'Where is the Sermon on the Mount?', choices: ['Matthew', 'Mark', 'Luke', 'John'], answerIndex: 0),
    _Question(prompt: 'Who killed Goliath?', choices: ['Saul', 'Samuel', 'David', 'Jonathan'], answerIndex: 2),
    _Question(prompt: 'Fruit of the Spirit count?', choices: ['5', '7', '9', '12'], answerIndex: 2),
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

  void _prev() {
    if (_q > 0) setState(() => _q--);
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
      game: 'quiz',
      score: _score,
      optInGlobal: optIn,
      shareNameGlobal: shareName,
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
    final q = _questions[_q];
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
                    Text(q.prompt, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < q.choices.length; i++)
                          ChoiceChip(
                            label: Text(q.choices[i]),
                            selected: false,
                            onSelected: (_) => _pick(i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: _prev, icon: const Icon(Icons.arrow_back)),
                        const SizedBox(width: 12),
                        Text('${_q + 1} / ${_questions.length}'),
                        const SizedBox(width: 12),
                        IconButton(onPressed: () => _pick(-1), icon: const Icon(Icons.arrow_forward)),
                      ],
                    ),
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