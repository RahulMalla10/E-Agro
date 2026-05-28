import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:krishi_smart/core/config/app_config.dart';
import 'package:krishi_smart/core/errors/app_exception.dart';

class WeatherForecast {
  const WeatherForecast({
    required this.locationLabel,
    required this.summary,
    required this.tempC,
    required this.humidity,
    required this.windKph,
    required this.isOfflineFallback,
  });

  final String locationLabel;
  final String summary;
  final double tempC;
  final int humidity;
  final double windKph;
  final bool isOfflineFallback;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.label,
    required this.tempMinC,
    required this.tempMaxC,
    required this.summary,
    required this.icon,
  });

  final DateTime date;
  final String label;
  final double tempMinC;
  final double tempMaxC;
  final String summary;
  final String icon;
}

class WeatherAlert {
  const WeatherAlert({
    required this.severity,
    required this.title,
    required this.message,
  });

  final String severity;
  final String title;
  final String message;
}

class WeatherBundle {
  const WeatherBundle({
    required this.current,
    required this.daily,
    required this.alerts,
  });

  final WeatherForecast current;
  final List<DailyForecast> daily;
  final List<WeatherAlert> alerts;
}

class WeatherRepository {
  WeatherRepository({required AppConfig config, http.Client? client})
      : _config = config,
        _client = client ?? http.Client();

  final AppConfig _config;
  final http.Client _client;

  Future<WeatherBundle> getWeatherBundle({
    double lat = 27.7172,
    double lon = 85.3240,
    String locationLabel = 'Kathmandu',
  }) async {
    final current = await getForecast(
      lat: lat,
      lon: lon,
      locationLabel: locationLabel,
    );
    final key = _config.openWeatherApiKey;

    if (key.isEmpty) {
      return WeatherBundle(
        current: current,
        daily: _mockDaily(),
        alerts: _deriveAlerts(current, _mockDaily()),
      );
    }

    try {
      final uri = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/forecast',
        {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': key,
          'units': 'metric',
        },
      );
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw NetworkException('Forecast API error (${response.statusCode})');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List;
      final daily = _aggregateDaily(list);
      return WeatherBundle(
        current: current,
        daily: daily,
        alerts: _deriveAlerts(current, daily),
      );
    } catch (_) {
      final daily = _mockDaily();
      return WeatherBundle(
        current: current,
        daily: daily,
        alerts: _deriveAlerts(current, daily),
      );
    }
  }

  Future<WeatherForecast> getForecast({
    double lat = 27.7172,
    double lon = 85.3240,
    String locationLabel = 'Kathmandu',
  }) async {
    final key = _config.openWeatherApiKey;
    if (key.isEmpty) {
      return WeatherForecast(
        locationLabel: locationLabel,
        summary: 'Partly cloudy — offline estimate',
        tempC: 24,
        humidity: 65,
        windKph: 8,
        isOfflineFallback: true,
      );
    }

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': key,
        'units': 'metric',
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw NetworkException('Weather API error (${response.statusCode})');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = (data['weather'] as List).first as Map<String, dynamic>;
      final main = data['main'] as Map<String, dynamic>;
      final wind = data['wind'] as Map<String, dynamic>?;

      return WeatherForecast(
        locationLabel: locationLabel,
        summary: weather['description'] as String? ?? '—',
        tempC: (main['temp'] as num).toDouble(),
        humidity: (main['humidity'] as num).toInt(),
        windKph: ((wind?['speed'] as num?) ?? 0).toDouble() * 3.6,
        isOfflineFallback: false,
      );
    } catch (_) {
      return WeatherForecast(
        locationLabel: locationLabel,
        summary: 'Unable to reach weather service',
        tempC: 24,
        humidity: 65,
        windKph: 8,
        isOfflineFallback: true,
      );
    }
  }

  List<DailyForecast> _aggregateDaily(List<dynamic> entries) {
    final byDay = <String, List<Map<String, dynamic>>>{};

    for (final raw in entries) {
      final item = raw as Map<String, dynamic>;
      final dtTxt = item['dt_txt'] as String;
      final dayKey = dtTxt.split(' ').first;
      byDay.putIfAbsent(dayKey, () => []).add(item);
    }

    final days = byDay.keys.toList()..sort();
    final result = <DailyForecast>[];

    for (final day in days.take(7)) {
      final slots = byDay[day]!;
      double minT = 99;
      double maxT = -99;
      String summary = '';
      String icon = '01d';

      for (final slot in slots) {
        final main = slot['main'] as Map<String, dynamic>;
        final t = (main['temp'] as num).toDouble();
        minT = t < minT ? t : minT;
        maxT = t > maxT ? t : maxT;
        final weather = (slot['weather'] as List).first as Map<String, dynamic>;
        summary = weather['description'] as String? ?? summary;
        icon = weather['icon'] as String? ?? icon;
      }

      result.add(
        DailyForecast(
          date: DateTime.parse(day),
          label: _weekday(DateTime.parse(day)),
          tempMinC: minT,
          tempMaxC: maxT,
          summary: summary,
          icon: icon,
        ),
      );
    }
    return result;
  }

  List<DailyForecast> _mockDaily() {
    final now = DateTime.now();
    return List.generate(5, (i) {
      final d = now.add(Duration(days: i));
      return DailyForecast(
        date: d,
        label: _weekday(d),
        tempMinC: 18 + i.toDouble(),
        tempMaxC: 26 + i.toDouble(),
        summary: i == 0 ? 'Partly cloudy' : i == 2 ? 'Light rain possible' : 'Clear',
        icon: i == 2 ? '10d' : '02d',
      );
    });
  }

  List<WeatherAlert> _deriveAlerts(WeatherForecast current, List<DailyForecast> daily) {
    final alerts = <WeatherAlert>[];

    if (current.tempC >= 35) {
      alerts.add(
        const WeatherAlert(
          severity: 'high',
          title: 'Heat stress',
          message: 'High temperature — irrigate crops in early morning or evening.',
        ),
      );
    }
    if (current.humidity >= 85) {
      alerts.add(
        const WeatherAlert(
          severity: 'medium',
          title: 'High humidity',
          message: 'Fungal disease risk rises — scout tomatoes and potatoes for blight.',
        ),
      );
    }
    if (current.windKph >= 40) {
      alerts.add(
        const WeatherAlert(
          severity: 'medium',
          title: 'Strong wind',
          message: 'Secure greenhouse plastic and delay spraying until winds calm.',
        ),
      );
    }

    final rainDay = daily.any((d) => d.summary.toLowerCase().contains('rain'));
    if (rainDay) {
      alerts.add(
        const WeatherAlert(
          severity: 'info',
          title: 'Rain expected',
          message: 'Delay urea top-dress; good window for paddy transplant if fields are level.',
        ),
      );
    }

    if (alerts.isEmpty && current.isOfflineFallback) {
      alerts.add(
        const WeatherAlert(
          severity: 'info',
          title: 'Offline estimates',
          message: 'Add OPENWEATHER_API_KEY in .env for live forecasts and precise alerts.',
        ),
      );
    }

    return alerts;
  }

  String _weekday(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }
}
