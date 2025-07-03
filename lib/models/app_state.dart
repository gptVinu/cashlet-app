import 'package:flutter/foundation.dart' hide Category;
import 'expense.dart';
import 'task.dart';
import 'category.dart';
import 'budget.dart';
import 'credit_transaction.dart';

class AppState with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Task> _tasks = [];
  List<Category> _categories = [];
  List<Budget> _budgets = [];
  List<CreditTransaction>? _creditTransactions = [];

  // Getters
  List<Expense> get expenses => _expenses;
  List<Task> get tasks => _tasks;
  List<Category> get categories => _categories;
  List<Budget> get budgets => _budgets;
  List<CreditTransaction>? get creditTransactions => _creditTransactions;

  // Expense related methods
  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index >= 0) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  // Task related methods
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  // Category methods
  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void deleteCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  // Initialize default categories if none exist
  void initializeCategories() {
    if (_categories.isEmpty) {
      _categories = Category.defaultCategories();
      notifyListeners();
    }
  }

  // Update category
  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(String categoryId) {
    return _expenses
        .where((expense) => expense.categoryId == categoryId)
        .toList();
  }

  // Get total amount spent by category
  double getTotalByCategory(String categoryId) {
    return _expenses
        .where((expense) => expense.categoryId == categoryId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get total expenses for a specific period
  double getTotalForPeriod({required DateTime start, required DateTime end}) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get tasks for today
  List<Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
    }).toList();
  }

  // Get upcoming tasks
  List<Task> getUpcomingTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(today) && !task.isCompleted;
    }).toList();
  }

  // Get completed tasks
  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  // Get tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Get tasks for the next N days
  List<Task> getTasksForNextDays(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.add(Duration(days: days));

    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(today.subtract(const Duration(days: 1))) &&
          taskDate.isBefore(endDate.add(const Duration(days: 1))) &&
          !task.isCompleted;
    }).toList();
  }

  // Budget related functionality

  // Add a budget
  void addBudget(Budget budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  // Update a budget
  void updateBudget(Budget budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index >= 0) {
      _budgets[index] = budget;
      notifyListeners();
    }
  }

  // Delete a budget
  void deleteBudget(String id) {
    _budgets.removeWhere((budget) => budget.id == id);
    notifyListeners();
  }

  // Get budget by ID
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate budget progress
  Map<String, dynamic> getBudgetProgress(String budgetId) {
    final budget = getBudgetById(budgetId);
    if (budget == null) return {};

    final now = DateTime.now();
    DateTime periodStart;
    DateTime periodEnd;

    switch (budget.period) {
      case BudgetPeriod.daily:
        periodStart = DateTime(now.year, now.month, now.day);
        periodEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case BudgetPeriod.weekly:
        // Find start of week (Sunday)
        final daysToSubtract = now.weekday % 7;
        periodStart = DateTime(now.year, now.month, now.day - daysToSubtract);
        periodEnd = periodStart
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case BudgetPeriod.monthly:
        periodStart = DateTime(now.year, now.month, 1);
        periodEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case BudgetPeriod.yearly:
        periodStart = DateTime(now.year, 1, 1);
        periodEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }

    // Calculate spending for this budget period
    double spent;
    if (budget.categoryId != null) {
      // Category-specific budget
      spent = _expenses
          .where((expense) =>
              expense.categoryId == budget.categoryId &&
              expense.date
                  .isAfter(periodStart.subtract(const Duration(seconds: 1))) &&
              expense.date.isBefore(periodEnd.add(const Duration(seconds: 1))))
          .fold(0, (sum, expense) => sum + expense.amount);
    } else {
      // Overall budget
      spent = getTotalForPeriod(start: periodStart, end: periodEnd);
    }

    // Calculate percentage
    final percentage = (spent / budget.amount) * 100;

    // Calculate remaining amount
    final remaining = budget.amount - spent;

    // Calculate days remaining in period
    final daysTotal = periodEnd.difference(periodStart).inDays + 1;
    final daysRemaining = periodEnd.difference(now).inDays + 1;

    // Calculate daily budget
    final dailyBudget = budget.amount / daysTotal;

    // Calculate daily remaining budget
    final dailyRemaining = daysRemaining > 0 ? remaining / daysRemaining : 0;

    return {
      'budget': budget,
      'spent': spent,
      'remaining': remaining,
      'percentage': percentage,
      'isOverBudget': spent > budget.amount,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'daysTotal': daysTotal,
      'daysRemaining': daysRemaining,
      'dailyBudget': dailyBudget,
      'dailyRemaining': dailyRemaining,
    };
  }

  // Get all budget progress data
  List<Map<String, dynamic>> getAllBudgetProgress() {
    return _budgets.map((budget) => getBudgetProgress(budget.id)).toList();
  }

  // Set data (for restoring from backup)
  void setData({
    List<Expense>? expenses,
    List<Task>? tasks,
    List<Category>? categories,
    List<Budget>? budgets,
    List<CreditTransaction>? creditTransactions,
  }) {
    _expenses = expenses ?? [];
    _tasks = tasks ?? [];
    _categories = categories ?? [];
    _budgets = budgets ?? [];
    _creditTransactions = creditTransactions ?? [];

    _sortExpenses();
    _sortTasks();
    _sortCreditTransactions();
  }

  // Clear specific data types
  void clearExpensesData() {
    _expenses = [];
    notifyListeners();
  }

  void clearTasksData() {
    _tasks = [];
    notifyListeners();
  }

  void clearCreditData() {
    _creditTransactions = [];
    notifyListeners();
  }

  // Clear all data
  void clearAllData() {
    _expenses = [];
    _tasks = [];
    _categories = [];
    _budgets = [];
    _creditTransactions = [];
    notifyListeners();
  }

  // Get expenses grouped by day for a specific month
  Map<String, List<Expense>> getExpensesGroupedByDay(int month, int year) {
    final targetMonth = DateTime(year, month, 1);
    final nextMonth = DateTime(year, month + 1, 1);

    final monthlyExpenses = _expenses.where((expense) {
      return expense.date
              .isAfter(targetMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(nextMonth);
    }).toList();

    Map<String, List<Expense>> result = {};

    for (var expense in monthlyExpenses) {
      final dayKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

      if (!result.containsKey(dayKey)) {
        result[dayKey] = [];
      }

      result[dayKey]!.add(expense);
    }

    return result;
  }

  // Get expense statistics for the current month
  Map<String, dynamic> getCurrentMonthStats() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyExpenses = _expenses.where((expense) {
      return expense.date
              .isAfter(currentMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(nextMonth);
    }).toList();

    double total = 0;
    Map<String, double> categoryTotals = {};

    for (var expense in monthlyExpenses) {
      total += expense.amount;

      final categoryId = expense.categoryId;
      categoryTotals[categoryId] =
          (categoryTotals[categoryId] ?? 0) + expense.amount;
    }

    // Sort categories by amount (highest first)
    var sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total': total,
      'count': monthlyExpenses.length,
      'categoryTotals': categoryTotals,
      'topCategories': sortedCategories.take(3).toList(),
    };
  }

  // Compare current month with previous month
  Map<String, dynamic> getMonthlyComparison() {
    final now = DateTime.now();

    // Current month
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    final currentMonthTotal =
        getTotalForPeriod(start: currentMonthStart, end: currentMonthEnd);

    // Previous month
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd =
        currentMonthStart.subtract(const Duration(days: 1));
    final previousMonthTotal =
        getTotalForPeriod(start: previousMonthStart, end: previousMonthEnd);

    // Calculate difference
    final difference = currentMonthTotal - previousMonthTotal;
    double percentChange = 0;
    if (previousMonthTotal > 0) {
      percentChange = (difference / previousMonthTotal) * 100;
    }

    return {
      'currentMonthTotal': currentMonthTotal,
      'previousMonthTotal': previousMonthTotal,
      'difference': difference,
      'percentChange': percentChange,
      'isIncrease': difference > 0,
    };
  }

  // Get daily average expense for a specific period
  double getDailyAverage({DateTime? start, DateTime? end}) {
    final now = DateTime.now();
    start = start ?? DateTime(now.year, now.month, 1);
    end = end ?? now;

    final totalDays = end.difference(start).inDays + 1;
    if (totalDays <= 0) return 0;

    final totalExpense = getTotalForPeriod(start: start, end: end);
    return totalExpense / totalDays;
  }

  // Get category distribution for visualization
  List<Map<String, dynamic>> getCategoryDistribution(
      {DateTime? start, DateTime? end}) {
    final now = DateTime.now();
    start = start ?? DateTime(now.year, now.month, 1);
    end = end ?? now;

    final totalExpense = getTotalForPeriod(start: start, end: end);
    if (totalExpense <= 0) return [];

    Map<String, double> categoryTotals = {};

    // Calculate total for each category
    for (var expense in _expenses) {
      if (expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)))) {
        final categoryId = expense.categoryId;
        categoryTotals[categoryId] =
            (categoryTotals[categoryId] ?? 0) + expense.amount;
      }
    }

    // Convert to list of maps with category details
    List<Map<String, dynamic>> result = [];
    for (var entry in categoryTotals.entries) {
      final category = getCategoryById(entry.key);
      if (category != null) {
        result.add({
          'id': category.id,
          'name': category.name,
          'amount': entry.value,
          'percentage': (entry.value / totalExpense) * 100,
          'color': category.color,
          'icon': category.icon,
        });
      }
    }

    // Sort by amount (highest first)
    result.sort(
        (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return result;
  }

  // Get weekly expense trend for the past N weeks
  List<Map<String, dynamic>> getWeeklyTrend(int weeksCount) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    for (int i = 0; i < weeksCount; i++) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      final total = getTotalForPeriod(start: weekStart, end: weekEnd);

      result.add({
        'startDate': weekStart,
        'endDate': weekEnd,
        'total': total,
        'weekNumber': weeksCount - i,
      });
    }

    return result.reversed.toList(); // Return in chronological order
  }

  // Get top expense items for a specific period
  List<Expense> getTopExpenses(
      {DateTime? start, DateTime? end, int limit = 5, String? categoryId}) {
    final now = DateTime.now();
    start = start ?? DateTime(now.year, now.month, 1);
    end = end ?? now;

    // Filter expenses by date and optionally by category
    var filteredExpenses = _expenses.where((expense) {
      final matchesDate =
          expense.date.isAfter(start!.subtract(const Duration(days: 1))) &&
              expense.date.isBefore(end!.add(const Duration(days: 1)));

      if (categoryId != null) {
        return matchesDate && expense.categoryId == categoryId;
      }

      return matchesDate;
    }).toList();

    // Sort by amount (highest first)
    filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));

    // Return limited number of items
    return filteredExpenses.take(limit).toList();
  }

  // Get forecast for next month based on average spending
  Map<String, dynamic> getNextMonthForecast() {
    final now = DateTime.now();

    // Get spending for last 3 months to calculate average
    double totalSpending = 0;
    int monthsToConsider = 3;

    for (int i = 1; i <= monthsToConsider; i++) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 1)
          .subtract(const Duration(days: 1));

      totalSpending += getTotalForPeriod(start: monthStart, end: monthEnd);
    }

    final averageMonthlySpending =
        monthsToConsider > 0 ? totalSpending / monthsToConsider : 0;

    // Get category distribution for forecast
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    final categoryDistribution =
        getCategoryDistribution(start: currentMonth, end: nextMonth);

    return {
      'forecastAmount': averageMonthlySpending,
      'categoryDistribution': categoryDistribution,
      'basedOnMonths': monthsToConsider,
    };
  }

  // Check if user is overspending compared to average
  Map<String, dynamic> getSpendingInsight() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Get days passed in current month
    final daysPassed = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Get total spent so far this month
    final spentSoFar = getTotalForPeriod(start: currentMonth, end: now);

    // Get average daily spending
    final dailyAverage = spentSoFar / daysPassed;

    // Project total for month
    final projectedTotal = dailyAverage * daysInMonth;

    // Get previous month's total
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = currentMonth.subtract(const Duration(days: 1));
    final previousMonthTotal =
        getTotalForPeriod(start: previousMonthStart, end: previousMonthEnd);

    final percentProgress = (daysPassed / daysInMonth) * 100;
    final percentBudgetUsed =
        previousMonthTotal > 0 ? (spentSoFar / previousMonthTotal) * 100 : 0;

    final isOverspending = percentBudgetUsed > percentProgress;

    return {
      'spentSoFar': spentSoFar,
      'projectedTotal': projectedTotal,
      'previousMonthTotal': previousMonthTotal,
      'dailyAverage': dailyAverage,
      'percentProgress': percentProgress,
      'percentBudgetUsed': percentBudgetUsed,
      'isOverspending': isOverspending,
      'daysPassed': daysPassed,
      'daysInMonth': daysInMonth,
    };
  }

  void addCreditTransaction(CreditTransaction transaction) {
    _creditTransactions = [...?_creditTransactions, transaction];
    _sortCreditTransactions();
    notifyListeners();
  }

  void _sortCreditTransactions() {
    _creditTransactions?.sort((a, b) => b.date.compareTo(a.date));
  }

  void _sortExpenses() {
    _expenses.sort((a, b) => b.date.compareTo(a.date));
  }

  void _sortTasks() {
    _tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  void deleteCreditTransaction(String id) {
    _creditTransactions?.removeWhere((credit) => credit.id == id);
    notifyListeners();
  }
}
