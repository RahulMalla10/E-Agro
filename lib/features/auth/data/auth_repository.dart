import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/errors/app_exception.dart';
import 'package:krishi_smart/core/network/supabase_client.dart';
import 'package:krishi_smart/core/security/secure_storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  AuthRepository({
    required SupabaseService? supabase,
    required SecureStorageService secureStorage,
    required AppDatabase database,
  }) : _supabase = supabase,
       _secureStorage = secureStorage,
       _database = database;

  final SupabaseService? _supabase;
  final SecureStorageService _secureStorage;
  final AppDatabase _database;

  Future<bool> isOnboardingComplete() => _secureStorage.isOnboardingComplete();

  /// First launch: skip wizard screens; defaults (Nepali, buyer). Permissions asked later.
  Future<void> ensureInitialSetup() async {
    if (await isOnboardingComplete()) return;

    const language = 'ne';
    const role = UserRole.buyer;

    await _secureStorage.setOnboardingComplete(true);
    await _secureStorage.setPreferredLanguage(language);
    await _secureStorage.setUserRole(role.storageValue);
    await _database.upsertFarmerProfile({
      'id': const Uuid().v4(),
      'consent_location': 0,
      'consent_photos': 0,
      'preferred_language': language,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> completeOnboarding({
    required bool consentLocation,
    required bool consentPhotos,
    required String preferredLanguage,
    required UserRole userRole,
  }) async {
    await _secureStorage.setOnboardingComplete(true);
    await _secureStorage.setPreferredLanguage(preferredLanguage);
    await _secureStorage.setUserRole(userRole.storageValue);
    await _database.upsertFarmerProfile({
      'id': const Uuid().v4(),
      'consent_location': consentLocation ? 1 : 0,
      'consent_photos': consentPhotos ? 1 : 0,
      'preferred_language': preferredLanguage,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isLoggedIn() async {
    final session = await _secureStorage.readSession();
    if (session != null && session.isNotEmpty) return true;
    return _supabase?.isAuthenticated ?? false;
  }

  Future<void> sendOtp(String phone) async {
    final normalized = _normalizePhone(phone);
    if (_supabase != null) {
      await _supabase.signInWithOtp(normalized);
      return;
    }
    // Offline/dev mode: accept any phone for local MVP testing
    await _secureStorage.writeSession('dev:$normalized');
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    final normalized = _normalizePhone(phone);
    if (_supabase != null) {
      final response = await _supabase.verifyOtp(phone: normalized, token: otp);
      final session = response.session;
      if (session == null) {
        throw const AuthException('Invalid OTP. Please try again.');
      }
      await _secureStorage.writeSession(session.accessToken);
      return;
    }
    if (otp != '1234') {
      throw const AuthException('Invalid OTP. Use 1234 in dev mode.');
    }
    await _secureStorage.writeSession('dev:$normalized');
  }

  Future<void> signOut() async {
    await _secureStorage.deleteSession();
    await _supabase?.signOut();
  }

  Future<void> updateUserRole(UserRole role) async {
    await _secureStorage.setUserRole(role.storageValue);
  }

  /// Clears session and onboarding; user picks role again (language/theme kept).
  Future<void> logout() async {
    await signOut();
    await _secureStorage.setOnboardingComplete(false);
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('977')) return '+$digits';
    if (digits.length == 10) return '+977$digits';
    return '+$digits';
  }
}
