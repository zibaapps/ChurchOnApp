import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/sermon.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/providers/sermons_providers.dart';

class AddSermonScreen extends ConsumerStatefulWidget {
  const AddSermonScreen({super.key});

  @override
  ConsumerState<AddSermonScreen> createState() => _AddSermonScreenState();
}

class _AddSermonScreenState extends ConsumerState<AddSermonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _mediaUrl = TextEditingController();
  String _mediaType = 'video';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Sermon')),
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
            DropdownButtonFormField<String>(
              value: _mediaType,
              items: const [
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
              ],
              onChanged: (v) => setState(() => _mediaType = v ?? 'video'),
              decoration: const InputDecoration(labelText: 'Media Type'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mediaUrl,
              decoration: const InputDecoration(labelText: 'Media URL'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: user == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final sermon = Sermon(
                        id: 'new',
                        churchId: user.churchId!,
                        title: _title.text.trim(),
                        mediaType: _mediaType,
                        mediaUrl: _mediaUrl.text.trim(),
                        publishedAt: DateTime.now(),
                      );
                      await ref.read(sermonsServiceProvider).addSermon(user.churchId!, sermon);
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