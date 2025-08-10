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
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => _PaymentPrefsDialog(churchId: churchId),
                          );
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

class _PaymentPrefsDialog extends StatefulWidget {
  const _PaymentPrefsDialog({required this.churchId});
  final String churchId;
  @override
  State<_PaymentPrefsDialog> createState() => _PaymentPrefsDialogState();
}

class _PaymentPrefsDialogState extends State<_PaymentPrefsDialog> {
  final TextEditingController _payerName = TextEditingController();
  final TextEditingController _payerEmail = TextEditingController();
  String _defaultMethod = 'mtn';
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final doc = FirebaseFirestore.instance
        .collection('churches')
        .doc(widget.churchId)
        .collection('tenant_settings')
        .doc('payment_prefs');

    return AlertDialog(
      title: const Text('Payment Preferences'),
      content: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? const {};
          if (!_loaded && snap.hasData) {
            _payerName.text = (data['payerName'] as String?) ?? '';
            _payerEmail.text = (data['payerEmail'] as String?) ?? '';
            _defaultMethod = (data['defaultMethod'] as String?) ?? 'mtn';
            _loaded = true;
          }
          return SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _payerName, decoration: const InputDecoration(labelText: 'Payer Name')),
                const SizedBox(height: 8),
                TextField(controller: _payerEmail, decoration: const InputDecoration(labelText: 'Payer Email')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _defaultMethod,
                  items: const [
                    DropdownMenuItem(value: 'mtn', child: Text('MTN MoMo')),
                    DropdownMenuItem(value: 'airtel', child: Text('Airtel Money')),
                    DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
                  ],
                  onChanged: (v) => setState(() => _defaultMethod = v ?? 'mtn'),
                  decoration: const InputDecoration(labelText: 'Default Method'),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            await doc.set({
              'payerName': _payerName.text.trim(),
              'payerEmail': _payerEmail.text.trim(),
              'defaultMethod': _defaultMethod,
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            }, SetOptions(merge: true));
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment preferences saved')));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}