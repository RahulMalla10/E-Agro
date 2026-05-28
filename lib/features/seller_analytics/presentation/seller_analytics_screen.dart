import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/widgets/drawer_menu_button.dart';
import 'package:krishi_smart/features/seller_analytics/data/seller_analytics_models.dart';

final sellerAnalyticsProvider = FutureProvider<SellerDashboardStats>((ref) async {
  return ref.read(sellerAnalyticsRepositoryProvider).loadDashboard();
});

class SellerAnalyticsScreen extends ConsumerWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final statsAsync = ref.watch(sellerAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerMenuButton(),
        title: Text(s.sellerAnalyticsTitle),
      ),
      body: statsAsync.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('$e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(sellerAnalyticsProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              _SummaryGrid(stats: stats, strings: s),
              const SizedBox(height: 20),
              _SectionTitle(icon: Icons.show_chart, title: s.salesTrendTitle),
              const SizedBox(height: 10),
              _SalesTrendChart(points: stats.salesTrend, nepali: s.isNepali),
              const SizedBox(height: 20),
              if (stats.topProducts.isNotEmpty) ...[
                _SectionTitle(icon: Icons.star_outline, title: s.topProductsTitle),
                const SizedBox(height: 8),
                _TopProductsList(rows: stats.topProducts, nepali: s.isNepali),
                const SizedBox(height: 20),
              ],
              _SectionTitle(icon: Icons.receipt_long_outlined, title: s.sellerOrdersTitle),
              const SizedBox(height: 8),
              _SellerOrdersSection(
                orders: stats.orders,
                strings: s,
                emptyLabel: s.sellerOrdersEmpty,
              ),
              const SizedBox(height: 20),
              _SectionTitle(icon: Icons.inventory_2_outlined, title: s.inventoryTitle),
              const SizedBox(height: 8),
              _InventorySection(
                items: stats.inventory,
                nepali: s.isNepali,
                emptyLabel: s.noListings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.stats, required this.strings});

  final SellerDashboardStats stats;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _StatCard(
          icon: Icons.payments_outlined,
          label: strings.analyticsRevenue,
          value: 'Rs ${stats.totalRevenueNpr.toStringAsFixed(0)}',
          color: const Color(0xFF2E7D32),
        ),
        _StatCard(
          icon: Icons.receipt_long_outlined,
          label: strings.analyticsOrders,
          value: '${stats.orderCount}',
          color: const Color(0xFF1565C0),
        ),
        _StatCard(
          icon: Icons.storefront_outlined,
          label: strings.analyticsActiveListings,
          value: '${stats.activeListings}',
          color: const Color(0xFF6A1B9A),
        ),
        _StatCard(
          icon: Icons.warning_amber_outlined,
          label: strings.analyticsLowStock,
          value: '${stats.lowStockCount}',
          subtitle: stats.outOfStockCount > 0 ? '${stats.outOfStockCount} ${strings.analyticsOutOfStock}' : null,
          color: const Color(0xFFE65100),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error)),
          ],
        ),
      ),
    );
  }
}

class _SalesTrendChart extends StatelessWidget {
  const _SalesTrendChart({required this.points, required this.nepali});

  final List<DailySalesPoint> points;
  final bool nepali;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = points.map((p) => p.revenueNpr).fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 1000.0 : maxY * 1.2;
    final dateFmt = DateFormat(nepali ? 'MM/dd' : 'd MMM');

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: SizedBox(
          height: 220,
          child: maxY <= 0
              ? Center(
                  child: Text(
                    nepali ? 'अहिले बिक्री डाटा छैन' : 'No sales data yet',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: chartMax / 4,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: theme.dividerColor,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (v, _) => Text(
                            'Rs ${v.toInt()}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            if (i < 0 || i >= points.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(dateFmt.format(points[i].date), style: theme.textTheme.labelSmall),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (points.length - 1).toDouble(),
                    minY: 0,
                    maxY: chartMax,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), points[i].revenueNpr),
                        ],
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _TopProductsList extends StatelessWidget {
  const _TopProductsList({required this.rows, required this.nepali});

  final List<ProductSalesRow> rows;
  final bool nepali;

  @override
  Widget build(BuildContext context) {
    final maxRev = rows.first.revenueNpr;
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final row = rows[i];
          final name = nepali && row.nameNe != null && row.nameNe!.isNotEmpty ? row.nameNe! : row.name;
          final pct = maxRev > 0 ? row.revenueNpr / maxRev : 0.0;
          return ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            trailing: Text(
              'Rs ${row.revenueNpr.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}

class _SellerOrdersSection extends StatelessWidget {
  const _SellerOrdersSection({
    required this.orders,
    required this.strings,
    required this.emptyLabel,
  });

  final List<SellerOrderDetail> orders;
  final AppStrings strings;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(emptyLabel)),
        ),
      );
    }

    final dateFmt = DateFormat(strings.isNepali ? 'yyyy/MM/dd HH:mm' : 'd MMM yyyy, HH:mm');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final order = orders[i];
          final productName = strings.isNepali &&
                  order.productNameNe != null &&
                  order.productNameNe!.isNotEmpty
              ? order.productNameNe!
              : order.productName;

          return ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(productName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'Rs ${order.totalNpr.toStringAsFixed(0)} · ${dateFmt.format(order.createdAt)}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.orderDetails,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _OrderField(label: strings.orderProduct, value: productName),
                    _OrderField(
                      label: strings.quantity,
                      value:
                          '${order.quantity.toStringAsFixed(order.quantity == order.quantity.roundToDouble() ? 0 : 1)} ${order.unit}',
                    ),
                    _OrderField(label: strings.total, value: 'Rs ${order.totalNpr.toStringAsFixed(0)}'),
                    if (order.esewaRef != null)
                      _OrderField(label: strings.reference, value: order.esewaRef!),
                    const SizedBox(height: 12),
                    Text(
                      strings.sellerBuyerDetails,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _OrderField(label: strings.fullName, value: order.buyerName),
                    _OrderField(label: strings.phone, value: order.buyerPhone),
                    _OrderField(label: strings.address, value: order.buyerAddress),
                    if (order.buyerLandmark != null && order.buyerLandmark!.isNotEmpty)
                      _OrderField(label: strings.landmark, value: order.buyerLandmark!),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderField extends StatelessWidget {
  const _OrderField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({
    required this.items,
    required this.nepali,
    required this.emptyLabel,
  });

  final List<InventoryStatusRow> items;
  final bool nepali;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(emptyLabel)),
        ),
      );
    }

    final maxStock = items.map((i) => i.stockQuantity).fold<double>(1, (a, b) => a > b ? a : b);

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = items[i];
          final name = nepali && item.nameNe != null && item.nameNe!.isNotEmpty ? item.nameNe! : item.name;
          final barValue = item.isOutOfStock ? 0.0 : (item.stockQuantity / maxStock).clamp(0.05, 1.0);
          final statusColor = item.isOutOfStock
              ? Colors.red
              : item.isLowStock
                  ? Colors.orange
                  : Colors.green;

          return ListTile(
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barValue,
                    minHeight: 8,
                    color: statusColor,
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.stockQuantity.toStringAsFixed(item.stockQuantity == item.stockQuantity.roundToDouble() ? 0 : 1)} ${item.stockUnit} · Rs ${item.priceNpr.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Icon(
              item.isOutOfStock ? Icons.remove_shopping_cart : Icons.inventory_2_outlined,
              color: statusColor,
            ),
          );
        },
      ),
    );
  }
}
