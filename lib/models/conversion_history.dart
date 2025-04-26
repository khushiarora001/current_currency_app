class ConversionHistory {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double convertedAmount;
  ConversionHistory({
    required this.amount,
    required this.convertedAmount,
    required this.fromCurrency,
    required this.toCurrency,
  });
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'convertedAmount': convertedAmount,
    };
  }

  factory ConversionHistory.fromMap(Map<String, dynamic> map) {
    return ConversionHistory(
      amount: map['amount'],
      fromCurrency: map['fromCurrency'],
      toCurrency: map['toCurrency'],
      convertedAmount: map['converteddAmount'],
    );
  }
}
