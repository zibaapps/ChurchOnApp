import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'fees_service.dart';
import 'payments/mtn_momo_provider.dart';
import 'payments/airtel_money_provider.dart';

enum PaymentMethod { mtn, airtel, paypal }

class PaymentResult {
  PaymentResult({required this.success, this.error, this.reference});
  final bool success;
  final String? error;
  final String? reference;
}

class PaymentService {
  PaymentService({FirebaseFirestore? firestore, FeesService? feesService, MtnMomoProvider? mtn, AirtelMoneyProvider? airtel})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _fees = feesService ?? const FeesService(),
        _mtn = mtn,
        _airtel = airtel;

  final FirebaseFirestore _firestore;
  final FeesService _fees;
  final MtnMomoProvider? _mtn;
  final AirtelMoneyProvider? _airtel;

  Future<PaymentResult> processPayment({
    required String churchId,
    required double amountZMW,
    required PaymentMethod method,
    required String userId,
    String? msisdn,
  }) async {
    try {
      final fee = _fees.computeFee(amountZMW);
      final net = _fees.netAmount(amountZMW);
      final now = DateTime.now().toUtc();
      final ref = _firestore.collection('churches').doc(churchId).collection('payments').doc();
      final reference = ref.id;

      String status = 'pending';
      String providerRef = reference;

      if (method == PaymentMethod.mtn) {
        if (_mtn == null) throw Exception('MTN provider not configured');
        providerRef = await _mtn!.initiatePayment(reference: reference, payerMsisdn: msisdn ?? '', amountZMW: amountZMW, currency: 'ZMW');
      } else if (method == PaymentMethod.airtel) {
        if (_airtel == null) throw Exception('Airtel provider not configured');
        providerRef = await _airtel!.initiatePayment(reference: reference, payerMsisdn: msisdn ?? '', amountZMW: amountZMW, currency: 'ZMW');
      } else {
        // Placeholder PayPal
        status = 'success';
      }

      await ref.set({
        'userId': userId,
        'amount': amountZMW,
        'fee': fee,
        'netAmount': net,
        'method': method.name,
        'status': status,
        'reference': reference,
        'providerRef': providerRef,
        'createdAt': now.toIso8601String(),
      });

      if (status == 'success') {
        await _firestore.collection('superadmin_ledger').add({
          'churchId': churchId,
          'fee': fee,
          'source': method.name,
          'createdAt': now.toIso8601String(),
        });
        return PaymentResult(success: true, reference: reference);
      }

      // Poll provider until success/failed (simple client-side polling; replace with webhook in production)
      if (method == PaymentMethod.mtn || method == PaymentMethod.airtel) {
        for (int i = 0; i < 12; i++) { // up to ~60s
          await Future.delayed(const Duration(seconds: 5));
          final s = method == PaymentMethod.mtn ? await _mtn!.checkStatus(providerRef) : await _airtel!.checkStatus(providerRef);
          if (s == 'success' || s == 'failed') {
            status = s;
            break;
          }
        }

        await ref.update({'status': status, 'updatedAt': DateTime.now().toUtc().toIso8601String()});
        if (status == 'success') {
          await _firestore.collection('superadmin_ledger').add({
            'churchId': churchId,
            'fee': fee,
            'source': method.name,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          });
          return PaymentResult(success: true, reference: reference);
        }
        return PaymentResult(success: false, error: 'Payment failed or timed out', reference: reference);
      }

      return PaymentResult(success: true, reference: reference);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  Stream<List<Map<String, dynamic>>> streamPaymentHistory(String churchId, String userId) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}