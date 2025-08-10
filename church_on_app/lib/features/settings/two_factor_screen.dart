import 'package:flutter/material.dart';

class TwoFactorScreen extends StatelessWidget {
  const TwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.phone_iphone),
            title: Text('SMS-based 2FA (Coming soon)'),
            subtitle: Text('Receive codes via SMS when signing in'),
          ),
          ListTile(
            leading: Icon(Icons.key),
            title: Text('Passkeys / FIDO2 (Coming soon)'),
            subtitle: Text('Use platform passkeys for stronger authentication'),
          ),
          ListTile(
            leading: Icon(Icons.qr_code),
            title: Text('Authenticator App (Coming soon)'),
            subtitle: Text('Scan a QR code with Google Authenticator / Authy'),
          ),
        ],
      ),
    );
  }
}