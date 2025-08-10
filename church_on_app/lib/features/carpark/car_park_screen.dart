import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';

class CarParkScreen extends ConsumerStatefulWidget {
  const CarParkScreen({super.key});

  @override
  ConsumerState<CarParkScreen> createState() => _CarParkScreenState();
}

class _CarParkScreenState extends ConsumerState<CarParkScreen> {
  final _capacity = TextEditingController(text: '100');

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('Select a church')));
    final col = FirebaseFirestore.instance.collection('churches').doc(churchId).collection('carpark');
    return Scaffold(
      appBar: AppBar(title: const Text('Car Park')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Capacity:'),
                const SizedBox(width: 8),
                SizedBox(width: 100, child: TextField(controller: _capacity, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final cap = int.tryParse(_capacity.text.trim()) ?? 0;
                    await col.doc('settings').set({'capacity': cap}, SetOptions(merge: true));
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: col.where('type', isEqualTo: 'assignment').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? const [];
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = docs[i].data();
                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(d['plate']?.toString() ?? ''),
                      subtitle: Text(d['owner']?.toString() ?? ''),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => docs[i].reference.delete()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final plate = TextEditingController();
          final owner = TextEditingController();
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Assign Parking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: plate, decoration: const InputDecoration(labelText: 'Plate Number')),
                  TextField(controller: owner, decoration: const InputDecoration(labelText: 'Owner Name')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Assign')),
              ],
            ),
          );
          if (ok == true) {
            await col.add({'type': 'assignment', 'plate': plate.text.trim(), 'owner': owner.text.trim(), 'createdAt': DateTime.now().toIso8601String()});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}