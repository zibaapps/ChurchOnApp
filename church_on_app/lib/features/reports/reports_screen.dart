import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';

import '../../common/models/report.dart';
import '../../common/providers/reports_providers.dart';
import '../../common/web/export_csv.dart' if (dart.library.html) '../../common/web/export_csv_web.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _types = const [null, ReportType.secretary, ReportType.usher, ReportType.treasurer, ReportType.pastor];
  final _labels = const ['All', 'Secretary', 'Usher', 'Treasurer', 'Pastor'];

  ReportVisibility? _visibilityFilter; // null = any

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportCsv(List<ChurchReport> items) {
    final rows = <List<String>>[
      ['Type', 'Title', 'Visibility', 'AssignedLeaderChurchId', 'PeriodStart', 'PeriodEnd', 'CreatedAt', 'CreatedBy'],
      ...items.map((r) => [
            r.type.name,
            r.title,
            r.visibility.name,
            r.assignedLeaderChurchId ?? '',
            r.periodStart?.toIso8601String() ?? '',
            r.periodEnd?.toIso8601String() ?? '',
            r.createdAt.toIso8601String(),
            r.createdBy ?? '',
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    exportCsv('reports.csv', bytes);
  }

  @override
  Widget build(BuildContext context) {
    final type = _types[_tabController.index];
    final reports = ref.watch(reportsStreamProvider(type));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Column(
            children: [
              TabBar(controller: _tabController, isScrollable: true, tabs: [for (final label in _labels) Tab(text: label)]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Text('Visibility:'),
                    const SizedBox(width: 8),
                    DropdownButton<ReportVisibility?>(
                      value: _visibilityFilter,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Any')),
                        ...ReportVisibility.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                      ],
                      onChanged: (v) => setState(() => _visibilityFilter = v),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        final data = reports.valueOrNull ?? const <ChurchReport>[];
                        final filtered = _applyVisibility(data);
                        _exportCsv(filtered);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final data = _applyVisibility(items);
          if (data.isEmpty) return const Center(child: Text('No reports'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = data[i];
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text('${r.type.name} • ${r.visibility.name} • ${r.createdAt.toLocal()}'),
                  trailing: r.assignedLeaderChurchId == null
                      ? null
                      : Chip(avatar: const Icon(Icons.account_balance), label: Text('Leader: ${r.assignedLeaderChurchId}')),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<ChurchReport> _applyVisibility(List<ChurchReport> items) {
    if (_visibilityFilter == null) return items;
    return items.where((r) => r.visibility == _visibilityFilter).toList();
  }
}