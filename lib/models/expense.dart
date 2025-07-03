import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? note;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? note,
  }) {
    return Expense(
      id: this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      note: json['note'],
    );
  }
}
