import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/report.dart';
import '../../common/providers/reports_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _types = const [null, ReportType.secretary, ReportType.usher, ReportType.treasurer, ReportType.pastor];
  final _labels = const ['All', 'Secretary', 'Usher', 'Treasurer', 'Pastor'];

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

  @override
  Widget build(BuildContext context) {
    final type = _types[_tabController.index];
    final reports = ref.watch(reportsStreamProvider(type));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: [
          for (final label in _labels) Tab(text: label),
        ]),
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No reports'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = items[i];
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text('${r.type.name} • ${r.createdAt.toLocal()}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}