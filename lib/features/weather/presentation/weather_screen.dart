import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/weather/data/weather_repository.dart';

final _weatherBundleProvider = FutureProvider<WeatherBundle>((ref) async {
  await ref.read(permissionServiceProvider).requestLocation();
  return ref.read(weatherRepositoryProvider).getWeatherBundle();
});

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = ref.watch(_weatherBundleProvider);
    final s = ref.watch(stringsProvider);

    final body = bundle.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('${s.error}: $e')),
            data: (b) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_weatherBundleProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CurrentCard(forecast: b.current, strings: s),
              const SizedBox(height: 16),
              if (b.alerts.isNotEmpty) ...[
                Text(s.alerts, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...b.alerts.map((a) => _AlertCard(alert: a)),
                const SizedBox(height: 16),
              ],
              Text(s.forecast5Day, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...b.daily.map((d) => _DayRow(day: d)),
              if (b.current.isOfflineFallback) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(s.offlineWeatherHint),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: Text(s.weatherTitle)), body: body);
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.forecast, required this.strings});

  final WeatherForecast forecast;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.tertiary.withValues(alpha: 0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forecast.locationLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.tempC.round()}°C',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              forecast.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                  icon: Icons.water_drop,
                  label: '${forecast.humidity}% ${strings.humidityLabel}',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.air,
                  label: '${forecast.windKph.round()} km/h ${strings.windLabel}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final WeatherAlert alert;

  Color _severityColor(BuildContext context) {
    return switch (alert.severity) {
      'high' => Colors.red.shade700,
      'medium' => Colors.orange.shade800,
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _severityColor(context).withValues(alpha: 0.15),
          child: Icon(Icons.warning_amber, color: _severityColor(context)),
        ),
        title: Text(alert.title),
        subtitle: Text(alert.message),
        isThreeLine: true,
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final DailyForecast day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMM').format(day.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.label, style: theme.textTheme.titleMedium),
                  Text(dateLabel, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(_iconFor(day.icon), size: 36, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                day.summary,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${day.tempMinC.round()}° / ${day.tempMaxC.round()}°',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String code) {
    if (code.startsWith('09') || code.startsWith('10')) return Icons.grain;
    if (code.startsWith('11')) return Icons.thunderstorm;
    if (code.startsWith('13')) return Icons.ac_unit;
    if (code.startsWith('50')) return Icons.foggy;
    if (code.startsWith('02') || code.startsWith('03') || code.startsWith('04')) {
      return Icons.wb_cloudy;
    }
    return Icons.wb_sunny;
  }
}
