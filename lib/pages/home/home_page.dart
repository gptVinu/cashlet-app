import 'package:cashlet/pages/credits/add_credit_transaction_page.dart';
import 'package:cashlet/pages/credits/credit_history_page.dart';
import 'package:cashlet/pages/tasks/tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/expense/expense_summary_card.dart';
import '../../widgets/task/upcoming_tasks_list.dart';
import '../expenses/expenses_page.dart';
import 'package:cashlet/pages/expenses/add_expense_page.dart';
import 'package:cashlet/pages/credit/credit_history_page.dart';
import 'package:cashlet/pages/tasks/add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Cashlet',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ExpenseSummaryCard(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Tasks',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const TasksPage()),
                              );
                            },
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      UpcomingTasksList(limit: 4),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Expenses',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ExpensesPage()),
                              );
                            },
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRecentExpenses(context),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Credit History',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const CreditHistoryPage()),
                              );
                            },
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCreditHistory(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOptions(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add transaction',
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Transaction & Task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Add Credit'),
                  subtitle: const Text('Income, salary, refunds'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddCreditTransactionPage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Add Expense'),
                  subtitle: const Text('Bills, shopping, payments'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddExpensePage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                    child: Icon(
                      Icons.task_alt,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  title: const Text('Add Task'),
                  subtitle: const Text('Reminders, to-dos, schedules'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddTaskPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentExpenses(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final expenses = appState.expenses;

    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const Text('No expenses yet'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddExpensePage()),
                  );
                },
                child: const Text('Add your first expense'),
              ),
            ],
          ),
        ),
      );
    }

    // Show max 4 recent expenses
    final recentExpenses = expenses.take(4).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentExpenses.length,
      itemBuilder: (context, index) {
        final expense = recentExpenses[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(expense.title),
            subtitle: Text(
              expense.date.toString().substring(0, 10),
            ),
            trailing: Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreditHistory(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final credits = appState.creditTransactions ?? [];

    if (credits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const Text('No credit transactions yet'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AddCreditTransactionPage()),
                  );
                },
                child: const Text('Add your first credit'),
              ),
            ],
          ),
        ),
      );
    }

    // Show max 4 recent credit transactions
    final recentCredits = credits.take(4).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentCredits.length,
      itemBuilder: (context, index) {
        final credit = recentCredits[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(credit.title),
            subtitle: Text(
              credit.date.toString().substring(0, 10),
            ),
            trailing: Text(
              '₹${credit.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      },
    );
  }
}
