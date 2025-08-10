import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});
  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  String _md = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.loadString('assets/docs/HOWTO.md');
      if (mounted) setState(() => _md = data);
    } catch (_) {
      if (mounted) setState(() => _md = '# Terms\nContent not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Terms & Conditions')), body: Markdown(data: _md));
  }
}