import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';
import 'package:krishi_smart/features/trading/presentation/product_detail_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final double quantity;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _landmark = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _proceed(FarmerProduct product) {
    final s = ref.read(stringsProvider);
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.checkoutFieldsRequired)),
      );
      return;
    }

    context.push(
      '${AppRoutes.esewaPay}?id=${product.id}&qty=${widget.quantity}'
      '&name=${Uri.encodeComponent(_name.text.trim())}'
      '&phone=${Uri.encodeComponent(_phone.text.trim())}'
      '&address=${Uri.encodeComponent(_address.text.trim())}'
      '&landmark=${Uri.encodeComponent(_landmark.text.trim())}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.checkout)),
      body: productAsync.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('$e')),
        data: (product) {
          if (product == null) return Center(child: Text(s.productNotFound));

          final u = StockUnit.byId(product.stockUnit);
          final total = widget.quantity * product.priceNpr;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(s.orderSummary, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(product.displayName(s.isNepali)),
              Text(
                '${widget.quantity.toStringAsFixed(widget.quantity == widget.quantity.roundToDouble() ? 0 : 1)} ${s.isNepali ? u.labelNe : u.id} × Rs ${product.priceNpr.toStringAsFixed(0)}',
              ),
              Text(
                '${s.total}: Rs ${total.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              Text(s.buyerDetails, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: s.fullName),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: s.phone),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _address,
                decoration: InputDecoration(labelText: s.address),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _landmark,
                decoration: InputDecoration(labelText: s.landmark),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => _proceed(product),
                child: Text(s.proceedToEsewa),
              ),
            ],
          );
        },
      ),
    );
  }
}
