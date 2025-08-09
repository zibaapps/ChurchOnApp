import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/services/finance_service.dart';
import '../../common/models/finance.dart';
import '../../common/web/export_csv.dart' if (dart.library.html) '../../common/web/export_csv_web.dart';

class TithesAdminScreen extends ConsumerStatefulWidget {
  const TithesAdminScreen({super.key});
  @override
  ConsumerState<TithesAdminScreen> createState() => _TithesAdminScreenState();
}

class _TithesAdminScreenState extends ConsumerState<TithesAdminScreen> {
  final _userId = TextEditingController();
  DateTime? _from;
  DateTime? _to;

  void _pickFrom() async {
    final d = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
    if (d != null) setState(() => _from = d);
  }

  void _pickTo() async {
    final d = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
    if (d != null) setState(() => _to = d);
  }

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('Select a church')));
    final svc = FinanceService();
    final startIso = _from?.toUtc().toIso8601String();
    final endIso = _to?.toUtc().toIso8601String();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tithes Dashboard (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final list = await svc.streamAllTithes(churchId, startIso: startIso, endIso: endIso).first;
              final filtered = _userId.text.trim().isEmpty ? list : list.where((t) => t.userId == _userId.text.trim()).toList();
              final rows = <List<String>>[
                ['UserId', 'Amount', 'CreatedAt', 'Note'],
                ...filtered.map((t) => [t.userId, t.amount.toStringAsFixed(2), t.createdAt.toIso8601String(), t.note ?? '']),
              ];
              final csv = const ListToCsvConverter().convert(rows);
              final bytes = utf8.encode(csv);
              exportCsv('tithes_admin.csv', bytes);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _userId, decoration: const InputDecoration(labelText: 'Filter by UserId'))),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _pickFrom, child: Text(_from == null ? 'From' : _from!.toIso8601String().split('T').first)),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _pickTo, child: Text(_to == null ? 'To' : _to!.toIso8601String().split('T').first)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TitheRecord>>(
              stream: svc.streamAllTithes(churchId, startIso: startIso, endIso: endIso),
              builder: (context, snap) {
                var items = snap.data ?? const <TitheRecord>[];
                if (_userId.text.trim().isNotEmpty) {
                  items = items.where((t) => t.userId == _userId.text.trim()).toList();
                }
                if (items.isEmpty) return const Center(child: Text('No tithes'));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = items[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('K${t.amount.toStringAsFixed(2)}'),
                      subtitle: Text('User: ${t.userId} • ${t.createdAt.toLocal()}'),
                      trailing: t.note != null ? Text(t.note!) : null,
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}