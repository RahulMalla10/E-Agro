import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/providers/user_role_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/widgets/app_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _consentLocation = false;
  bool _consentPhotos = false;
  String _language = 'ne';
  UserRole _role = UserRole.buyer;
  bool _loading = false;
  String? _error;

  AppStrings get _previewStrings => AppStrings(_language);

  Future<void> _finish() async {
    if (!_consentLocation && !_consentPhotos) {
      setState(() => _error = _previewStrings.consentRequired);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      ref.read(localeProvider.notifier).setLocale(_language);
      ref.read(userRoleProvider.notifier).setRole(_role);
      await ref.read(authRepositoryProvider).completeOnboarding(
            consentLocation: _consentLocation,
            consentPhotos: _consentPhotos,
            preferredLanguage: _language,
            userRole: _role,
          );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _finish();
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _previewStrings;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: s.btnBack,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() {
                  _page = i;
                  _error = null;
                }),
                children: [
                  _WelcomePage(strings: s),
                  _LanguagePage(
                    strings: s,
                    selected: _language,
                    onSelect: (code) {
                      setState(() => _language = code);
                      ref.read(localeProvider.notifier).setLocale(code);
                    },
                  ),
                  _RolePage(
                    strings: s,
                    selected: _role,
                    onSelect: (r) => setState(() => _role = r),
                  ),
                  _PermissionsPage(
                    strings: s,
                    location: _consentLocation,
                    photos: _consentPhotos,
                    onLocation: (v) => setState(() => _consentLocation = v),
                    onPhotos: (v) => setState(() => _consentPhotos = v),
                    error: _error,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: _loading ? null : _next,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_page == 3 ? s.btnGetStarted : s.btnNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const AppLogo(size: 110),
          ),
          const SizedBox(height: 32),
          Text(
            strings.onboardingWelcome,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            strings.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            strings.tagline,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RolePage extends StatelessWidget {
  const _RolePage({
    required this.strings,
    required this.selected,
    required this.onSelect,
  });

  final AppStrings strings;
  final UserRole selected;
  final ValueChanged<UserRole> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strings.onboardingStepRole, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              )),
          const SizedBox(height: 8),
          Text(strings.chooseRole, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          _RoleCard(
            title: strings.roleBuyer,
            subtitle: strings.roleBuyerDesc,
            icon: Icons.shopping_bag_outlined,
            selected: selected == UserRole.buyer,
            onTap: () => onSelect(UserRole.buyer),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            title: strings.roleSeller,
            subtitle: strings.roleSellerDesc,
            icon: Icons.storefront_outlined,
            selected: selected == UserRole.seller,
            onTap: () => onSelect(UserRole.seller),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 36, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    required this.strings,
    required this.selected,
    required this.onSelect,
  });

  final AppStrings strings;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.onboardingStepLanguage,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(strings.languageTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 28),
          _LanguageCard(
            label: strings.languageNepali,
            subtitle: 'नेपाली',
            icon: Icons.translate,
            selected: selected == 'ne',
            onTap: () => onSelect('ne'),
          ),
          const SizedBox(height: 16),
          _LanguageCard(
            label: strings.languageEnglish,
            subtitle: 'English',
            icon: Icons.language,
            selected: selected == 'en',
            onTap: () => onSelect('en'),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      elevation: selected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: theme.colorScheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleLarge),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage({
    required this.strings,
    required this.location,
    required this.photos,
    required this.onLocation,
    required this.onPhotos,
    this.error,
  });

  final AppStrings strings;
  final bool location;
  final bool photos;
  final ValueChanged<bool> onLocation;
  final ValueChanged<bool> onPhotos;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            strings.onboardingStepPermissions,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(strings.permissionsTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(strings.permissionsSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          _PermissionTile(
            icon: Icons.location_on_outlined,
            title: strings.consentLocationTitle,
            body: strings.consentLocationBody,
            value: location,
            onChanged: onLocation,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.photo_camera_outlined,
            title: strings.consentPhotosTitle,
            body: strings.consentPhotosBody,
            value: photos,
            onChanged: onPhotos,
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          secondary: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          title: Text(title, style: theme.textTheme.titleMedium),
          subtitle: Text(body),
        ),
      ),
    );
  }
}
