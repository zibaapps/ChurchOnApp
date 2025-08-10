import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/services/billing_service.dart';
import '../../common/models/tenant_billing.dart';

class BillingPanelScreen extends ConsumerWidget {
  const BillingPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Usage')),
      body: churchId == null
          ? const Center(child: Text('Select a church'))
          : FutureBuilder<TenantBilling>(
              future: BillingService().fetch(churchId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final b = snap.data!;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(title: const Text('Plan'), trailing: Chip(label: Text(b.plan.name.toUpperCase()))),
                    const SizedBox(height: 8),
                    _row('Events (month)', '${b.usage.eventsThisMonth}'),
                    _row('Sermons (month)', '${b.usage.sermonsThisMonth}'),
                    _row('Messages (month)', '${b.usage.messagesThisMonth}'),
                    _row('Members', '${b.usage.members}'),
                    _row('Storage (MB)', b.usage.storageMB.toStringAsFixed(0)),
                    if (b.graceUntil != null) _row('Grace until', b.graceUntil!.toLocal().toString()),
                    const Divider(height: 32),
                    Wrap(spacing: 12, children: [
                      FilledButton.tonal(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('churches')
                              .doc(churchId)
                              .collection('tenant_settings')
                              .doc('billing')
                              .set({'plan': TenantPlan.pro.name}, SetOptions(merge: true));
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upgraded to Pro')));
                        },
                        child: const Text('Upgrade'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('churches')
                              .doc(churchId)
                              .collection('tenant_settings')
                              .doc('billing')
                              .set({'plan': TenantPlan.free.name}, SetOptions(merge: true));
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downgraded to Free')));
                        },
                        child: const Text('Downgrade'),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment method management coming soon')));
                        },
                        child: const Text('Manage Payment Method'),
                      ),
                    ]),
                  ],
                );
              },
            ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]),
      );
}