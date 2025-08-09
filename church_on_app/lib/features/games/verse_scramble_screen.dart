import 'dart:math';
import 'package:flutter/material.dart';

class VerseScrambleScreen extends StatefulWidget {
  const VerseScrambleScreen({super.key});
  @override
  State<VerseScrambleScreen> createState() => _VerseScrambleScreenState();
}

class _VerseScrambleScreenState extends State<VerseScrambleScreen> {
  final _controller = TextEditingController();
  final _verses = const [
    'God is love',
    'The Lord is my shepherd',
    'I can do all things',
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

  void _check() {
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
      appBar: AppBar(title: Text('Verse Scramble (Score: $_score)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_scrambled, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Type the verse in order')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _check, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}