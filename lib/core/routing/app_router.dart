import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/user_role_provider.dart';
import 'package:krishi_smart/core/routing/router_refresh.dart';
import 'package:krishi_smart/core/widgets/app_drawer.dart';
import 'package:krishi_smart/features/auth/presentation/choose_role_screen.dart';
import 'package:krishi_smart/features/auth/presentation/login_screen.dart';
import 'package:krishi_smart/features/auth/presentation/onboarding_screen.dart';
import 'package:krishi_smart/features/auth/presentation/splash_screen.dart';
import 'package:krishi_smart/features/home/presentation/all_products_screen.dart';
import 'package:krishi_smart/features/home/presentation/home_screen.dart';
import 'package:krishi_smart/features/insights/presentation/insights_screen.dart';
import 'package:krishi_smart/features/tools/presentation/farm_tools_screen.dart';
import 'package:krishi_smart/features/trading/presentation/checkout_screen.dart';
import 'package:krishi_smart/features/trading/presentation/esewa_payment_screen.dart';
import 'package:krishi_smart/features/trading/presentation/product_detail_screen.dart';
import 'package:krishi_smart/features/seller_analytics/presentation/seller_analytics_screen.dart';
import 'package:krishi_smart/features/trading/presentation/seller_upload_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/';
  static const products = '/products';
  static const productDetail = '/product';
  static const sellerUpload = '/sell/upload';
  static const checkout = '/checkout';
  static const esewaPay = '/pay/esewa';
  static const farmTools = '/tools';
  static const insights = '/insights';
  static const sellerAnalytics = '/seller/analytics';
  static const chooseRole = '/choose-role';

  static const advisor = farmTools;
  static const disease = farmTools;
  static const news = insights;
  static const weather = insights;
  static const addProduct = sellerUpload;
  static const cropAdvisor = farmTools;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;

      if (path == AppRoutes.splash) return null;
      if (path == AppRoutes.chooseRole) return null;

      if (path == AppRoutes.onboarding || path == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseRole,
        builder: (context, state) {
          final afterLogout = state.uri.queryParameters['logout'] == '1';
          return ChooseRoleScreen(afterLogout: afterLogout);
        },
      ),
      GoRoute(
        path: AppRoutes.sellerUpload,
        builder: (context, state) => const SellerUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          final qty = double.tryParse(state.uri.queryParameters['qty'] ?? '1') ?? 1;
          return CheckoutScreen(productId: id, quantity: qty);
        },
      ),
      GoRoute(
        path: AppRoutes.esewaPay,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return EsewaPaymentScreen(
            productId: q['id'] ?? '',
            quantity: double.tryParse(q['qty'] ?? '1') ?? 1,
            buyerName: Uri.decodeComponent(q['name'] ?? ''),
            buyerPhone: Uri.decodeComponent(q['phone'] ?? ''),
            buyerAddress: Uri.decodeComponent(q['address'] ?? ''),
            buyerLandmark: Uri.decodeComponent(q['landmark'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? 'vegetables';
          return AllProductsScreen(categoryKey: category);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.farmTools,
            builder: (context, state) => const FarmToolsScreen(),
          ),
          GoRoute(
            path: AppRoutes.insights,
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: AppRoutes.sellerAnalytics,
            builder: (context, state) => const SellerAnalyticsScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.child});

  final Widget child;

  int _indexForLocation(String location, bool isSeller) {
    if (location.startsWith(AppRoutes.farmTools)) return 1;
    if (isSeller && location.startsWith(AppRoutes.sellerAnalytics)) return 2;
    if (location.startsWith(AppRoutes.insights)) return isSeller ? 3 : 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final s = ref.watch(stringsProvider);
    final role = ref.watch(userRoleProvider);
    final isSeller = role == UserRole.seller;
    final selected = _indexForLocation(location, isSeller);

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      body: child,
      floatingActionButton: isSeller ? const _SellerFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isSeller
          ? _sellerBar(context, s, selected)
          : _buyerBar(context, s, selected),
    );
  }

  Widget _buyerBar(BuildContext context, AppStrings s, int selected) {
    return NavigationBar(
      selectedIndex: selected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) => _go(context, i, isSeller: false),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: s.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.agriculture_outlined),
          selectedIcon: const Icon(Icons.agriculture),
          label: s.navFarmTools,
        ),
        NavigationDestination(
          icon: const Icon(Icons.insights_outlined),
          selectedIcon: const Icon(Icons.insights),
          label: s.navInsights,
        ),
      ],
    );
  }

  Widget _sellerBar(BuildContext context, AppStrings s, int selected) {
    return BottomAppBar(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      notchMargin: _SellerFab.notchMargin,
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _DockNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: s.navHome,
              selected: selected == 0,
              onTap: () => _go(context, 0, isSeller: true),
            ),
          ),
          Expanded(
            child: _DockNavItem(
              icon: Icons.agriculture_outlined,
              selectedIcon: Icons.agriculture,
              label: s.navFarmTools,
              selected: selected == 1,
              onTap: () => _go(context, 1, isSeller: true),
            ),
          ),
          const SizedBox(width: _SellerFab.notchWidth),
          Expanded(
            child: _DockNavItem(
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics,
              label: s.navSellerAnalytics,
              selected: selected == 2,
              onTap: () => _go(context, 2, isSeller: true),
            ),
          ),
          Expanded(
            child: _DockNavItem(
              icon: Icons.newspaper_outlined,
              selectedIcon: Icons.newspaper,
              label: s.navNews,
              selected: selected == 3,
              onTap: () => _go(context, 3, isSeller: true),
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, int index, {required bool isSeller}) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.farmTools);
      case 2:
        if (isSeller) {
          context.go(AppRoutes.sellerAnalytics);
        } else {
          context.go(AppRoutes.insights);
        }
      case 3:
        context.go(AppRoutes.insights);
    }
  }
}

/// Center-docked sell button; [notchWidth] must match [BottomAppBar] center gap.
class _SellerFab extends StatelessWidget {
  const _SellerFab();

  static const double size = 58;
  static const double notchMargin = 8;
  static const double notchWidth = size + notchMargin * 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        elevation: 8,
        highlightElevation: 12,
        shape: const CircleBorder(),
        onPressed: () => context.push<bool>(AppRoutes.sellerUpload),
        child: Icon(Icons.add_rounded, size: 32, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}

class _DockNavItem extends StatelessWidget {
  const _DockNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
