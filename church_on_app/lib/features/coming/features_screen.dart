import 'package:flutter/material.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ['Car Park', 'Assign parking teams, track capacity, print QR permits, attendants check-in.'],
      ['Bible School', 'Classes, lecturers, attendance, grades, fees, and graduation tracking.'],
      ['Asset Registry', 'Track church assets, maintenance schedules, depreciation, custodians.'],
      ['Volunteers', 'Roster planning, availability, training, certifications.'],
      ['Follow-up', 'First-timers, pastoral care, visitations, outcomes.'],
      ['Library', 'Catalog, borrow/return, late fees, digital PDFs and audio.'],
      ['Child Check-In', 'Secure check-in/out, guardians, labels, SMS alerts.'],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Coming Soon')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.upcoming_outlined),
            title: Text(items[i][0]),
            subtitle: Text(items[i][1]),
            trailing: const Chip(label: Text('Planned')),
          ),
        ),
      ),
    );
  }
}