import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Splash loading animation. Place JSON at [assets/animations/splash_loading.json].
/// See docs/ASSETS.md for download instructions.
class SplashLoader extends StatelessWidget {
  const SplashLoader({super.key, this.size = 120});

  final double size;

  static const lottieAsset = 'assets/animations/splash_loading.json';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        lottieAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _FallbackLoader(size: size * 0.5),
      ),
    );
  }
}

class _FallbackLoader extends StatefulWidget {
  const _FallbackLoader({required this.size});

  final double size;

  @override
  State<_FallbackLoader> createState() => _FallbackLoaderState();
}

class _FallbackLoaderState extends State<_FallbackLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.eco, size: widget.size, color: color),
    );
  }
}
