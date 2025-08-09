import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final ads = [
                  {
                    'title': 'National Youth Conference 2025',
                    'imageUrl': 'https://picsum.photos/seed/youth/800/400',
                    'linkUrl': 'https://conference.example',
                    'priority': 1,
                  },
                  {
                    'title': 'Worship Night – Lusaka',
                    'imageUrl': 'https://picsum.photos/seed/worship/800/400',
                    'linkUrl': 'https://worship.example',
                    'priority': 2,
                  },
                  {
                    'title': 'Bible School Intake',
                    'imageUrl': 'https://picsum.photos/seed/bibleschool/800/400',
                    'linkUrl': 'https://bibleschool.example',
                    'priority': 3,
                  },
                  {
                    'title': 'Community Outreach Week',
                    'imageUrl': 'https://picsum.photos/seed/outreach/800/400',
                    'linkUrl': 'https://outreach.example',
                    'priority': 4,
                  },
                ];
                final col = FirebaseFirestore.instance.collection('superadmin_ads');
                for (final ad in ads) {
                  await col.add(ad);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample ads inserted')));
                }
              },
              icon: const Icon(Icons.campaign),
              label: const Text('Seed Sample Ads'),
            ),
          ],
        ),
      ),
    );
  }
}