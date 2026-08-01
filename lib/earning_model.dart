class EarningModel {
  final String id;
  final double amount;
  final String formattedAmount; // Build lag se bachne ke liye pehle se formatted
  dynamic detail;

  EarningModel({
    required this.id,
    required this.amount,
    required this.formattedAmount,
    this.detail,
  });
}