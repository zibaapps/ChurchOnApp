import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import '../../common/web/export_csv.dart' if (dart.library.html) '../../common/web/export_csv_web.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/services/finance_service.dart';
import '../../common/models/finance.dart';
import '../payments/payment_screen.dart';
import '../../common/widgets/animations.dart';

class GiveTab extends ConsumerStatefulWidget {
  const GiveTab({super.key});

  @override
  ConsumerState<GiveTab> createState() => _GiveTabState();
}

class _GiveTabState extends ConsumerState<GiveTab> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give'),
        bottom: TabBar(controller: _tab, tabs: const [
          Tab(text: 'Contribute'),
          Tab(text: 'Tithes'),
          Tab(text: 'Payments'),
        ]),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _ContributionPoolsTab(),
          _TithesTab(),
          _PaymentsTab(),
        ],
      ),
    );
  }
}

class _ContributionPoolsTab extends ConsumerWidget {
  const _ContributionPoolsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Center(child: Text('Select a church'));
    final svc = FinanceService();
    return StreamBuilder<List<ContributionPool>>(
      stream: svc.streamPools(churchId),
      builder: (context, snap) {
        final items = snap.data ?? const <ContributionPool>[];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      await showDialog(context: context, builder: (_) => _CreatePoolDialog(churchId: churchId));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Pool'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = items[i];
                  final progress = p.targetAmount <= 0 ? 0.0 : (p.currentAmount / p.targetAmount).clamp(0, 1);
                  return Card(
                    child: ListTile(
                      title: Text(p.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.description != null) Text(p.description!),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress.toDouble()),
                          const SizedBox(height: 4),
                          Text('K${p.currentAmount.toStringAsFixed(2)} / K${p.targetAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.volunteer_activism),
                        onPressed: () async {
                          final amount = await showDialog<double>(context: context, builder: (_) => const _AmountDialog());
                          if (amount != null && amount > 0) {
                            await FinanceService().contribute(churchId, p.id, amount);
                            final user = ref.read(currentUserStreamProvider).valueOrNull;
                            if (user != null) {
                              await FinanceService().addContributor(churchId, p.id, userId: user.uid, amount: amount);
                            }
                            if (context.mounted) await showSuccessAnimation(context, message: 'Thank you for contributing!');
                          }
                        },
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PoolDetailScreen(churchId: churchId, pool: p))),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CreatePoolDialog extends StatefulWidget {
  const _CreatePoolDialog({required this.churchId});
  final String churchId;
  @override
  State<_CreatePoolDialog> createState() => _CreatePoolDialogState();
}

class _CreatePoolDialogState extends State<_CreatePoolDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _target = TextEditingController();
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Contribution Pool'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _target, decoration: const InputDecoration(labelText: 'Target Amount (ZMW)'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  final pool = ContributionPool(
                    id: const Uuid().v4(),
                    churchId: widget.churchId,
                    title: _title.text.trim(),
                    description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                    targetAmount: double.tryParse(_target.text) ?? 0,
                  );
                  await FinanceService().createPool(widget.churchId, pool);
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: _busy ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create'),
        ),
      ],
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog();
  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _amount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter amount (ZMW)'),
      content: TextField(controller: _amount, keyboardType: TextInputType.number),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(double.tryParse(_amount.text) ?? 0), child: const Text('OK')),
      ],
    );
  }
}

class _TithesTab extends ConsumerWidget {
  const _TithesTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) return const Center(child: Text('Sign in'));
    final svc = FinanceService();
    return StreamBuilder<List<TitheRecord>>(
      stream: svc.streamMyTithes(churchId, user.uid),
      builder: (context, snap) {
        final items = snap.data ?? const <TitheRecord>[];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      await showDialog(context: context, builder: (_) => _AddTitheDialog(churchId: churchId, userId: user.uid));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tithe (Admin only)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final rows = <List<String>>[
                        ['Amount', 'CreatedAt', 'Note'],
                        ...items.map((t) => [
                              t.amount.toStringAsFixed(2),
                              t.createdAt.toIso8601String(),
                              t.note ?? '',
                            ]),
                      ];
                      final csv = const ListToCsvConverter().convert(rows);
                      final bytes = utf8.encode(csv);
                      exportCsv('my_tithes.csv', bytes);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final t = items[i];
                  return Card(
                    child: ListTile(
                      title: Text('K${t.amount.toStringAsFixed(2)}'),
                      subtitle: Text(t.createdAt.toLocal().toString()),
                      trailing: t.note != null ? Text(t.note!) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddTitheDialog extends StatefulWidget {
  const _AddTitheDialog({required this.churchId, required this.userId});
  final String churchId;
  final String userId;
  @override
  State<_AddTitheDialog> createState() => _AddTitheDialogState();
}

class _AddTitheDialogState extends State<_AddTitheDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add/Edit Tithe'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (ZMW)')),
            TextField(controller: _note, decoration: const InputDecoration(labelText: 'Note (optional)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  final tithe = TitheRecord(
                    id: const Uuid().v4(),
                    churchId: widget.churchId,
                    userId: widget.userId,
                    amount: double.tryParse(_amount.text) ?? 0,
                    createdAt: DateTime.now(),
                    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  );
                  await FinanceService().addOrEditTithe(widget.churchId, tithe);
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: _busy ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
        ),
      ],
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentScreen())),
        icon: const Icon(Icons.payments),
        label: const Text('Open Payments'),
      ),
    );
  }
}

class _PoolDetailScreen extends ConsumerWidget {
  const _PoolDetailScreen({required this.churchId, required this.pool});
  final String churchId;
  final ContributionPool pool;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = FinanceService();
    final progress = pool.targetAmount <= 0 ? 0.0 : (pool.currentAmount / pool.targetAmount).clamp(0, 1).toDouble();
    return Scaffold(
      appBar: AppBar(title: Text(pool.title), actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            final msg = 'Support ${pool.title}: K${pool.currentAmount.toStringAsFixed(2)} / K${pool.targetAmount.toStringAsFixed(2)}';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share: $msg')));
          },
        ),
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pool.description != null) Text(pool.description!),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 4),
                Text('K${pool.currentAmount.toStringAsFixed(2)} / K${pool.targetAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text('Contributors', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: svc.streamContributors(churchId, pool.id),
              builder: (context, snap) {
                final items = snap.data ?? const <Map<String, dynamic>>[];
                if (items.isEmpty) return const Center(child: Text('No contributions yet'));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = items[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('K${(c['amount'] as num).toStringAsFixed(2)}'),
                      subtitle: Text('User: ${c['userId']} • ${(c['createdAt'] as String?)?.split('T').first ?? ''}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}