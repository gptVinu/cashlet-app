import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/credit_transaction.dart';

class BackupData {
  final List<Expense> expenses;
  final List<Task> tasks;
  final List<Category> categories;
  final List<Budget> budgets;
  final List<CreditTransaction> creditTransactions;

  BackupData({
    required this.expenses,
    required this.tasks,
    required this.categories,
    this.budgets = const [],
    this.creditTransactions = const [],
  });
}

class StorageService {
  static const String _expensesKey = 'cashlet_expenses';
  static const String _tasksKey = 'cashlet_tasks';
  static const String _categoriesKey = 'cashlet_categories';
  static const String _budgetsKey = 'cashlet_budgets';
  static const String _creditTransactionsKey = 'cashlet_credit_transactions';

  // Save expenses to SharedPreferences
  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = expenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_expensesKey, jsonData);
  }

  // Save tasks to SharedPreferences
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_tasksKey, jsonData);
  }

  // Save categories to SharedPreferences
  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = categories.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_categoriesKey, jsonData);
  }

  // Save budgets to SharedPreferences
  Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = budgets.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_budgetsKey, jsonData);
  }

  // Save credit transactions to SharedPreferences
  Future<void> saveCreditTransactions(
      List<CreditTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_creditTransactionsKey, jsonData);
  }

  // Load expenses from SharedPreferences
  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_expensesKey) ?? [];

    return jsonData.map((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      return Expense.fromJson(json);
    }).toList();
  }

  // Load tasks from SharedPreferences
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_tasksKey) ?? [];

    return jsonData.map((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      return Task.fromJson(json);
    }).toList();
  }

  // Load categories from SharedPreferences
  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_categoriesKey) ?? [];

    if (jsonData.isEmpty) {
      return Category.defaultCategories();
    }

    return jsonData.map((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      return Category.fromJson(json);
    }).toList();
  }

  // Load budgets from SharedPreferences
  Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_budgetsKey) ?? [];
    return jsonData.map((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      return Budget.fromJson(json);
    }).toList();
  }

  // Load credit transactions from SharedPreferences
  Future<List<CreditTransaction>> loadCreditTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_creditTransactionsKey) ?? [];

    return jsonData.map((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      return CreditTransaction.fromJson(json);
    }).toList();
  }

  // Save all data
  Future<void> saveAllData({
    required List<Expense> expenses,
    required List<Task> tasks,
    required List<Category> categories,
    List<Budget>? budgets,
    List<CreditTransaction>? creditTransactions,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await saveExpenses(expenses);
    await saveTasks(tasks);
    await saveCategories(categories);
    if (budgets != null) {
      await saveBudgets(budgets);
    }
    if (creditTransactions != null) {
      final creditList = creditTransactions
          .map((credit) => {
                'id': credit.id,
                'title': credit.title,
                'amount': credit.amount,
                'date': credit.date.toIso8601String(),
                'category': credit.category,
              })
          .toList();

      await prefs.setString('credit_transactions', jsonEncode(creditList));
    }
  }

  // Load all data
  Future<BackupData> loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    final expenses = await loadExpenses();
    final tasks = await loadTasks();
    final categories = await loadCategories();
    final budgets = await loadBudgets();

    // Load credit transactions
    List<CreditTransaction>? creditTransactions;
    final creditJson = prefs.getString('credit_transactions');
    if (creditJson != null) {
      final creditList = jsonDecode(creditJson) as List;
      creditTransactions = creditList
          .map((item) => CreditTransaction(
                id: item['id'],
                title: item['title'],
                amount: item['amount'].toDouble(),
                date: DateTime.parse(item['date']),
                category: item['category'],
              ))
          .toList();
    }

    return BackupData(
      expenses: expenses,
      tasks: tasks,
      categories: categories,
      budgets: budgets,
      creditTransactions: creditTransactions ?? [],
    );
  }

  // Create backup
  Future<void> backupData({
    required List<Expense> expenses,
    required List<Task> tasks,
    required List<Category> categories,
    List<Budget>? budgets,
    List<CreditTransaction>? creditTransactions,
  }) async {
    await saveAllData(
      expenses: expenses,
      tasks: tasks,
      categories: categories,
      budgets: budgets,
      creditTransactions: creditTransactions,
    );
  }

  // Restore from backup
  Future<BackupData?> restoreData() async {
    try {
      return await loadAllData();
    } catch (e) {
      // Using debugPrint which is more appropriate for Flutter apps
      foundation.debugPrint('Error restoring data: $e');
      return null;
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
    await prefs.remove(_tasksKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_budgetsKey);
    await prefs.remove(_creditTransactionsKey);
  }
}
