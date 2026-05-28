import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:krishi_smart/core/models/user_role.dart';

/// Stores sensitive tokens and keys in platform secure enclaves (Keychain / Keystore).
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'auth_session';
  static const _onboardingKey = 'onboarding_complete';
  static const _languageKey = 'preferred_language';
  static const _roleKey = 'user_role';
  static const _themeKey = 'theme_mode';

  Future<void> writeSession(String value) =>
      _storage.write(key: _sessionKey, value: value);

  Future<String?> readSession() => _storage.read(key: _sessionKey);

  Future<void> deleteSession() => _storage.delete(key: _sessionKey);

  Future<void> setOnboardingComplete(bool value) => _storage.write(
        key: _onboardingKey,
        value: value.toString(),
      );

  Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  Future<void> setPreferredLanguage(String code) =>
      _storage.write(key: _languageKey, value: code);

  Future<String> getPreferredLanguage() async {
    final value = await _storage.read(key: _languageKey);
    return value ?? '';
  }

  Future<void> setUserRole(String role) => _storage.write(key: _roleKey, value: role);

  Future<UserRole> getUserRole() async {
    final value = await _storage.read(key: _roleKey);
    return UserRole.fromString(value);
  }

  Future<void> setThemeMode(ThemeMode mode) => _storage.write(
        key: _themeKey,
        value: mode == ThemeMode.dark ? 'dark' : 'light',
      );

  Future<ThemeMode> getThemeMode() async {
    final value = await _storage.read(key: _themeKey);
    return value == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
