import 'dart:io';

import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  ProductRepository(this._database);

  final AppDatabase _database;

  Future<List<FarmerProduct>> getListings({bool inStockOnly = true}) async {
    final rows = await _database.getProducts();
    var products = rows.map(FarmerProduct.fromMap).toList();
    if (inStockOnly) {
      products = products.where((p) => p.inStock).toList();
    }
    return products;
  }

  Future<FarmerProduct?> getById(String id) async {
    final row = await _database.getProductById(id);
    return row == null ? null : FarmerProduct.fromMap(row);
  }

  Future<FarmerProduct> createListing({
    required String name,
    required String nameNe,
    required ProductCategory category,
    required List<File> images,
    required double stockQuantity,
    required String stockUnit,
    required double priceNpr,
    String? sellerId,
  }) async {
    if (images.length < 2 || images.length > 5) {
      throw ArgumentError('Upload 2 to 5 photos');
    }
    if (stockQuantity <= 0 || priceNpr <= 0) {
      throw ArgumentError('Stock and price must be greater than zero');
    }

    final id = const Uuid().v4();
    final imagePaths = await _saveImages(id, images);

    final product = FarmerProduct(
      id: id,
      name: name.trim(),
      nameNe: nameNe.trim(),
      category: category,
      imagePaths: imagePaths,
      stockQuantity: stockQuantity,
      stockUnit: stockUnit,
      priceNpr: priceNpr,
      sellerId: sellerId,
      createdAt: DateTime.now(),
    );

    await _database.insertProduct(product.toMap());
    return product;
  }

  Future<List<String>> _saveImages(String productId, List<File> images) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/product_images/$productId');
    if (!await folder.exists()) await folder.create(recursive: true);

    final paths = <String>[];
    for (var i = 0; i < images.length; i++) {
      final ext = images[i].path.split('.').last;
      final dest = '${folder.path}/$i.$ext';
      await images[i].copy(dest);
      paths.add(dest);
    }
    return paths;
  }

  Future<MarketplaceOrder> placeOrder({
    required FarmerProduct product,
    required double quantity,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    String? buyerLandmark,
    required String esewaRef,
  }) async {
    if (quantity <= 0 || quantity > product.stockQuantity) {
      throw ArgumentError('Invalid quantity');
    }

    final total = quantity * product.priceNpr;
    final orderId = const Uuid().v4();
    final order = MarketplaceOrder(
      id: orderId,
      productId: product.id,
      quantity: quantity,
      unit: product.stockUnit,
      unitPriceNpr: product.priceNpr,
      totalNpr: total,
      buyerName: buyerName.trim(),
      buyerPhone: buyerPhone.trim(),
      buyerAddress: buyerAddress.trim(),
      buyerLandmark: buyerLandmark?.trim(),
      paymentStatus: 'paid',
      esewaRef: esewaRef,
      createdAt: DateTime.now(),
    );

    await _database.insertOrder({
      'id': order.id,
      'product_id': order.productId,
      'quantity': order.quantity,
      'unit': order.unit,
      'unit_price_npr': order.unitPriceNpr,
      'total_npr': order.totalNpr,
      'buyer_name': order.buyerName,
      'buyer_phone': order.buyerPhone,
      'buyer_address': order.buyerAddress,
      'buyer_landmark': order.buyerLandmark,
      'payment_status': order.paymentStatus,
      'esewa_ref': order.esewaRef,
      'created_at': order.createdAt.toIso8601String(),
    });

    await _database.updateProductStock(
      product.id,
      product.stockQuantity - quantity,
    );

    return order;
  }
}
