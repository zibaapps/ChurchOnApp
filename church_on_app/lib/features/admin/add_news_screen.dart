import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/news_item.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/providers/news_providers.dart';

class AddNewsScreen extends ConsumerStatefulWidget {
  const AddNewsScreen({super.key});

  @override
  ConsumerState<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends ConsumerState<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _headline = TextEditingController();
  final _body = TextEditingController();
  final _source = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Add News')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _headline,
              decoration: const InputDecoration(labelText: 'Headline'),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _source,
              decoration: const InputDecoration(labelText: 'Source (optional)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: user == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final n = NewsItem(
                        id: 'new',
                        churchId: user.churchId!,
                        headline: _headline.text.trim(),
                        body: _body.text.trim(),
                        imageUrl: null,
                        publishedAt: DateTime.now(),
                        source: _source.text.trim().isEmpty ? null : _source.text.trim(),
                      );
                      await ref.read(newsServiceProvider).addNews(user.churchId!, n);
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