import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/fees_service.dart';
import '../../common/services/payment_service.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/widgets/animations.dart';

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
          TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (ZMW)'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          TextFormField(controller: _msisdn, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number (MSISDN)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _method,
            items: const [
              DropdownMenuItem(value: 'mtn', child: Text('MTN MoMo')),
              DropdownMenuItem(value: 'airtel', child: Text('Airtel Money')),
              DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
            ],
            onChanged: (v) => setState(() => _method = v ?? 'mtn'),
            decoration: const InputDecoration(labelText: 'Method'),
          ),
          const SizedBox(height: 16),
          Text('Fee: K${fee.toStringAsFixed(2)}'),
          Text('Net to church: K${net.toStringAsFixed(2)}'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loading || amt <= 0 || churchId == null || user == null || _msisdn.text.isEmpty || _method != 'mtn'
                ? null
                : () async {
                    setState(() => _loading = true);
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
                    if (res.success && mounted) await showSuccessAnimation(context, message: 'Thank you! Payment successful');
                  },
            icon: const Icon(Icons.payments),
            label: _loading && _method == 'mtn'
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Pay with MTN'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading || amt <= 0 || churchId == null || user == null || _msisdn.text.isEmpty || _method != 'airtel'
                ? null
                : () async {
                    setState(() => _loading = true);
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
                    if (res.success && mounted) await showSuccessAnimation(context, message: 'Thank you! Payment successful');
                  },
            icon: const Icon(Icons.payments_outlined),
            label: _loading && _method == 'airtel'
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Pay with Airtel'),
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