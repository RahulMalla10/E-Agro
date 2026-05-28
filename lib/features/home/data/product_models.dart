import 'dart:convert';

import 'package:flutter/material.dart';

enum ProductCategory {
  vegetables,
  fruits,
  dairy;

  String get dbValue => name;

  IconData get icon => switch (this) {
        ProductCategory.vegetables => Icons.eco_outlined,
        ProductCategory.fruits => Icons.local_florist_outlined,
        ProductCategory.dairy => Icons.water_drop_outlined,
      };

  Color get color => switch (this) {
        ProductCategory.vegetables => const Color(0xFF388E3C),
        ProductCategory.fruits => const Color(0xFFE65100),
        ProductCategory.dairy => const Color(0xFF5D4037),
      };

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ProductCategory.vegetables,
    );
  }
}

class FarmerProduct {
  const FarmerProduct({
    required this.id,
    required this.name,
    this.nameNe,
    required this.category,
    required this.imagePaths,
    required this.stockQuantity,
    required this.stockUnit,
    required this.priceNpr,
    this.sellerId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? nameNe;
  final ProductCategory category;
  final List<String> imagePaths;
  final double stockQuantity;
  final String stockUnit;
  final double priceNpr;
  final String? sellerId;
  final DateTime createdAt;

  String? get primaryImage =>
      imagePaths.isEmpty ? null : imagePaths.first;

  String displayName(bool nepali) {
    if (nepali && nameNe != null && nameNe!.isNotEmpty) return nameNe!;
    return name;
  }

  factory FarmerProduct.fromMap(Map<String, Object?> map) {
    final pathsRaw = map['image_paths'] as String?;
    List<String> paths = [];
    if (pathsRaw != null && pathsRaw.isNotEmpty) {
      try {
        paths = (jsonDecode(pathsRaw) as List).cast<String>();
      } catch (_) {
        paths = [pathsRaw];
      }
    }

    return FarmerProduct(
      id: map['id'] as String,
      name: map['name'] as String,
      nameNe: map['name_ne'] as String?,
      category: ProductCategory.fromString(map['category'] as String),
      imagePaths: paths,
      stockQuantity: (map['stock_quantity'] as num?)?.toDouble() ?? 0,
      stockUnit: map['stock_unit'] as String? ?? 'kg',
      priceNpr: (map['price_npr'] as num?)?.toDouble() ?? 0,
      sellerId: map['seller_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'name_ne': nameNe,
        'category': category.dbValue,
        'image_paths': jsonEncode(imagePaths),
        'stock_quantity': stockQuantity,
        'stock_unit': stockUnit,
        'price_npr': priceNpr,
        'seller_id': sellerId,
        'created_at': createdAt.toIso8601String(),
      };

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        (nameNe?.toLowerCase().contains(q) ?? false);
  }

  bool get inStock => stockQuantity > 0;
}

class MarketplaceOrder {
  const MarketplaceOrder({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unit,
    required this.unitPriceNpr,
    required this.totalNpr,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    this.buyerLandmark,
    required this.paymentStatus,
    this.esewaRef,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final double quantity;
  final String unit;
  final double unitPriceNpr;
  final double totalNpr;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String? buyerLandmark;
  final String paymentStatus;
  final String? esewaRef;
  final DateTime createdAt;
}
