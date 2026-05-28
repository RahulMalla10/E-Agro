import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/providers/user_role_provider.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/core/widgets/app_logo.dart';

class ChooseRoleScreen extends ConsumerStatefulWidget {
  const ChooseRoleScreen({super.key, this.afterLogout = false});

  final bool afterLogout;

  @override
  ConsumerState<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends ConsumerState<ChooseRoleScreen> {
  UserRole? _selected;
  bool _saving = false;

  Future<void> _confirm() async {
    if (_selected == null) return;

    setState(() => _saving = true);
    try {
      ref.read(userRoleProvider.notifier).setRole(_selected!);
      await ref.read(authRepositoryProvider).updateUserRole(_selected!);

      await ref.read(authRepositoryProvider).ensureInitialSetup();

      if (!mounted) return;
      context.go(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.chooseRole),
        automaticallyImplyLeading: widget.afterLogout,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AppLogo(size: 72)),
              const SizedBox(height: 20),
              Text(
                s.chooseRole,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (widget.afterLogout) ...[
                const SizedBox(height: 8),
                Text(
                  s.logoutRoleHint,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 28),
              _RoleOption(
                title: s.roleBuyer,
                subtitle: s.roleBuyerDesc,
                icon: Icons.shopping_bag_outlined,
                selected: _selected == UserRole.buyer,
                onTap: () => setState(() => _selected = UserRole.buyer),
              ),
              const SizedBox(height: 12),
              _RoleOption(
                title: s.roleSeller,
                subtitle: s.roleSellerDesc,
                icon: Icons.storefront_outlined,
                selected: _selected == UserRole.seller,
                onTap: () => setState(() => _selected = UserRole.seller),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _selected == null || _saving ? null : _confirm,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(s.btnNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
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
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
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
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
