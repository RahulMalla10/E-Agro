import 'package:flutter/material.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/widgets/product_image.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

class MinimalSectionTitle extends StatelessWidget {
  const MinimalSectionTitle({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const Spacer(),
          if (onSeeAll != null)
            IconButton(
              onPressed: onSeeAll,
              icon: const Icon(Icons.chevron_right, size: 22),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class HorizontalProductList extends StatelessWidget {
  const HorizontalProductList({
    super.key,
    required this.products,
    this.emptyMessage = '',
    this.onProductTap,
    this.nepali = false,
  });

  final List<FarmerProduct> products;
  final String emptyMessage;
  final void Function(FarmerProduct)? onProductTap;
  final bool nepali;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      if (emptyMessage.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      );
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            nepali: nepali,
            onTap: onProductTap == null ? null : () => onProductTap!(products[index]),
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.nepali = false,
  });

  final FarmerProduct product;
  final VoidCallback? onTap;
  final bool nepali;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = StockUnit.byId(product.stockUnit);

    return SizedBox(
      width: 132,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductImage.fromProduct(
                product,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName(nepali),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      'Rs ${product.priceNpr.toStringAsFixed(0)}/${nepali ? unit.labelNe : unit.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
