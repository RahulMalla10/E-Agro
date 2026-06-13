import 'package:uuid/uuid.dart';
import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

class SellerReviewRepository {
  SellerReviewRepository(this._database);

  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<void> submitReview({
    required String sellerId,
    required int rating,
    String? comment,
    String? buyerId,
    String? productId,
  }) async {
    final review = SellerReview(
      id: _uuid.v4(),
      sellerId: sellerId,
      buyerId: buyerId,
      productId: productId,
      rating: rating.clamp(1, 5),
      comment: comment?.isEmpty ?? true ? null : comment,
      createdAt: DateTime.now(),
    );

    await _database.insertReview(review.toMap());
  }

  Future<List<SellerReview>> getReviewsForSeller(String sellerId) async {
    final rows = await _database.getReviewsForSeller(sellerId);
    return rows.map(SellerReview.fromMap).toList();
  }

  Future<double> getAverageRatingForSeller(String sellerId) async {
    return _database.getAverageRatingForSeller(sellerId);
  }

  Future<int> getReviewCountForSeller(String sellerId) async {
    return _database.getReviewCountForSeller(sellerId);
  }

  Future<List<SellerReview>> getReviewsForProduct(String productId) async {
    final rows = await _database.getReviewsForProduct(productId);
    return rows.map(SellerReview.fromMap).toList();
  }
}
