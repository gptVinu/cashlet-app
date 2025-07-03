import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';
import '../../models/budget.dart';
import 'add_budget_page.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final budgets = appState.budgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: budgets.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Budget Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...budgets.map((budget) => _BudgetCard(budgetId: budget.id)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBudgetPage()),
          );
        },
        label: const Text('Add Budget'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text('No budgets yet'),
          const SizedBox(height: 8),
          const Text(
            'Create a budget to help you manage your expenses',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBudgetPage()),
              );
            },
            child: const Text('Create Your First Budget'),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String budgetId;

  const _BudgetCard({required this.budgetId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final budgetProgress = appState.getBudgetProgress(budgetId);

    if (budgetProgress.isEmpty) {
      return const SizedBox();
    }

    final budget = budgetProgress['budget'] as Budget;
    final spent = budgetProgress['spent'] as double;
    final remaining = budgetProgress['remaining'] as double;
    final percentage = budgetProgress['percentage'] as double;
    final isOverBudget = budgetProgress['isOverBudget'] as bool;

    final theme = Theme.of(context);

    // Choose color based on percentage
    Color progressColor;
    if (percentage >= 100) {
      progressColor = Colors.red;
    } else if (percentage >= 75) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    String periodText;
    switch (budget.period) {
      case BudgetPeriod.daily:
        periodText = 'Daily';
        break;
      case BudgetPeriod.weekly:
        periodText = 'Weekly';
        break;
      case BudgetPeriod.monthly:
        periodText = 'Monthly';
        break;
      case BudgetPeriod.yearly:
        periodText = 'Yearly';
        break;
    }

    // Format dates
    final dateFormat = DateFormat('MMM d, y');
    final startDate =
        dateFormat.format(budgetProgress['periodStart'] as DateTime);
    final endDate = dateFormat.format(budgetProgress['periodEnd'] as DateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.name,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  periodText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            if (budget.categoryId != null) ...[
              const SizedBox(height: 4),
              _buildCategoryInfo(context, budget.categoryId!),
            ],
            const SizedBox(height: 8),
            Text(
              '$startDate to $endDate',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: progressColor,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${percentage.toStringAsFixed(1)}%'),
                Text(
                  isOverBudget ? 'Over Budget!' : 'On Budget',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Budget',
                  '\u{20B9}${budget.amount.toStringAsFixed(2)}',
                  theme.colorScheme.primary,
                ),
                _buildInfoColumn(
                  context,
                  'Spent',
                  '\u{20B9}${spent.toStringAsFixed(2)}',
                  Colors.red,
                ),
                _buildInfoColumn(
                  context,
                  'Remaining',
                  '\u{20B9}${remaining.toStringAsFixed(2)}',
                  remaining >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddBudgetPage(budget: budget),
                      ),
                    );
                  },
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _confirmDeleteBudget(context, budget);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfo(BuildContext context, String categoryId) {
    final appState = Provider.of<AppState>(context);
    final category = appState.getCategoryById(categoryId);

    if (category == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Icon(category.icon, size: 16, color: category.color),
        const SizedBox(width: 4),
        Text(
          category.name,
          style: TextStyle(color: category.color),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteBudget(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Budget'),
          content: Text('Are you sure you want to delete "${budget.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.deleteBudget(budget.id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
