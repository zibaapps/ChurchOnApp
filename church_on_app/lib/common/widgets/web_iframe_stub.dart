import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebIFrame extends StatelessWidget {
  const WebIFrame({super.key, required this.url, this.height = 300});
  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: const Text('Open Link'),
    );
  }
}