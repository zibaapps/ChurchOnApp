import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/services/contacts_service.dart';

class EmergencyContactsScreen extends ConsumerWidget {
  const EmergencyContactsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: Text('Sign in')));
    final svc = ContactsService();
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: svc.streamContacts(user.uid),
        builder: (context, snap) {
          final items = snap.data ?? const <Map<String, dynamic>>[];
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = items[i];
              return ListTile(
                leading: const Icon(Icons.contact_phone),
                title: Text(c['name']?.toString() ?? ''),
                subtitle: Text(c['number']?.toString() ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => ContactsService().deleteContact(user.uid, c['id'] as String),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, String>>(
            context: context,
            builder: (_) => const _AddContactDialog(),
          );
          if (result != null) {
            await ContactsService().addContact(user.uid, name: result['name']!, number: result['number']!);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  const _AddContactDialog();
  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Contact'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _number, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop({'name': _name.text.trim(), 'number': _number.text.trim()}),
          child: const Text('Save'),
        ),
      ],
    );
  }
}