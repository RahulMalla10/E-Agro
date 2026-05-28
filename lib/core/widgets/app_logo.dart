import 'package:flutter/material.dart';

/// App branding image from [assets/logo/logo.png].
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.borderRadius});

  final double size;
  final BorderRadius? borderRadius;

  static const assetPath = 'assets/logo/logo.png';

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.2);

    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.eco,
          size: size * 0.7,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
