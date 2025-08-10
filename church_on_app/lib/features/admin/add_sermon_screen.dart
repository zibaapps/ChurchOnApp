import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/sermon.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/sermons_providers.dart';
import '../../common/services/thumbnail_service.dart';
import '../../common/services/remote_config_service.dart';

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

  bool _isLive = false;
  LivePlatform _platform = LivePlatform.youtube;
  final _liveUrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    final isProLive = RemoteConfigService().proLiveStream;
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
              decoration: const InputDecoration(labelText: 'On-demand Media URL (S3/Storage/MP3/MP4/YouTube)')
            ),
            const Divider(height: 32),
            if (isProLive)
              SwitchListTile.adaptive(
                title: const Text('Live Streaming'),
                value: _isLive,
                onChanged: (v) => setState(() => _isLive = v),
              ),
            if (isProLive && _isLive) ...[
              DropdownButtonFormField<LivePlatform>(
                value: _platform,
                items: const [
                  DropdownMenuItem(value: LivePlatform.youtube, child: Text('YouTube')),
                  DropdownMenuItem(value: LivePlatform.facebook, child: Text('Facebook Live')),
                  DropdownMenuItem(value: LivePlatform.googleMeet, child: Text('Google Meet')),
                  DropdownMenuItem(value: LivePlatform.other, child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _platform = v ?? LivePlatform.youtube),
                decoration: const InputDecoration(labelText: 'Platform'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _liveUrl,
                decoration: const InputDecoration(labelText: 'Live URL'),
                validator: (v) => _isLive && (v == null || v.isEmpty) ? 'Required for live' : null,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: churchId == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final sermon = Sermon(
                        id: 'new',
                        churchId: churchId,
                        title: _title.text.trim(),
                        mediaType: _mediaType,
                        mediaUrl: _mediaUrl.text.trim(),
                        publishedAt: DateTime.now(),
                        isLive: _isLive,
                        livePlatform: _isLive ? _platform : null,
                        liveUrl: _isLive ? _liveUrl.text.trim() : null,
                      );
                      final newId = await ref.read(sermonsServiceProvider).addSermon(churchId, sermon);
                      // Auto-generate thumbnail if missing
                      await ThumbnailService().generateForDoc(
                        churchId: churchId,
                        collection: 'sermons',
                        docId: newId,
                        title: sermon.title,
                      );
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