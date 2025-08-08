import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/fees_service.dart';
import '../../common/services/payment_service.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/auth_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _amount = TextEditingController();
  String _method = 'momo'; // momo | paypal
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
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (ZMW)'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _method,
            items: const [
              DropdownMenuItem(value: 'momo', child: Text('Mobile Money')),
              DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
            ],
            onChanged: (v) => setState(() => _method = v ?? 'momo'),
            decoration: const InputDecoration(labelText: 'Method'),
          ),
          const SizedBox(height: 16),
          Text('Fee: K${fee.toStringAsFixed(2)}'),
          Text('Net to church: K${net.toStringAsFixed(2)}'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading || amt <= 0 || churchId == null || user == null
                ? null
                : () async {
                    setState(() => _loading = true);
                    final res = await PaymentService().processPayment(
                      churchId: churchId,
                      amountZMW: amt,
                      method: _method == 'momo' ? PaymentMethod.momo : PaymentMethod.paypal,
                      userId: user.uid,
                    );
                    if (!mounted) return;
                    setState(() => _loading = false);
                    if (res.success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${res.error}')));
                    }
                  },
            child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}