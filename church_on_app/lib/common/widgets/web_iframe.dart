// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebIFrame extends StatelessWidget {
  const WebIFrame({super.key, required this.url, this.height = 300});
  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return FilledButton(
        onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: const Text('Open Link'),
      );
    }
    final viewType = 'iframe-${url.hashCode}-${height.toInt()}';
    // Register once; runtime ignores duplicates
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..allow = 'autoplay; encrypted-media; picture-in-picture'
        ..allowFullscreen = true;
      return element;
    });
    return SizedBox(
      height: height,
      child: HtmlElementView(viewType: viewType),
    );
  }
}