import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tenant_info_providers.dart';

class AppLogo extends ConsumerWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconUrl = ref.watch(tenantIconUrlProvider);
    final color = Theme.of(context).colorScheme.primary;

    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        if (iconUrl != null && iconUrl.isNotEmpty) {
          return CircleAvatar(radius: size / 2, backgroundImage: NetworkImage(iconUrl));
        }
        return Icon(Icons.church, size: size, color: color);
      },
    );
  }
}