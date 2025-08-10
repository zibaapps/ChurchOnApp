import 'dart:math';
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
  int _score = 0;
  int _streak = 0;
  int _questionIndex = 0;
  late List<_Question> _deck;
  final Random _rng = Random();

  final List<_Question> _bank = const [
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
    _Question(prompt: 'Who was thrown into the lions’ den?', choices: ['Daniel', 'Jeremiah', 'Nehemiah', 'Ezekiel'], answerIndex: 0),
    _Question(prompt: 'Which apostle doubted Jesus after resurrection?', choices: ['Peter', 'John', 'Thomas', 'James'], answerIndex: 2),
    _Question(prompt: 'What is the last book of the Bible?', choices: ['Jude', 'Revelation', 'Acts', 'Hebrews'], answerIndex: 1),
    _Question(prompt: 'What is the first commandment?', choices: ['No idols', 'Keep Sabbath', 'Love God only', 'Do not kill'], answerIndex: 2),
  ];

  @override
  void initState() {
    super.initState();
    _reshuffleDeck();
  }

  void _reshuffleDeck() {
    _deck = List<_Question>.from(_bank)..shuffle(_rng);
    _questionIndex = 0;
  }

  void _pick(int idx) {
    final q = _deck[_questionIndex];
    final correct = idx == q.answerIndex;
    setState(() {
      if (correct) {
        _score += 10;
        _streak += 1;
      } else {
        _streak = 0;
      }
      _questionIndex += 1;
      if (_questionIndex >= _deck.length) {
        _reshuffleDeck();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final q = _deck[_questionIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Quiz')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Score: $_score'),
                const SizedBox(width: 16),
                Text('Streak: $_streak')
              ]),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _submitScore, child: const Text('Submit Score')),
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