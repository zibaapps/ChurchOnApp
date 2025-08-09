import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/bible/bible_service.dart';
import '../../common/providers/auth_providers.dart';

class ReadingPlansScreen extends ConsumerStatefulWidget {
  const ReadingPlansScreen({super.key});

  @override
  ConsumerState<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends ConsumerState<ReadingPlansScreen> {
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: Text('Sign in to manage plans')));
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Plans')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: BibleService().streamPlans(user.uid),
        builder: (context, snap) {
          final plans = snap.data ?? const <Map<String, dynamic>>[];
          if (plans.isEmpty) return const Center(child: Text('No plans yet'));
          return ListView.separated(
            itemCount: plans.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = plans[i];
              final streak = (p['streak'] as num?)?.toInt() ?? 0;
              return ListTile(
                title: Text(p['name'] as String? ?? 'Plan'),
                subtitle: Text('Streak: $streak days'),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    await BibleService().markPlanDay(user.uid, p['id'] as String, DateTime.now());
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked today complete')));
                  },
                  child: const Text('Done today'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Plan'),
              content: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Plan name')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
              ],
            ),
          );
          if (ok == true && _name.text.trim().isNotEmpty) {
            await BibleService().createPlan(user.uid, name: _name.text.trim());
            _name.clear();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}