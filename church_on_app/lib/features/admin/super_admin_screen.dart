import 'package:flutter/material.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('Manage Churches')),
          ListTile(title: Text('Global Analytics')),
          ListTile(title: Text('Track Giving Metrics')),
        ],
      ),
    );
  }
}