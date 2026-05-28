import 'dart:io';

import 'package:flutter/material.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

/// Product photo with consistent aspect ratio; [BoxFit.contain] keeps the full image visible.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    this.aspectRatio = 4 / 3,
    this.borderRadius,
    this.placeholderIcon,
    this.placeholderColor,
  });

  final String? imagePath;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final IconData? placeholderIcon;
  final Color? placeholderColor;

  factory ProductImage.fromProduct(
    FarmerProduct product, {
    double aspectRatio = 4 / 3,
    BorderRadius? borderRadius,
  }) {
    return ProductImage(
      imagePath: product.primaryImage,
      aspectRatio: aspectRatio,
      borderRadius: borderRadius,
      placeholderIcon: product.category.icon,
      placeholderColor: product.category.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: bg,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = imagePath;
    if (path != null && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        placeholderIcon ?? Icons.image_outlined,
        size: 40,
        color: (placeholderColor ?? Colors.grey).withValues(alpha: 0.6),
      ),
    );
  }
}
