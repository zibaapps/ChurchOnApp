import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tenant_billing.dart';

class BillingService {
  BillingService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _billingRef(String churchId) => _firestore.collection('churches').doc(churchId).collection('tenant_settings').doc('billing');

  Future<TenantBilling> fetch(String churchId) async {
    final snap = await _billingRef(churchId).get();
    return TenantBilling.fromMap(snap.data());
  }

  // Simple quotas per plan
  bool isOverQuota(TenantBilling b, {required String resource}) {
    switch (b.plan) {
      case TenantPlan.free:
        if (resource == 'events') return b.usage.eventsThisMonth >= 10;
        if (resource == 'sermons') return b.usage.sermonsThisMonth >= 10;
        if (resource == 'messages') return b.usage.messagesThisMonth >= 1000;
        return false;
      case TenantPlan.pro:
        if (resource == 'events') return b.usage.eventsThisMonth >= 100;
        if (resource == 'sermons') return b.usage.sermonsThisMonth >= 200;
        if (resource == 'messages') return b.usage.messagesThisMonth >= 20000;
        return false;
      case TenantPlan.enterprise:
        return false;
    }
  }
}