import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/announcement.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/providers/announcements_providers.dart';

class AddAnnouncementScreen extends ConsumerStatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  ConsumerState<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends ConsumerState<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Announcement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _body,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'Body'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: user == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final a = Announcement(
                        id: 'new',
                        churchId: user.churchId!,
                        title: _title.text.trim(),
                        body: _body.text.trim(),
                        imageUrl: null,
                        publishedAt: DateTime.now(),
                        authorName: user.displayName,
                      );
                      await ref.read(announcementServiceProvider).addAnnouncement(user.churchId!, a);
                      if (mounted) Navigator.of(context).pop();
                    },
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }
}