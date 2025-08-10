import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../common/services/seed_service.dart';

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
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await SeedService().seedDummyTenants();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dummy tenants created')));
                }
              },
              icon: const Icon(Icons.church),
              label: const Text('Seed Dummy Tenants'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await showDialog(context: context, builder: (_) => const _CreateTenantDialog());
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Create Tenant'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTenantDialog extends StatefulWidget {
  const _CreateTenantDialog();
  @override
  State<_CreateTenantDialog> createState() => _CreateTenantDialogState();
}

class _CreateTenantDialogState extends State<_CreateTenantDialog> {
  final _id = TextEditingController();
  final _name = TextEditingController();
  final _domain = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Tenant'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _id, decoration: const InputDecoration(labelText: 'Tenant ID (e.g., my_church)')),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display Name')),
            const SizedBox(height: 8),
            TextField(controller: _domain, decoration: const InputDecoration(labelText: 'Custom Domain (optional)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final id = _id.text.trim();
            final name = _name.text.trim().isEmpty ? id : _name.text.trim();
            final domain = _domain.text.trim();
            if (id.isEmpty) return;
            final fs = FirebaseFirestore.instance;
            await fs.collection('churches').doc(id).set({
              'id': id,
              'name': name,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            }, SetOptions(merge: true));
            if (domain.isNotEmpty) {
              await fs.collection('domain_map').doc(domain).set({'churchId': id});
            }
            await fs.collection('churches').doc(id).collection('tenant_settings').doc('billing').set({'plan': 'free'});
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tenant created')));
          },
          child: const Text('Create'),
        )
      ],
    );
  }
}