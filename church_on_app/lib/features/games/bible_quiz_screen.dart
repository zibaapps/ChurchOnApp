import 'package:flutter/material.dart';

class BibleQuizScreen extends StatefulWidget {
  const BibleQuizScreen({super.key});
  @override
  State<BibleQuizScreen> createState() => _BibleQuizScreenState();
}

class _BibleQuizScreenState extends State<BibleQuizScreen> {
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
                    FilledButton(onPressed: _reset, child: const Text('Play Again')),
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