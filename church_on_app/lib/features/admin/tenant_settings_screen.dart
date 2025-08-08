import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/services/tenant_settings_service.dart';

class TenantSettingsScreen extends ConsumerStatefulWidget {
  const TenantSettingsScreen({super.key});

  @override
  ConsumerState<TenantSettingsScreen> createState() => _TenantSettingsScreenState();
}

class _TenantSettingsScreenState extends ConsumerState<TenantSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _iconUrl = TextEditingController();
  final _themeColor = TextEditingController();
  final _about = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Settings')),
      body: churchId == null
          ? const Center(child: Text('No active church'))
          : StreamBuilder<Map<String, dynamic>?>(
              stream: TenantSettingsService().streamChurch(churchId),
              builder: (context, snap) {
                final data = snap.data ?? {};
                _name.text = data['name']?.toString() ?? _name.text;
                _iconUrl.text = data['iconUrl']?.toString() ?? _iconUrl.text;
                _themeColor.text = data['themeColor']?.toString() ?? _themeColor.text;
                _about.text = data['about']?.toString() ?? _about.text;
                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'App Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      TextFormField(controller: _iconUrl, decoration: const InputDecoration(labelText: 'Icon URL')),
                      const SizedBox(height: 12),
                      TextFormField(controller: _themeColor, decoration: const InputDecoration(labelText: 'Theme Color (hex)')),
                      const SizedBox(height: 12),
                      TextFormField(controller: _about, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'About / Description')),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          await TenantSettingsService().updateChurch(churchId, {
                            'name': _name.text.trim(),
                            'iconUrl': _iconUrl.text.trim(),
                            'themeColor': _themeColor.text.trim(),
                            'about': _about.text.trim(),
                          });
                          if (mounted) Navigator.of(context).pop();
                        },
                        child: const Text('Save'),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}