import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/animations.dart';
import '../../common/widgets/app_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 96),
            const SizedBox(height: 16),
            Text('Welcome to Church On App', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login / Register'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await showSuccessAnimation(context, message: 'Onboarding complete');
                if (context.mounted) context.go('/home');
              },
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}