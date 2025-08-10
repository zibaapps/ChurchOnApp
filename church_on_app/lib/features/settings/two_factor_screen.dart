import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  bool _smsEnabled = false;
  bool _passkeysEnabled = false;
  bool _authAppEnabled = false;
  final TextEditingController _phone = TextEditingController();
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Sign in to manage 2FA')));
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('security').doc('twofactor');

    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? const {};
          if (!_loaded && snap.hasData) {
            _smsEnabled = (data['sms'] as bool?) ?? false;
            _passkeysEnabled = (data['passkeys'] as bool?) ?? false;
            _authAppEnabled = (data['authApp'] as bool?) ?? false;
            _phone.text = (data['phone'] as String?) ?? _phone.text;
            _loaded = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile.adaptive(
                value: _smsEnabled,
                onChanged: (v) => setState(() => _smsEnabled = v),
                title: const Text('SMS-based 2FA'),
                subtitle: const Text('Receive codes via SMS when signing in'),
              ),
              if (_smsEnabled)
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number for 2FA'),
                ),
              const Divider(height: 32),
              SwitchListTile.adaptive(
                value: _passkeysEnabled,
                onChanged: (v) => setState(() => _passkeysEnabled = v),
                title: const Text('Passkeys / FIDO2'),
                subtitle: const Text('Use platform passkeys for stronger authentication'),
              ),
              const Divider(height: 32),
              SwitchListTile.adaptive(
                value: _authAppEnabled,
                onChanged: (v) => setState(() => _authAppEnabled = v),
                title: const Text('Authenticator App'),
                subtitle: const Text('Use Google Authenticator / Authy with a time-based code'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await docRef.set({
                    'sms': _smsEnabled,
                    'phone': _smsEnabled ? _phone.text.trim() : null,
                    'passkeys': _passkeysEnabled,
                    'authApp': _authAppEnabled,
                    'updatedAt': DateTime.now().toUtc().toIso8601String(),
                  }, SetOptions(merge: true));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2FA settings saved')));
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}