import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/expense.dart';
import '../../widgets/expense/expense_chart.dart';
import 'add_expense_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'This Month'),
            Tab(text: 'Statistics'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExpensesList(filter: ExpenseFilter.all),
          _ExpensesList(filter: ExpenseFilter.thisMonth),
          const _ExpenseStatistics(),
        ],
      ),
    );
  }
}

enum ExpenseFilter { all, thisMonth }

class _ExpensesList extends StatelessWidget {
  final ExpenseFilter filter;

  const _ExpensesList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    List<Expense> expenses = appState.expenses;

    // Apply filter
    if (filter == ExpenseFilter.thisMonth) {
      final now = DateTime.now();
      expenses = expenses
          .where((expense) =>
              expense.date.month == now.month && expense.date.year == now.year)
          .toList();
    }

    // Sort by date, newest first
    expenses.sort((a, b) => b.date.compareTo(a.date));

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text('No expenses found'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpensePage()),
                );
              },
              child: const Text('Add Expense'),
            ),
          ],
        ),
      );
    }

    // Group by date
    final Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in expenses) {
      final dateStr =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

      if (!groupedExpenses.containsKey(dateStr)) {
        groupedExpenses[dateStr] = [];
      }
      groupedExpenses[dateStr]!.add(expense);
    }

    // Sort dates, newest first
    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final expensesForDate = groupedExpenses[date]!;
        final totalForDate = expensesForDate.fold<double>(
            0, (sum, expense) => sum + expense.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\u{20B9}${totalForDate.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expensesForDate.length,
              itemBuilder: (context, i) {
                final expense = expensesForDate[i];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(expense.title),
                    subtitle: Text(expense.note ?? ''),
                    trailing: Text(
                      '\u{20B9}${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () {
                      // Navigate to expense details page
                    },
                    onLongPress: () {
                      _showExpenseActions(context, expense);
                    },
                  ),
                );
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final date = DateTime.parse(dateStr);
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showExpenseActions(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit expense page
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.deleteExpense(expense.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseStatistics extends StatelessWidget {
  const _ExpenseStatistics();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExpenseChart(),
          const SizedBox(height: 24),
          Text(
            'Top Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const _TopCategoriesWidget(),
          const SizedBox(height: 24),
          Text(
            'Monthly Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const _MonthlySummaryWidget(),
        ],
      ),
    );
  }
}

class _TopCategoriesWidget extends StatelessWidget {
  const _TopCategoriesWidget();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Top categories will be displayed here'),
      ),
    );
  }
}

class _MonthlySummaryWidget extends StatelessWidget {
  const _MonthlySummaryWidget();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Monthly summary will be displayed here'),
      ),
    );
  }
}
