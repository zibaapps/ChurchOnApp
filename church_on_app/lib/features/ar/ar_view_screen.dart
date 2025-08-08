import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ArViewScreen extends StatelessWidget {
  const ArViewScreen({super.key, this.modelUrl});

  final String? modelUrl;

  @override
  Widget build(BuildContext context) {
    final url = modelUrl ??
        'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    return Scaffold(
      appBar: AppBar(title: const Text('AR Altar')),
      body: kIsWeb
          ? ModelViewer(
              src: url,
              alt: 'AR Altar',
              ar: true,
              autoRotate: true,
              cameraControls: true,
            )
          : const Center(
              child: Text('AR view is coming soon on mobile devices.'),
            ),
    );
  }
}