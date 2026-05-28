import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/widgets/drawer_menu_button.dart';
import 'package:krishi_smart/features/news/presentation/news_screen.dart';
import 'package:krishi_smart/features/weather/presentation/weather_screen.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const DrawerMenuButton(),
          title: Text(s.navInsights),
          bottom: TabBar(
            tabs: [
              Tab(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.newspaper_outlined, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(s.navNews, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              Tab(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_outlined, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(s.navWeather, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewsScreen(embedded: true),
            WeatherScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
