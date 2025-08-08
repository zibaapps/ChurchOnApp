import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/report.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/providers/reports_providers.dart';

class AddReportScreen extends ConsumerStatefulWidget {
  const AddReportScreen({super.key});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  ReportType _type = ReportType.secretary;
  DateTime? _start;
  DateTime? _end;

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    setState(() => isStart ? _start = date : _end = date);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ReportType>(
              value: _type,
              items: ReportType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? ReportType.secretary),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _content,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(labelText: 'Content'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('Start: ${_start ?? '-'}')),
                TextButton(onPressed: () => _pickDate(context, true), child: const Text('Pick Start')),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('End: ${_end ?? '-'}')),
                TextButton(onPressed: () => _pickDate(context, false), child: const Text('Pick End')),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: user == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final r = ChurchReport(
                        id: 'new',
                        churchId: user.churchId!,
                        type: _type,
                        title: _title.text.trim(),
                        content: _content.text.trim(),
                        attachmentUrl: null,
                        periodStart: _start,
                        periodEnd: _end,
                        createdAt: DateTime.now(),
                        createdBy: user.uid,
                      );
                      await ref.read(reportsServiceProvider).addReport(user.churchId!, r);
                      if (mounted) Navigator.of(context).pop();
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}