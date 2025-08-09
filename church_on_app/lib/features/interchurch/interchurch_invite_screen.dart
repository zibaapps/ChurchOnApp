import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/providers/church_directory_providers.dart';
import '../../common/services/interchurch_service.dart';

class InterchurchInviteScreen extends ConsumerStatefulWidget {
  const InterchurchInviteScreen({super.key, required this.activityId});
  final String activityId;

  @override
  ConsumerState<InterchurchInviteScreen> createState() => _InterchurchInviteScreenState();
}

class _InterchurchInviteScreenState extends ConsumerState<InterchurchInviteScreen> {
  final Set<String> _selected = <String>{};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final churches = ref.watch(churchListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Churches')),
      body: churches.when(
        data: (list) {
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];
              final selected = _selected.contains(c.id);
              return CheckboxListTile(
                title: Text(c.name),
                subtitle: c.iconUrl != null ? Text(c.id) : null,
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selected.add(c.id);
                    } else {
                      _selected.remove(c.id);
                    }
                  });
                },
              );
            },
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            icon: _busy ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            label: const Text('Send Invites'),
            onPressed: _busy || _selected.isEmpty
                ? null
                : () async {
                    setState(() => _busy = true);
                    final svc = InterchurchService();
                    for (final ch in _selected) {
                      await svc.updateActivity(widget.activityId, {
                        'participants': FieldValue.arrayUnion([ch]),
                        'participantStatuses.$ch': 'invited',
                      });
                    }
                    if (!mounted) return;
                    setState(() => _busy = false);
                    Navigator.of(context).pop(true);
                  },
          ),
        ),
      ),
    );
  }
}