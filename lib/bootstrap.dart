import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/app.dart';
import 'package:krishi_smart/core/config/app_config.dart';
import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/core/network/supabase_client.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await AppConfig.load();
  final database = await AppDatabase.open();
  final supabase = await initializeSupabase(config);

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        appDatabaseProvider.overrideWithValue(database),
        supabaseServiceProvider.overrideWithValue(supabase),
      ],
      child: const KrishiSmartApp(),
    ),
  );
}
