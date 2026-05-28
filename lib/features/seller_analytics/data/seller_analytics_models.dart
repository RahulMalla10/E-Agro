class DailySalesPoint {
  const DailySalesPoint({
    required this.date,
    required this.revenueNpr,
    required this.orderCount,
  });

  final DateTime date;
  final double revenueNpr;
  final int orderCount;
}

class ProductSalesRow {
  const ProductSalesRow({
    required this.productId,
    required this.name,
    this.nameNe,
    required this.revenueNpr,
    required this.unitsSold,
  });

  final String productId;
  final String name;
  final String? nameNe;
  final double revenueNpr;
  final double unitsSold;
}

class InventoryStatusRow {
  const InventoryStatusRow({
    required this.productId,
    required this.name,
    this.nameNe,
    required this.stockQuantity,
    required this.stockUnit,
    required this.priceNpr,
    required this.category,
  });

  final String productId;
  final String name;
  final String? nameNe;
  final double stockQuantity;
  final String stockUnit;
  final double priceNpr;
  final String category;

  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;
  bool get isOutOfStock => stockQuantity <= 0;
}

class SellerOrderDetail {
  const SellerOrderDetail({
    required this.id,
    required this.productName,
    this.productNameNe,
    required this.quantity,
    required this.unit,
    required this.totalNpr,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    this.buyerLandmark,
    this.esewaRef,
    required this.createdAt,
  });

  final String id;
  final String productName;
  final String? productNameNe;
  final double quantity;
  final String unit;
  final double totalNpr;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String? buyerLandmark;
  final String? esewaRef;
  final DateTime createdAt;
}

class SellerDashboardStats {
  const SellerDashboardStats({
    required this.totalRevenueNpr,
    required this.orderCount,
    required this.activeListings,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.salesTrend,
    required this.topProducts,
    required this.inventory,
    required this.orders,
  });

  final double totalRevenueNpr;
  final int orderCount;
  final int activeListings;
  final int lowStockCount;
  final int outOfStockCount;
  final List<DailySalesPoint> salesTrend;
  final List<ProductSalesRow> topProducts;
  final List<InventoryStatusRow> inventory;
  final List<SellerOrderDetail> orders;
}
