import 'package:uuid/uuid.dart';

enum BudgetPeriod { daily, weekly, monthly, yearly }

class Budget {
  final String id;
  final String name;
  final double amount;
  final String? categoryId; // null means overall budget
  final BudgetPeriod period;
  final DateTime startDate;
  final bool isRecurring;

  Budget({
    String? id,
    required this.name,
    required this.amount,
    this.categoryId,
    required this.period,
    required this.startDate,
    this.isRecurring = true,
  }) : id = id ?? const Uuid().v4();

  Budget copyWith({
    String? name,
    double? amount,
    String? categoryId,
    BudgetPeriod? period,
    DateTime? startDate,
    bool? isRecurring,
  }) {
    return Budget(
      id: this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'categoryId': categoryId,
      'period': period.index,
      'startDate': startDate.toIso8601String(),
      'isRecurring': isRecurring,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      categoryId: json['categoryId'],
      period: BudgetPeriod.values[json['period']],
      startDate: DateTime.parse(json['startDate']),
      isRecurring: json['isRecurring'],
    );
  }
}
