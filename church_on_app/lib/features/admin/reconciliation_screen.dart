import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';

class ReconciliationScreen extends ConsumerStatefulWidget {
  const ReconciliationScreen({super.key});
  @override
  ConsumerState<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends ConsumerState<ReconciliationScreen> {
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('Select a church')));
    final query = FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId)
        .collection('payments')
        .orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
                initialDateRange: _range,
              );
              if (picked != null) setState(() => _range = picked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy CSV',
            onPressed: () async {
              final snap = await query.get();
              final rows = <String>['reference,createdAt,method,amount,fee,net,status'];
              for (final d in snap.docs) {
                final data = d.data();
                final created = data['createdAt']?.toString() ?? '';
                final dt = DateTime.tryParse(created)?.toLocal();
                if (_range != null && dt != null) {
                  if (dt.isBefore(_range!.start) || dt.isAfter(_range!.end)) continue;
                }
                rows.add('${data['reference']},$created,${data['method']},${data['amount']},${data['fee']},${data['netAmount']},${data['status']}');
              }
              await Clipboard.setData(ClipboardData(text: rows.join('\n')));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied')));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? const [];
          double total = 0, fees = 0, net = 0;
          int count = 0;
          for (final d in docs) {
            final data = d.data();
            final created = data['createdAt']?.toString() ?? '';
            final dt = DateTime.tryParse(created)?.toLocal();
            if (_range != null && dt != null) {
              if (dt.isBefore(_range!.start) || dt.isAfter(_range!.end)) continue;
            }
            count++;
            total += (data['amount'] as num?)?.toDouble() ?? 0;
            fees += (data['fee'] as num?)?.toDouble() ?? 0;
            net += (data['netAmount'] as num?)?.toDouble() ?? 0;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('Transactions'), trailing: Text('$count')),
              ListTile(title: const Text('Total Amount'), trailing: Text('K${total.toStringAsFixed(2)}')),
              ListTile(title: const Text('Total Fees'), trailing: Text('K${fees.toStringAsFixed(2)}')),
              ListTile(title: const Text('Net to Church'), trailing: Text('K${net.toStringAsFixed(2)}')),
              const Divider(height: 32),
              ...docs.map((d) {
                final x = d.data();
                return ListTile(
                  title: Text('K${(x['amount'] as num).toStringAsFixed(2)} • ${x['method']}'),
                  subtitle: Text('Ref: ${x['reference']} • ${x['status']}\n${x['createdAt']}'),
                );
              })
            ],
          );
        },
      ),
    );
  }
}