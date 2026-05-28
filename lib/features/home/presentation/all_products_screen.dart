import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/widgets/drawer_menu_button.dart';
import 'package:krishi_smart/core/widgets/product_showcase.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';
import 'package:krishi_smart/features/home/presentation/home_screen.dart';

class AllProductsScreen extends ConsumerWidget {
  const AllProductsScreen({super.key, required this.categoryKey});

  final String categoryKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerMenuButton(),
        title: Text(s.allCategoryTitle(categoryKey)),
      ),
      body: productsAsync.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('${s.error}: $e')),
        data: (all) {
          final list = _filter(all, categoryKey);
          if (list.isEmpty) {
            return Center(child: Text(s.noListings));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              return ProductCard(
                product: p,
                nepali: s.isNepali,
                onTap: () => context.push('${AppRoutes.productDetail}?id=${p.id}'),
              );
            },
          );
        },
      ),
    );
  }

  List<FarmerProduct> _filter(List<FarmerProduct> all, String key) {
    final cat = ProductCategory.fromString(key);
    return all.where((p) => p.category == cat).toList();
  }
}
