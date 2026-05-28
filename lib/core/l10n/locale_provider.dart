import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, String>((ref) => LocaleNotifier(ref));

final stringsProvider = Provider<AppStrings>((ref) {
  return AppStrings(ref.watch(localeProvider));
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier(this._ref) : super('en') {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final storage = _ref.read(secureStorageProvider);
    var code = await storage.getPreferredLanguage();
    if (code.isEmpty) {
      final profile = await _ref.read(appDatabaseProvider).getFarmerProfile();
      code = profile?['preferred_language'] as String? ?? 'en';
    }
    if (code != 'ne' && code != 'en') code = 'en';
    state = code;
  }

  /// Updates UI immediately; persists in the background (no navigation reset).
  void setLocale(String code) {
    final normalized = code == 'ne' ? 'ne' : 'en';
    if (state == normalized) return;
    state = normalized;
    _ref.read(secureStorageProvider).setPreferredLanguage(normalized);
  }
}
