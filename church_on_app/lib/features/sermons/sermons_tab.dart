import 'package:flutter/material.dart';

class SermonsTab extends StatelessWidget {
  const SermonsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sermons')),
      body: const Center(child: Text('Audio/Video playback, categories, offline downloads')),
    );
  }
}