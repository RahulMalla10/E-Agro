import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.openWeatherApiKey,
    required this.enableAnalytics,
    required this.enableCrashReporting,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String openWeatherApiKey;
  final bool enableAnalytics;
  final bool enableCrashReporting;

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('placeholder') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('placeholder');

  static Future<AppConfig> load() async {
    await dotenv.load(fileName: '.env');

    return AppConfig(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      openWeatherApiKey: dotenv.env['OPENWEATHER_API_KEY'] ?? '',
      enableAnalytics: dotenv.env['ENABLE_ANALYTICS'] == 'true',
      enableCrashReporting: dotenv.env['ENABLE_CRASH_REPORTING'] == 'true',
    );
  }
}
