import 'package:flutter/material.dart';
import 'package:krishi_smart/core/widgets/product_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/user_role_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/trading/presentation/review_widgets.dart';
import 'package:krishi_smart/features/trading/presentation/review_providers.dart';
import 'package:krishi_smart/features/trading/presentation/submit_review_sheet.dart';

final productDetailProvider = FutureProvider.family<FarmerProduct?, String>((
  ref,
  id,
) {
  return ref.watch(productRepositoryProvider).getById(id);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  double _qty = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final s = ref.watch(stringsProvider);
    final role = ref.watch(userRoleProvider);
    final nepali = s.isNepali;

    return Scaffold(
      appBar: AppBar(title: Text(s.productDetails)),
      body: productAsync.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('$e')),
        data: (product) {
          if (product == null) {
            return Center(child: Text(s.productNotFound));
          }

          final unit = StockUnit.byId(product.stockUnit);
          final maxQty = product.stockQuantity;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (product.imagePaths.isNotEmpty)
                      SizedBox(
                        height: 260,
                        child: PageView.builder(
                          itemCount: product.imagePaths.length,
                          itemBuilder: (_, i) => ProductImage(
                            imagePath: product.imagePaths[i],
                            aspectRatio: 4 / 3,
                            borderRadius: BorderRadius.circular(12),
                            placeholderIcon: product.category.icon,
                            placeholderColor: product.category.color,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      product.displayName(nepali),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs ${product.priceNpr.toStringAsFixed(0)} / ${nepali ? unit.labelNe : unit.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${s.stockAvailable}: ${product.stockQuantity.toStringAsFixed(1)} ${nepali ? unit.labelNe : unit.id}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Seller Rating Section
                    if (product.sellerId != null) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1),
                      const SizedBox(height: 16),
                      Text(
                        nepali ? 'विक्रेता' : 'Seller',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ref
                          .watch(sellerAverageRatingProvider(product.sellerId!))
                          .when(
                            data: (avgRating) => ref
                                .watch(
                                  sellerReviewCountProvider(product.sellerId!),
                                )
                                .when(
                                  data: (count) => SellerRatingDisplay(
                                    averageRating: avgRating,
                                    reviewCount: count,
                                  ),
                                  loading: () =>
                                      const CircularProgressIndicator(),
                                  error: (e, _) => Text('Error: $e'),
                                ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text('Error: $e'),
                          ),
                    ],
                    if (role == UserRole.buyer && product.inStock) ...[
                      const SizedBox(height: 24),
                      Text(
                        s.quantity,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _qty > 1
                                ? () => setState(() => _qty -= 1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            _qty.toStringAsFixed(
                              _qty == _qty.roundToDouble() ? 0 : 1,
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            onPressed: _qty < maxQty
                                ? () => setState(() => _qty += 1)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          const Spacer(),
                          Text(
                            '${s.total}: Rs ${(_qty * product.priceNpr).toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                    // Reviews Section
                    if (product.sellerId != null) ...[
                      const SizedBox(height: 24),
                      Divider(height: 1),
                      const SizedBox(height: 16),
                      Text(
                        nepali ? 'समीक्षाहरु' : 'Reviews',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ref
                          .watch(sellerReviewsProvider(product.sellerId!))
                          .when(
                            data: (reviews) => ReviewListView(reviews: reviews),
                            loading: () => const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Text('Error: $e'),
                          ),
                    ],
                  ],
                ),
              ),
              if (role == UserRole.buyer && product.inStock)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: () => context.push(
                            '${AppRoutes.checkout}?id=${product.id}&qty=$_qty',
                          ),
                          child: Text(s.buyNow),
                        ),
                        const SizedBox(height: 8),
                        if (product.sellerId != null)
                          OutlinedButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => SubmitReviewBottomSheet(
                                sellerId: product.sellerId!,
                                productId: product.id,
                                onReviewSubmitted: () => ref.refresh(
                                  sellerReviewsProvider(product.sellerId!),
                                ),
                              ),
                            ),
                            child: Text(
                              nepali ? 'समीक्षा दिनुहोस्' : 'Write a Review',
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else if (role == UserRole.buyer)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed: null,
                      child: Text(nepali ? 'स्टकबाहिर' : 'Out of Stock'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
