class FeesService {
  const FeesService({this.fixedFeeZMW = 0.5, this.percent = 0.05});
  final double fixedFeeZMW; // Minimum fee K0.50
  final double percent; // 5%

  double computeFee(double amountZMW) {
    final pct = amountZMW * percent;
    return pct < fixedFeeZMW ? fixedFeeZMW : pct;
  }

  double netAmount(double amountZMW) {
    final fee = computeFee(amountZMW);
    return (amountZMW - fee).clamp(0, double.infinity);
  }
}