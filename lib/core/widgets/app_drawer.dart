import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/providers/theme_mode_provider.dart';
import 'package:krishi_smart/core/providers/user_role_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/routing/router_refresh.dart';
import 'package:krishi_smart/core/widgets/app_logo.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final role = ref.watch(userRoleProvider);
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const AppLogo(size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.appName, style: theme.textTheme.titleMedium),
                        Text(
                          role == UserRole.seller ? s.roleSeller : s.roleBuyer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(s.profile, style: theme.textTheme.titleSmall),
              subtitle: Text(s.profileSubtitle, style: theme.textTheme.bodySmall),
              onTap: () {
                Navigator.pop(context);
                _showProfile(context, s, role);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(s.switchRole, style: theme.textTheme.titleSmall),
              subtitle: Text(s.switchRoleSubtitle, style: theme.textTheme.bodySmall),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.chooseRole);
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(s.settings, style: theme.textTheme.titleSmall),
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(s.language, style: theme.textTheme.labelLarge),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'ne', label: Text(s.languageNepali)),
                      ButtonSegment(value: 'en', label: Text(s.languageEnglish)),
                    ],
                    selected: {locale},
                    onSelectionChanged: (v) {
                      ref.read(localeProvider.notifier).setLocale(v.first);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: Text(s.appearance, style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    themeMode == ThemeMode.dark ? s.darkMode : s.lightMode,
                    style: theme.textTheme.bodySmall,
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ),
                const SizedBox(height: 8),
              ],
            ),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                s.logout,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout(context, ref, s);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                s.drawerFooter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, AppStrings s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.logout),
        content: Text(s.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.btnBack),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.logout),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authRepositoryProvider).logout();
    ref.read(routerRefreshProvider).notifyRouter();
    if (context.mounted) {
      context.go('${AppRoutes.chooseRole}?logout=1');
    }
  }

  void _showProfile(BuildContext context, AppStrings s, UserRole role) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.profile, style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: Text(s.accountType),
              subtitle: Text(role == UserRole.seller ? s.roleSeller : s.roleBuyer),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(s.language),
              subtitle: Text(s.isNepali ? s.languageNepali : s.languageEnglish),
            ),
          ],
        ),
      ),
    );
  }
}
