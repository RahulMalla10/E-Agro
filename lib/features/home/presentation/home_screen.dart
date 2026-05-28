import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/widgets/app_logo.dart';
import 'package:krishi_smart/core/widgets/drawer_menu_button.dart';
import 'package:krishi_smart/core/widgets/product_showcase.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

final productsProvider = FutureProvider<List<FarmerProduct>>((ref) {
  return ref.watch(productRepositoryProvider).getListings();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmerProduct> _filter(List<FarmerProduct> list) {
    if (_query.isEmpty) return list;
    return list.where((p) => p.matchesQuery(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final s = ref.watch(stringsProvider);
    final nepali = s.isNepali;

    return productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.error}: $e')),
        data: (all) {
          final filtered = _filter(all);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(productsProvider),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  toolbarHeight: 64,
                  leading: const DrawerMenuButton(),
                  title: Row(
                    children: [
                      const AppLogo(size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.appName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              s.homeSubtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SearchBar(
                        controller: _searchController,
                        hintText: s.searchHint,
                        leading: const Icon(Icons.search, size: 22),
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        trailing: _query.isEmpty
                            ? null
                            : [
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                              ],
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ),
                ),
                if (_query.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: MinimalSectionTitle(title: s.searchResults(filtered.length)),
                  ),
                  SliverToBoxAdapter(
                    child: HorizontalProductList(
                      products: filtered,
                      emptyMessage: s.noListings,
                      nepali: nepali,
                      onProductTap: (p) => _openProduct(context, p.id),
                    ),
                  ),
                ] else ...[
                  _section(s, nepali, s.sectionVegetables, ProductCategory.vegetables, filtered),
                  _section(s, nepali, s.sectionFruits, ProductCategory.fruits, filtered),
                  _section(s, nepali, s.sectionDairy, ProductCategory.dairy, filtered),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
          );
        },
      );
  }

  Widget _section(
    AppStrings s,
    bool nepali,
    String title,
    ProductCategory category,
    List<FarmerProduct> all,
  ) {
    final items = all.where((p) => p.category == category).toList();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MinimalSectionTitle(
            title: title,
            onSeeAll: items.isEmpty
                ? null
                : () => context.push(
                      '${AppRoutes.products}?category=${category.dbValue}',
                    ),
          ),
          HorizontalProductList(
            products: items,
            emptyMessage: s.noListings,
            nepali: nepali,
            onProductTap: (p) => _openProduct(context, p.id),
          ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, String id) {
    context.push('${AppRoutes.productDetail}?id=$id');
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SearchHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) => false;
}
