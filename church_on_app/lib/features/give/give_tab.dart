import 'package:flutter/material.dart';

class GiveTab extends StatelessWidget {
  const GiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Give')),
      body: const Center(child: Text('MoMo, PayPal, Offline giving')),
    );
  }
}