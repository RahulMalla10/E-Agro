import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier(ref));

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref) : super(ThemeMode.light) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final stored = await _ref.read(secureStorageProvider).getThemeMode();
    state = stored;
  }

  void setThemeMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
    _ref.read(secureStorageProvider).setThemeMode(mode);
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}
