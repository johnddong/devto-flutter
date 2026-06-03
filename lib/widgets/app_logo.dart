import 'package:flutter/material.dart';

/// App bar logo from bundled PNG asset.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 28});

  /// Target height; width follows asset aspect (300×240).
  final double size;

  /// Must match [pubspec.yaml] exactly — no `?query` (that breaks lookup).
  static const _assetPath = 'assets/images/dev_logo.png';
  static const _aspectW = 300.0;
  static const _aspectH = 240.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = size * _aspectW / _aspectH;
    return Semantics(
      label: 'App logo',
      child: SizedBox(
        width: w,
        height: size,
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          errorBuilder: (_, __, ___) => Icon(
            Icons.bolt_outlined,
            size: size,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
