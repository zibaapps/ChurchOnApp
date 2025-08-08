import 'package:cloud_firestore/cloud_firestore.dart';

import 'fees_service.dart';

enum PaymentMethod { momo, paypal }

class PaymentResult {
  PaymentResult({required this.success, this.error});
  final bool success;
  final String? error;
}

class PaymentService {
  PaymentService({FirebaseFirestore? firestore, FeesService? feesService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _fees = feesService ?? const FeesService();

  final FirebaseFirestore _firestore;
  final FeesService _fees;

  Future<PaymentResult> processPayment({
    required String churchId,
    required double amountZMW,
    required PaymentMethod method,
    required String userId,
  }) async {
    try {
      // TODO: Integrate real SDKs/APIs. For now, simulate success.
      final success = true;
      if (!success) return PaymentResult(success: false, error: 'Payment failed');

      final fee = _fees.computeFee(amountZMW);
      final net = _fees.netAmount(amountZMW);

      await _firestore.collection('churches').doc(churchId).collection('payments').add({
        'userId': userId,
        'amount': amountZMW,
        'fee': fee,
        'netAmount': net,
        'method': method.name,
        'status': 'success',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      // Superadmin ledger (aggregate)
      await _firestore.collection('superadmin_ledger').add({
        'churchId': churchId,
        'fee': fee,
        'source': method.name,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      return PaymentResult(success: true);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }
}