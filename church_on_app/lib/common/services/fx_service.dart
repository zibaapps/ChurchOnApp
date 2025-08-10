import 'dart:convert';
import 'package:http/http.dart' as http;

class FxService {
  Future<double?> fetchRate({required String base, required String target}) async {
    try {
      final uri = Uri.parse('https://api.exchangerate.host/latest?base=$base&symbols=$target');
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      final rate = (rates?[target] as num?)?.toDouble();
      return rate;
    } catch (_) {
      return null;
    }
  }

  String formatEquivalent(double amountBase, double rate, String target) {
    final eq = amountBase * rate;
    return '$target ${eq.toStringAsFixed(2)}';
    
  }
}