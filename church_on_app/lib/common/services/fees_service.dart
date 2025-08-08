class FeesService {
  const FeesService({this.fixedFeeZMW = 0.5, this.percent = 0.05});
  final double fixedFeeZMW; // K0.50
  final double percent; // 5%

  double computeFee(double amountZMW) {
    return fixedFeeZMW + (amountZMW * percent);
  }

  double netAmount(double amountZMW) {
    final fee = computeFee(amountZMW);
    return (amountZMW - fee).clamp(0, double.infinity);
  }
}