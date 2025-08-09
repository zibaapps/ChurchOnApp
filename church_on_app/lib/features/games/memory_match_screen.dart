import 'dart:math';
import 'package:flutter/material.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});
  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late List<_CardItem> _cards;
  _CardItem? _first;
  int _matches = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final verses = [
      'John 3:16',
      'Psalm 23:1',
      'Philippians 4:13',
      'Romans 8:28',
    ];
    _cards = [
      for (final v in verses) _CardItem(v, false),
      for (final v in verses) _CardItem(v, false),
    ]..shuffle(Random());
    _first = null;
    _matches = 0;
    _busy = false;
    setState(() {});
  }

  void _tap(int i) async {
    if (_busy || _cards[i].revealed) return;
    setState(() => _cards[i] = _cards[i].reveal());
    if (_first == null) {
      _first = _cards[i];
    } else {
      if (_first!.text == _cards[i].text) {
        _matches++;
        _first = null;
        if (_matches == _cards.length ~/ 2) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All matched!')));
        }
      } else {
        _busy = true;
        await Future.delayed(const Duration(seconds: 1));
        final idxFirst = _cards.indexWhere((c) => c == _first);
        setState(() {
          _cards[i] = _cards[i].hide();
          if (idxFirst >= 0) _cards[idxFirst] = _cards[idxFirst].hide();
          _first = null;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Verse Match'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
      ]),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
        itemCount: _cards.length,
        itemBuilder: (context, i) {
          final c = _cards[i];
          return InkWell(
            onTap: () => _tap(i),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(c.revealed ? c.text : '?', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardItem {
  const _CardItem(this.text, this.revealed);
  final String text;
  final bool revealed;
  _CardItem reveal() => _CardItem(text, true);
  _CardItem hide() => _CardItem(text, false);
}