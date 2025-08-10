import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/providers/tenant_info_providers.dart';
import '../../common/widgets/app_logo.dart';

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
    final name = ref.watch(tenantDisplayNameProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use local asset logo if present, otherwise fall back to tenant icon URL or default icon
              const _SplashLogo(),
              const SizedBox(height: 16),
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.push('/tour'),
                child: const Text('Preview App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends ConsumerWidget {
  const _SplashLogo();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox(
      height: 120,
      width: 120,
      child: Center(child: AppLogo(size: 96)),
    );
  }
}