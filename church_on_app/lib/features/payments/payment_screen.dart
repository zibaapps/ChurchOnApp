import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/providers/analytics_providers.dart';

import '../../common/services/fees_service.dart';
import '../../common/services/payment_service.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/widgets/animations.dart';
import '../../common/services/fx_service.dart';
import '../../common/services/receipt_service.dart';
import '../../common/providers/tenant_info_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _amount = TextEditingController();
  final _msisdn = TextEditingController();
  String _method = 'mtn'; // mtn | airtel | paypal
  bool _loading = false;
  String? _fxUsd; // USD equivalent text
  bool _fxLoading = false;

  Future<void> _refreshFx() async {
    final amt = double.tryParse(_amount.text) ?? 0;
    if (amt <= 0) {
      setState(() => _fxUsd = null);
      return;
    }
    setState(() => _fxLoading = true);
    final rate = await FxService().fetchRate(base: 'ZMW', target: 'USD');
    if (!mounted) return;
    if (rate != null) {
      setState(() => _fxUsd = FxService().formatEquivalent(amt, rate, 'USD'));
    } else {
      setState(() => _fxUsd = null);
    }
    setState(() => _fxLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final fees = const FeesService();
    final amt = double.tryParse(_amount.text) ?? 0;
    final fee = fees.computeFee(amt);
    final net = fees.netAmount(amt);

    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (ZMW)'),
            onChanged: (_) async {
              setState(() {});
              await _refreshFx();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _msisdn, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number (MSISDN)')),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'mtn', label: Text('MTN'), icon: Icon(Icons.sim_card)),
              ButtonSegment(value: 'airtel', label: Text('Airtel'), icon: Icon(Icons.sim_card_alert)),
              ButtonSegment(value: 'paypal', label: Text('PayPal'), icon: Icon(Icons.account_balance_wallet)),
            ],
            selected: {_method},
            onSelectionChanged: (s) => setState(() => _method = s.first),
          ),
          const SizedBox(height: 16),
          Text('Fee: K${fee.toStringAsFixed(2)}'),
          Text('Net to church: K${net.toStringAsFixed(2)}'),
          if (_fxLoading) const Padding(padding: EdgeInsets.only(top: 8), child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))),
          if (!_fxLoading && _fxUsd != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Approx: $_fxUsd')),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _method == 'mtn' ? Theme.of(context).colorScheme.primary : null),
            onPressed: _loading || amt <= 0 || churchId == null || user == null || _msisdn.text.isEmpty || _method != 'mtn'
                ? null
                : () async {
                    setState(() => _loading = true);
                    await ref.read(analyticsServiceProvider).logGiveStart(churchId: churchId!, userId: user.uid, amount: amt, method: 'mtn');
                    final res = await PaymentService().processPayment(
                      churchId: churchId,
                      amountZMW: amt,
                      method: PaymentMethod.mtn,
                      userId: user.uid,
                      msisdn: _msisdn.text,
                    );
                    if (!mounted) return;
                    setState(() => _loading = false);
                    final msg = res.success ? 'MTN payment successful' : 'Payment failed: ${res.error}';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    if (res.success) {
                      await ref.read(analyticsServiceProvider).logGiveSuccess(churchId: churchId!, userId: user.uid, amount: amt, method: 'mtn', reference: res.reference);
                      final churchName = ref.read(tenantDisplayNameProvider);
                      final bytes = await ReceiptService().buildPaymentReceipt(
                        churchName: churchName,
                        userName: user.displayName ?? user.email ?? user.uid,
                        amountZmw: amt,
                        method: 'MTN',
                        reference: res.reference ?? '-',
                        createdAt: DateTime.now(),
                      );
                      await ReceiptService().sharePdf(bytes, filename: 'receipt_mtn.pdf');
                    }
                    if (res.success && mounted) await showSuccessAnimation(context, message: 'Thank you! Payment successful');
                  },
            icon: const Icon(Icons.payments),
            label: _loading && _method == 'mtn'
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Pay with MTN'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _method == 'airtel' ? Theme.of(context).colorScheme.primary : null),
            onPressed: _loading || amt <= 0 || churchId == null || user == null || _msisdn.text.isEmpty || _method != 'airtel'
                ? null
                : () async {
                    setState(() => _loading = true);
                    await ref.read(analyticsServiceProvider).logGiveStart(churchId: churchId!, userId: user.uid, amount: amt, method: 'airtel');
                    final res = await PaymentService().processPayment(
                      churchId: churchId,
                      amountZMW: amt,
                      method: PaymentMethod.airtel,
                      userId: user.uid,
                      msisdn: _msisdn.text,
                    );
                    if (!mounted) return;
                    setState(() => _loading = false);
                    final msg = res.success ? 'Airtel payment successful' : 'Payment failed: ${res.error}';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    if (res.success) {
                      await ref.read(analyticsServiceProvider).logGiveSuccess(churchId: churchId!, userId: user.uid, amount: amt, method: 'airtel', reference: res.reference);
                      final churchName = ref.read(tenantDisplayNameProvider);
                      final bytes = await ReceiptService().buildPaymentReceipt(
                        churchName: churchName,
                        userName: user.displayName ?? user.email ?? user.uid,
                        amountZmw: amt,
                        method: 'Airtel',
                        reference: res.reference ?? '-',
                        createdAt: DateTime.now(),
                      );
                      await ReceiptService().sharePdf(bytes, filename: 'receipt_airtel.pdf');
                    }
                    if (res.success && mounted) await showSuccessAnimation(context, message: 'Thank you! Payment successful');
                  },
            icon: const Icon(Icons.payments_outlined),
            label: _loading && _method == 'airtel'
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Pay with Airtel'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _method == 'paypal' ? Theme.of(context).colorScheme.primary : null),
            onPressed: null, // Implement PayPal integration when ready
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Pay with PayPal (coming soon)'),
          ),
        ],
      ),
    );
  }
}

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (churchId == null || user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final stream = PaymentService().streamPaymentHistory(churchId, user.uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          final items = snap.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) return const Center(child: Text('No payments'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = items[i];
              return ListTile(
                title: Text('${p['method']} • K${(p['amount'] as num).toStringAsFixed(2)}'),
                subtitle: Text('Status: ${p['status']}\nRef: ${p['reference']}'),
                isThreeLine: true,
                trailing: Text((p['createdAt'] as String?)?.split('T').first ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}