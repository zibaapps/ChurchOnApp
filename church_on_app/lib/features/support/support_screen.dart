import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _readme = '';
  String _howto = '';
  String _faq = '';
  String _privacy = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final readme = await rootBundle.loadString('assets/docs/README.md');
    final howto = await rootBundle.loadString('assets/docs/HOWTO.md');
    final faq = await rootBundle.loadString('assets/docs/FAQ.md');
    final privacy = await rootBundle.loadString('assets/docs/PRIVACY.md');
    if (!mounted) return;
    setState(() {
      _readme = readme;
      _howto = howto;
      _faq = faq;
      _privacy = privacy;
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Docs'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'How-To'),
            Tab(text: 'FAQ'),
            Tab(text: 'Privacy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          Markdown(data: _readme),
          Markdown(data: _howto),
          Markdown(data: _faq),
          Markdown(data: _privacy),
        ],
      ),
    );
  }
}