import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _md = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.loadString('assets/docs/PRIVACY.md');
      if (mounted) setState(() => _md = data);
    } catch (_) {
      if (mounted) setState(() => _md = '# Privacy\nContent not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Privacy Policy')), body: Markdown(data: _md));
  }
}