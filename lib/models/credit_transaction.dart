class CreditTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String? category;

  CreditTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  // Create from JSON
  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }
}
