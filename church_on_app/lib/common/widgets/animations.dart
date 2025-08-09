import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showSuccessAnimation(BuildContext context, {String message = 'Done'}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 140, width: 140, child: _SuccessLottie()),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      ),
    ),
  );
}

class _SuccessLottie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/success.json',
      repeat: false,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.check_circle, size: 96, color: Colors.green),
    );
  }
}