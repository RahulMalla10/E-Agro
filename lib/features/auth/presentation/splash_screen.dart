import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/providers/user_role_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/widgets/splash_loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minDisplayDuration = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final startedAt = DateTime.now();
    await ref.read(authRepositoryProvider).ensureInitialSetup();

    final lang = await ref.read(secureStorageProvider).getPreferredLanguage();
    if (lang.isNotEmpty) {
      ref.read(localeProvider.notifier).setLocale(lang);
    }

    final role = await ref.read(secureStorageProvider).getUserRole();
    ref.read(userRoleProvider.notifier).setRole(role);

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minDisplayDuration) {
      await Future.delayed(_minDisplayDuration - elapsed);
    }

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: SplashLoader(size: 180),
      ),
    );
  }
}
