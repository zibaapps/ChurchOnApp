import 'package:flutter/material.dart';

class BillingPanelScreen extends StatelessWidget {
  const BillingPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: Pro', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Monthly Usage: 12,340 requests'),
            const SizedBox(height: 16),
            FilledButton(onPressed: () {}, child: const Text('Pay Invoice')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () {}, child: const Text('Add Custom Domain')),
          ],
        ),
      ),
    );
  }
}