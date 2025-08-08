import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navTimer;

  void _decideNavigation() {
    final auth = ref.read(currentUserStreamProvider);
    final user = auth.valueOrNull;
    if (user == null) {
      context.go('/onboarding');
      return;
    }
    if (user.churchId == null) {
      context.go('/onboarding/church');
      return;
    }
    context.go('/home');
  }

  @override
  void initState() {
    super.initState();
    // Wait briefly to show branding, then decide route
    _navTimer = Timer(const Duration(milliseconds: 600), () => _decideNavigation());
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.church, size: 96, color: color),
              const SizedBox(height: 16),
              Text('Church On App', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}