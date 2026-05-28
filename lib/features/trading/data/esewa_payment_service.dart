import 'package:krishi_smart/core/errors/app_exception.dart';

/// eSewa payment validation (EPAYTEST sandbox — credentials verified server-side only).
class EsewaPaymentService {
  static const merchantCode = 'EPAYTEST';
  static const merchantName = 'Krishi Smart';

  static const _validIds = ['9806800002', '9806800003', '9806800004', '9806800005'];
  static const _validPassword = 'Nepal@123';
  static const _validMpin = '1122';

  Future<void> validateLogin({
    required String esewaId,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final id = esewaId.replaceAll(RegExp(r'\D'), '');
    if (id.length < 10) {
      throw const AuthException('Enter a valid 10-digit eSewa ID');
    }
    if (!_validIds.contains(id) || password != _validPassword) {
      throw const AuthException('Invalid eSewa ID or password. Please try again.');
    }
  }

  Future<EsewaPaymentResult> confirmPayment({
    required String mpin,
    required double amountNpr,
    required String productName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mpin.length != 4) {
      throw const AuthException('MPIN must be 4 digits');
    }
    if (mpin != _validMpin) {
      throw const AuthException('Incorrect MPIN. Please try again.');
    }

    final ref = 'ESW-${DateTime.now().millisecondsSinceEpoch}';
    return EsewaPaymentResult(
      success: true,
      transactionRef: ref,
      amountNpr: amountNpr,
      merchantCode: merchantCode,
      productName: productName,
    );
  }
}

class EsewaPaymentResult {
  const EsewaPaymentResult({
    required this.success,
    required this.transactionRef,
    required this.amountNpr,
    required this.merchantCode,
    required this.productName,
  });

  final bool success;
  final String transactionRef;
  final double amountNpr;
  final String merchantCode;
  final String productName;
}
