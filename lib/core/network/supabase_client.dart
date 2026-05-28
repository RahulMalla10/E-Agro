import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService(this._client);

  final SupabaseClient _client;

  SupabaseClient get client => _client;

  bool get isAuthenticated => _client.auth.currentSession != null;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signInWithOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}

Future<SupabaseService?> initializeSupabase(AppConfig config) async {
  if (!config.isSupabaseConfigured) return null;

  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  return SupabaseService(Supabase.instance.client);
}

final supabaseServiceProvider = Provider<SupabaseService?>((ref) {
  throw UnimplementedError('Supabase must be overridden at bootstrap');
});
