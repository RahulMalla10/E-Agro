import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/widgets/drawer_menu_button.dart';
import 'package:krishi_smart/features/crop_advisor/presentation/crop_advisor_screen.dart';
import 'package:krishi_smart/features/disease_detection/presentation/disease_detection_screen.dart';

class FarmToolsScreen extends ConsumerWidget {
  const FarmToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const DrawerMenuButton(),
          title: Text(s.navFarmTools),
          bottom: TabBar(
            tabs: [
              Tab(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(s.navAdvisor, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              Tab(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.biotech_outlined, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(s.navDisease, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CropAdvisorScreen(embedded: true),
            DiseaseDetectionScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
