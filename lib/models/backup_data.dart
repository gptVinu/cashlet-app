import 'package:cashlet/models/budget.dart';
import 'package:cashlet/models/category.dart';
import 'package:cashlet/models/task.dart';

import 'credit_transaction.dart';
import 'expense.dart';

class BackupData {
  final List<Expense>? expenses;
  final List<Task>? tasks;
  final List<Category>? categories;
  final List<Budget>? budgets;
  final List<CreditTransaction>? creditTransactions;

  BackupData({
    this.expenses,
    this.tasks,
    this.categories,
    this.budgets,
    this.creditTransactions,
  });
}
