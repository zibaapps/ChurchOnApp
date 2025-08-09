import 'package:flutter/material.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible & Resources')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.book), title: Text('Read Bible (Coming Soon)')),
          ListTile(leading: Icon(Icons.headphones), title: Text('Audio Bible (Coming Soon)')),
          ListTile(leading: Icon(Icons.menu_book), title: Text('Study Plans & Devotionals (Coming Soon)')),
          ListTile(leading: Icon(Icons.link), title: Text('External Resources (Coming Soon)')),
        ],
      ),
    );
  }
}