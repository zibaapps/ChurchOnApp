import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/service_issue.dart';
import '../../common/services/service_issue_service.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';

class ServiceIssuesScreen extends ConsumerStatefulWidget {
  const ServiceIssuesScreen({super.key});

  @override
  ConsumerState<ServiceIssuesScreen> createState() => _ServiceIssuesScreenState();
}

class _ServiceIssuesScreenState extends ConsumerState<ServiceIssuesScreen> {
  IssueType _type = IssueType.other;
  IssueSeverity _severity = IssueSeverity.medium;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('In-service Issues')),
      body: churchId == null
          ? const Center(child: Text('Select a church'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                      const SizedBox(height: 8),
                      TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                      const SizedBox(height: 8),
                      TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location (e.g., stage left)')),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField<IssueType>(
                            value: _type,
                            items: IssueType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                            onChanged: (v) => setState(() => _type = v ?? IssueType.other),
                            decoration: const InputDecoration(labelText: 'Type'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<IssueSeverity>(
                            value: _severity,
                            items: IssueSeverity.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                            onChanged: (v) => setState(() => _severity = v ?? IssueSeverity.medium),
                            decoration: const InputDecoration(labelText: 'Severity'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: churchId == null || user == null || _title.text.trim().isEmpty
                              ? null
                              : () async {
                                  final issue = ServiceIssue(
                                    id: 'new',
                                    churchId: churchId!,
                                    title: _title.text.trim(),
                                    description: _desc.text.trim(),
                                    type: _type,
                                    severity: _severity,
                                    status: IssueStatus.open,
                                    createdAt: DateTime.now(),
                                    createdBy: user.uid,
                                    location: _location.text.trim(),
                                  );
                                  await ServiceIssueService().createIssue(churchId, issue);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue submitted')));
                                  _title.clear();
                                  _desc.clear();
                                  _location.clear();
                                },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: churchId == null
                      ? const SizedBox.shrink()
                      : StreamBuilder<List<ServiceIssue>>(
                          stream: ServiceIssueService().streamIssues(churchId),
                          builder: (context, snap) {
                            final items = snap.data ?? const <ServiceIssue>[];
                            if (items.isEmpty) return const Center(child: Text('No issues'));
                            return ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final x = items[i];
                                return ListTile(
                                  title: Text(x.title),
                                  subtitle: Text('${x.type.name} • ${x.severity.name} • ${x.status.name}\n${x.description}'),
                                  isThreeLine: true,
                                  trailing: PopupMenuButton<IssueStatus>(
                                    onSelected: (s) => ServiceIssueService().updateStatus(churchId, x.id, s),
                                    itemBuilder: (context) => IssueStatus.values
                                        .map((s) => PopupMenuItem(value: s, child: Text('Mark ${s.name}')))
                                        .toList(),
                                  ),
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