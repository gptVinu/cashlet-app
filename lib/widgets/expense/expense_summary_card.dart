import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';

class ExpenseSummaryCard extends StatelessWidget {
  const ExpenseSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final currentMonthTotal = appState.getTotalForPeriod(
      start: currentMonthStart,
      end: nextMonthStart.subtract(const Duration(days: 1)),
    );

    // Get last month's total for comparison
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthTotal = appState.getTotalForPeriod(
      start: lastMonthStart,
      end: currentMonthStart.subtract(const Duration(days: 1)),
    );

    // Calculate difference percentage
    double differencePercentage = 0;
    if (lastMonthTotal > 0) {
      differencePercentage =
          ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    }

    final monthName = DateFormat('MMMM').format(now);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$monthName Expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusIndicator(differencePercentage),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\u{20B9}${currentMonthTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _calculateMonthProgress(),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 $monthName'),
                Text(
                    '${DateFormat('d').format(DateTime(now.year, now.month + 1, 0))} $monthName'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(double percentage) {
    if (percentage == 0) {
      return const SizedBox();
    }

    final isIncrease = percentage > 0;
    final color = isIncrease ? Colors.red : Colors.green;
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '${percentage.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _calculateMonthProgress() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return now.day / daysInMonth;
  }
}
