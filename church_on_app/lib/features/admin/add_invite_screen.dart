import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/invite_card.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/services/invite_service.dart';

class AddInviteScreen extends ConsumerStatefulWidget {
  const AddInviteScreen({super.key});

  @override
  ConsumerState<AddInviteScreen> createState() => _AddInviteScreenState();
}

class _AddInviteScreenState extends ConsumerState<AddInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _message = TextEditingController();
  final _serviceTime = TextEditingController();
  final _location = TextEditingController();
  final _qrData = TextEditingController();
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Invite Card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _message, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Message')), 
            const SizedBox(height: 12),
            SwitchListTile.adaptive(title: const Text('Online Service'), value: _isOnline, onChanged: (v) => setState(() => _isOnline = v)),
            const SizedBox(height: 12),
            TextFormField(controller: _serviceTime, decoration: const InputDecoration(labelText: 'Service Time (e.g., Sun 9:00 AM)')),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Location (if in-person)')),
            const SizedBox(height: 12),
            TextFormField(controller: _qrData, decoration: const InputDecoration(labelText: 'QR / Link Data'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: churchId == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final card = InviteCard(
                        id: 'new',
                        churchId: churchId,
                        title: _title.text.trim(),
                        message: _message.text.trim(),
                        qrData: _qrData.text.trim(),
                        bannerUrl: null,
                        serviceTime: _serviceTime.text.trim(),
                        location: _location.text.trim(),
                        isOnline: _isOnline,
                        createdAt: DateTime.now(),
                      );
                      await InviteService().addInvite(churchId, card);
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