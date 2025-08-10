import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/news_item.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/news_providers.dart';
import '../../common/services/thumbnail_service.dart';

class AddNewsScreen extends ConsumerStatefulWidget {
  const AddNewsScreen({super.key});

  @override
  ConsumerState<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends ConsumerState<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _headline = TextEditingController();
  final _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add News')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _headline, decoration: const InputDecoration(labelText: 'Headline'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _body, maxLines: 6, decoration: const InputDecoration(labelText: 'Body')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: churchId == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final item = NewsItem(
                        id: 'new',
                        churchId: churchId,
                        headline: _headline.text.trim(),
                        body: _body.text.trim(),
                        publishedAt: DateTime.now(),
                      );
                      final id = await ref.read(newsServiceProvider).addNewsReturnId(churchId, item);
                      await ThumbnailService().generateForDoc(
                        churchId: churchId,
                        collection: 'news',
                        docId: id,
                        title: item.headline,
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