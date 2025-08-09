import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteQrScreen extends StatelessWidget {
  const InviteQrScreen({super.key, required this.data, required this.title});
  final String data;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 240.0,
        ),
      ),
    );
  }
}