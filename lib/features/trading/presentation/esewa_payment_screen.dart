import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:krishi_smart/core/errors/app_exception.dart';
import 'package:krishi_smart/core/l10n/app_strings.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/core/routing/app_router.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';
import 'package:krishi_smart/features/home/presentation/home_screen.dart';
import 'package:krishi_smart/features/seller_analytics/presentation/seller_analytics_screen.dart';
import 'package:krishi_smart/features/trading/data/esewa_payment_service.dart';
import 'package:krishi_smart/features/trading/presentation/product_detail_screen.dart';

final esewaServiceProvider = Provider<EsewaPaymentService>((ref) => EsewaPaymentService());

/// eSewa brand green (sandbox UI).
const _esewaGreen = Color(0xFF5CB85C);
const _esewaGreenDark = Color(0xFF3D9A3D);

enum _EsewaStep { login, mpin, confirm, success }

class EsewaPaymentScreen extends ConsumerStatefulWidget {
  const EsewaPaymentScreen({
    super.key,
    required this.productId,
    required this.quantity,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.buyerLandmark,
  });

  final String productId;
  final double quantity;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String buyerLandmark;

  @override
  ConsumerState<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends ConsumerState<EsewaPaymentScreen> {
  _EsewaStep _step = _EsewaStep.login;
  final _esewaId = TextEditingController();
  final _password = TextEditingController();
  final _mpin = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;
  String? _txnRef;
  FarmerProduct? _product;

  @override
  void dispose() {
    _esewaId.dispose();
    _password.dispose();
    _mpin.dispose();
    super.dispose();
  }

  double get _total =>
      (_product?.priceNpr ?? 0) * widget.quantity;

  Future<void> _submitLogin() async {
    final s = ref.read(stringsProvider);
    if (_esewaId.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = s.esewaEnterCredentials);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(esewaServiceProvider).validateLogin(
            esewaId: _esewaId.text.trim(),
            password: _password.text,
          );
      if (mounted) setState(() => _step = _EsewaStep.mpin);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitMpin() async {
    if (_mpin.text.length != 4) {
      setState(() => _error = ref.read(stringsProvider).esewaMpinInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      setState(() => _step = _EsewaStep.confirm);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmPay() async {
    final product = _product;
    if (product == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(esewaServiceProvider).confirmPayment(
            mpin: _mpin.text,
            amountNpr: _total,
            productName: product.name,
          );

      await ref.read(productRepositoryProvider).placeOrder(
            product: product,
            quantity: widget.quantity,
            buyerName: widget.buyerName,
            buyerPhone: widget.buyerPhone,
            buyerAddress: widget.buyerAddress,
            buyerLandmark: widget.buyerLandmark.isEmpty ? null : widget.buyerLandmark,
            esewaRef: result.transactionRef,
          );

      ref.invalidate(productsProvider);
      ref.invalidate(productDetailProvider(widget.productId));
      ref.invalidate(sellerAnalyticsProvider);

      setState(() {
        _step = _EsewaStep.success;
        _txnRef = result.transactionRef;
      });
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _step = _EsewaStep.mpin;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: _esewaGreen,
        foregroundColor: Colors.white,
        title: Text(s.payWithEsewa),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: productAsync.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('$e')),
        data: (product) {
          if (product == null) return Center(child: Text(s.productNotFound));
          _product ??= product;

          return Column(
            children: [
              _EsewaHeader(amount: _total, step: _step, strings: s),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _buildStep(context, s, product),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppStrings s, FarmerProduct product) {
    return switch (_step) {
      _EsewaStep.login => _loginStep(context, s),
      _EsewaStep.mpin => _mpinStep(context, s),
      _EsewaStep.confirm => _confirmStep(context, s, product),
      _EsewaStep.success => _successStep(context, s),
    };
  }

  Widget _loginStep(BuildContext context, AppStrings s) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.esewaLoginTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(s.esewaLoginSubtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        TextField(
          controller: _esewaId,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            labelText: s.esewaIdLabel,
            prefixIcon: const Icon(Icons.phone_android_outlined),
            filled: true,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _password,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: s.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        _EsewaPrimaryButton(
          label: s.esewaLoginButton,
          loading: _loading,
          onPressed: _submitLogin,
        ),
      ],
    );
  }

  Widget _mpinStep(BuildContext context, AppStrings s) {
    return Column(
      key: const ValueKey('mpin'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.esewaMpinTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(s.esewaMpinSubtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        TextField(
          controller: _mpin,
          keyboardType: TextInputType.number,
          obscureText: true,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 12),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            labelText: s.esewaMpinLabel,
            filled: true,
            counterText: '',
          ),
          onSubmitted: (_) => _submitMpin(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        _EsewaPrimaryButton(
          label: s.btnContinue,
          loading: _loading,
          onPressed: _submitMpin,
        ),
        TextButton(
          onPressed: () => setState(() {
            _step = _EsewaStep.login;
            _error = null;
          }),
          child: Text(s.btnBack),
        ),
      ],
    );
  }

  Widget _confirmStep(BuildContext context, AppStrings s, FarmerProduct product) {
    final unit = StockUnit.byId(product.stockUnit);
    return Column(
      key: const ValueKey('confirm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.esewaConfirmTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(s.merchant, EsewaPaymentService.merchantName),
                _row(s.amount, 'Rs ${_total.toStringAsFixed(0)}'),
                _row(s.orderSummary, product.displayName(s.isNepali)),
                _row(
                  s.quantity,
                  '${widget.quantity.toStringAsFixed(widget.quantity == widget.quantity.roundToDouble() ? 0 : 1)} ${s.isNepali ? unit.labelNe : unit.id}',
                ),
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        _EsewaPrimaryButton(
          label: s.esewaPayNow,
          loading: _loading,
          onPressed: _confirmPay,
        ),
        TextButton(
          onPressed: () => setState(() {
            _step = _EsewaStep.mpin;
            _error = null;
          }),
          child: Text(s.btnBack),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _successStep(BuildContext context, AppStrings s) {
    return Column(
      key: const ValueKey('success'),
      children: [
        const SizedBox(height: 24),
        Icon(Icons.check_circle, size: 80, color: _esewaGreen),
        const SizedBox(height: 20),
        Text(s.paymentSuccess, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          '${s.reference}: $_txnRef',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _EsewaPrimaryButton(
          label: s.backToHome,
          loading: false,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}

class _EsewaHeader extends StatelessWidget {
  const _EsewaHeader({
    required this.amount,
    required this.step,
    required this.strings,
  });

  final double amount;
  final _EsewaStep step;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_esewaGreen, _esewaGreenDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'eSewa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Rs ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StepIndicator(step: step),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final _EsewaStep step;

  @override
  Widget build(BuildContext context) {
    final index = switch (step) {
      _EsewaStep.login => 0,
      _EsewaStep.mpin => 1,
      _EsewaStep.confirm => 2,
      _EsewaStep.success => 3,
    };

    return Row(
      children: List.generate(4, (i) {
        final active = i <= index;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _EsewaPrimaryButton extends StatelessWidget {
  const _EsewaPrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _esewaGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
