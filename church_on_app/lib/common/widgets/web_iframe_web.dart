// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class WebIFrame extends StatelessWidget {
  const WebIFrame({super.key, required this.url, this.height = 300});
  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final viewType = 'iframe-${url.hashCode}-${height.toInt()}';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..allow = 'autoplay; encrypted-media; picture-in-picture'
        ..allowFullscreen = true;
      return element;
    });
    return SizedBox(height: height, child: HtmlElementView(viewType: viewType));
  }
}