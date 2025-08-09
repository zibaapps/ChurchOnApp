import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';

class MembershipAdminScreen extends ConsumerWidget {
  const MembershipAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) return const Scaffold(body: Center(child: Text('No active church')));
    final membersRef = FirebaseFirestore.instance.collection('memberships_index').doc(churchId).collection('members');
    final invitesRef = FirebaseFirestore.instance.collection('churches').doc(churchId).collection('invites');
    final inviteCodeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Membership & Roles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Members', style: TextStyle(fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: membersRef.snapshots(),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? const [];
              return Column(children: [
                for (final d in docs)
                  Card(
                    child: ListTile(
                      title: Text(d.data()['email']?.toString() ?? d.id),
                      subtitle: Text('Role: ${d.data()['role'] ?? 'user'}'),
                      trailing: Wrap(spacing: 8, children: [
                        TextButton(onPressed: () => d.reference.update({'role': 'user'}), child: const Text('User')),
                        TextButton(onPressed: () => d.reference.update({'role': 'admin'}), child: const Text('Admin')),
                        TextButton(onPressed: () => d.reference.update({'role': 'superAdmin'}), child: const Text('Super')),
                      ]),
                    ),
                  ),
              ]);
            },
          ),
          const SizedBox(height: 16),
          const Text('Invite Codes', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            Expanded(child: TextFormField(controller: inviteCodeController, decoration: const InputDecoration(labelText: 'New Invite Code'))),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final code = inviteCodeController.text.trim();
                if (code.isEmpty) return;
                await invitesRef.doc(code).set({'code': code, 'createdAt': DateTime.now().toIso8601String(), 'type': 'membership'});
                inviteCodeController.clear();
              },
              child: const Text('Create'),
            )
          ]),
        ],
      ),
    );
  }
}