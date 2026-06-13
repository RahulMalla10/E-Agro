import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

final sellerAverageRatingProvider = FutureProvider.family<double, String>((
  ref,
  sellerId,
) async {
  return ref
      .watch(sellerReviewRepositoryProvider)
      .getAverageRatingForSeller(sellerId);
});

final sellerReviewCountProvider = FutureProvider.family<int, String>((
  ref,
  sellerId,
) async {
  return ref
      .watch(sellerReviewRepositoryProvider)
      .getReviewCountForSeller(sellerId);
});

final sellerReviewsProvider = FutureProvider.family<List<SellerReview>, String>(
  (ref, sellerId) async {
    return ref
        .watch(sellerReviewRepositoryProvider)
        .getReviewsForSeller(sellerId);
  },
);

final productReviewsProvider =
    FutureProvider.family<List<SellerReview>, String>((ref, productId) async {
      return ref
          .watch(sellerReviewRepositoryProvider)
          .getReviewsForProduct(productId);
    });
