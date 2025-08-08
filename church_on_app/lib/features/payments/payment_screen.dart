import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/services/fees_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _amount = TextEditingController();
  String _method = 'momo'; // momo | paypal

  @override
  Widget build(BuildContext context) {
    final fees = const FeesService();
    final amt = double.tryParse(_amount.text) ?? 0;
    final fee = fees.computeFee(amt);
    final net = fees.netAmount(amt);

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
          FilledButton(onPressed: amt > 0 ? () {} : null, child: const Text('Proceed')),
        ],
      ),
    );
  }
}