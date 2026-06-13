import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/config/app_config.dart';
import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/core/network/supabase_client.dart';
import 'package:krishi_smart/core/security/crypto_service.dart';
import 'package:krishi_smart/core/security/permission_service.dart';
import 'package:krishi_smart/core/security/secure_storage_service.dart';
import 'package:krishi_smart/features/auth/data/auth_repository.dart';
import 'package:krishi_smart/features/crop_advisor/data/crop_advisor_repository.dart';
import 'package:krishi_smart/features/disease_detection/data/disease_repository.dart';
import 'package:krishi_smart/features/home/data/product_repository.dart';
import 'package:krishi_smart/features/home/data/seller_review_repository.dart';
import 'package:krishi_smart/features/seller_analytics/data/seller_analytics_repository.dart';
import 'package:krishi_smart/features/news/data/news_repository.dart';
import 'package:krishi_smart/features/weather/data/weather_repository.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden at bootstrap');
});

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final cryptoServiceProvider = Provider<CryptoService>((ref) => CryptoService());

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('AppDatabase must be overridden at bootstrap');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    supabase: ref.watch(supabaseServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    database: ref.watch(appDatabaseProvider),
  );
});

final cropAdvisorRepositoryProvider = Provider<CropAdvisorRepository>((ref) {
  return CropAdvisorRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(appDatabaseProvider));
});

final sellerAnalyticsRepositoryProvider = Provider<SellerAnalyticsRepository>((
  ref,
) {
  return SellerAnalyticsRepository(ref.watch(appDatabaseProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
  return DiseaseRepository(
    database: ref.watch(appDatabaseProvider),
    permissions: ref.watch(permissionServiceProvider),
  );
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(config: ref.watch(appConfigProvider));
});

final sellerReviewRepositoryProvider = Provider<SellerReviewRepository>((ref) {
  return SellerReviewRepository(ref.watch(appDatabaseProvider));
});
