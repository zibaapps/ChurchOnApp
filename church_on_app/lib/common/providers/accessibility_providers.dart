import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final textScaleProvider = StateProvider<double>((ref) => 1.0);
final highContrastProvider = StateProvider<bool>((ref) => false);

ThemeData applyAccessibility(ThemeData base, Ref ref) {
  final highContrast = ref.watch(highContrastProvider);
  if (!highContrast) return base;
  final scheme = base.colorScheme;
  return base.copyWith(
    colorScheme: scheme.copyWith(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
  );
}