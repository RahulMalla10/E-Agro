import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/features/seller_analytics/data/seller_analytics_models.dart';

class SellerAnalyticsRepository {
  SellerAnalyticsRepository(this._database);

  final AppDatabase _database;

  static const defaultSellerId = 'local-seller';

  Future<SellerDashboardStats> loadDashboard({String sellerId = defaultSellerId}) async {
    final orderRows = await _database.getOrdersForSeller(sellerId);
    final productRows = await _database.getProductsForSeller(sellerId);

    var totalRevenue = 0.0;
    final productRevenue = <String, double>{};
    final productUnits = <String, double>{};
    final productNames = <String, String>{};
    final productNamesNe = <String, String?>{};

    for (final row in orderRows) {
      if (row['payment_status'] != 'paid') continue;
      final total = (row['total_npr'] as num).toDouble();
      totalRevenue += total;
      final pid = row['product_id'] as String;
      productRevenue[pid] = (productRevenue[pid] ?? 0) + total;
      productUnits[pid] = (productUnits[pid] ?? 0) + (row['quantity'] as num).toDouble();
      productNames[pid] = row['product_name'] as String? ?? pid;
      productNamesNe[pid] = row['product_name_ne'] as String?;
    }

    final salesTrend = _buildSalesTrend(orderRows);
    final topProducts = productRevenue.entries
        .map(
          (e) => ProductSalesRow(
            productId: e.key,
            name: productNames[e.key] ?? e.key,
            nameNe: productNamesNe[e.key],
            revenueNpr: e.value,
            unitsSold: productUnits[e.key] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.revenueNpr.compareTo(a.revenueNpr));

    final inventory = productRows
        .map(
          (r) => InventoryStatusRow(
            productId: r['id'] as String,
            name: r['name'] as String,
            nameNe: r['name_ne'] as String?,
            stockQuantity: (r['stock_quantity'] as num).toDouble(),
            stockUnit: r['stock_unit'] as String? ?? 'kg',
            priceNpr: (r['price_npr'] as num).toDouble(),
            category: r['category'] as String? ?? 'vegetables',
          ),
        )
        .toList();

    final lowStock = inventory.where((i) => i.isLowStock).length;
    final outOfStock = inventory.where((i) => i.isOutOfStock).length;

    final orders = orderRows
        .where((r) => r['payment_status'] == 'paid')
        .map(
          (r) => SellerOrderDetail(
            id: r['id'] as String,
            productName: r['product_name'] as String? ?? '',
            productNameNe: r['product_name_ne'] as String?,
            quantity: (r['quantity'] as num).toDouble(),
            unit: r['unit'] as String? ?? 'kg',
            totalNpr: (r['total_npr'] as num).toDouble(),
            buyerName: r['buyer_name'] as String,
            buyerPhone: r['buyer_phone'] as String,
            buyerAddress: r['buyer_address'] as String,
            buyerLandmark: r['buyer_landmark'] as String?,
            esewaRef: r['esewa_ref'] as String?,
            createdAt: DateTime.parse(r['created_at'] as String),
          ),
        )
        .toList();

    return SellerDashboardStats(
      totalRevenueNpr: totalRevenue,
      orderCount: orders.length,
      activeListings: inventory.where((i) => !i.isOutOfStock).length,
      lowStockCount: lowStock,
      outOfStockCount: outOfStock,
      salesTrend: salesTrend,
      topProducts: topProducts.take(5).toList(),
      inventory: inventory,
      orders: orders,
    );
  }

  List<DailySalesPoint> _buildSalesTrend(List<Map<String, Object?>> orders) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      return d;
    });

    final revenueByDay = {for (final d in days) d: 0.0};
    final countByDay = {for (final d in days) d: 0};

    for (final row in orders) {
      if (row['payment_status'] != 'paid') continue;
      final created = DateTime.parse(row['created_at'] as String);
      final day = DateTime(created.year, created.month, created.day);
      if (!revenueByDay.containsKey(day)) continue;
      revenueByDay[day] = revenueByDay[day]! + (row['total_npr'] as num).toDouble();
      countByDay[day] = countByDay[day]! + 1;
    }

    return days
        .map(
          (d) => DailySalesPoint(
            date: d,
            revenueNpr: revenueByDay[d] ?? 0,
            orderCount: countByDay[d] ?? 0,
          ),
        )
        .toList();
  }
}
