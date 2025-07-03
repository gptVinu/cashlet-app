import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final now = DateTime.now();

    // Get data for the last 7 days
    final List<_ExpenseData> chartData = [];
    final List<String> dayLabels = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final total = appState.getTotalForPeriod(start: start, end: end);
      chartData.add(_ExpenseData(6 - i, total, date));

      // Add day label
      dayLabels.add(DateFormat('E').format(date)[0]); // First letter of day
    }

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        minimum: 0,
        maximum: 6,
        interval: 1,
        majorGridLines: const MajorGridLines(width: 0),
        axisLabelFormatter: (axisLabelRenderArgs) {
          final int index = axisLabelRenderArgs.value.toInt();
          if (index >= 0 && index < 7) {
            return ChartAxisLabel(dayLabels[index], null);
          }
          return ChartAxisLabel('', null);
        },
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.currency(symbol: '₹', decimalDigits: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      series: <CartesianSeries<_ExpenseData, int>>[
        SplineAreaSeries<_ExpenseData, int>(
          dataSource: chartData,
          xValueMapper: (_ExpenseData data, _) => data.day,
          yValueMapper: (_ExpenseData data, _) => data.amount,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          borderColor: Theme.of(context).colorScheme.primary,
          borderWidth: 3,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.y',
        header: '',
        builder: (data, point, series, pointIndex, seriesIndex) {
          final _ExpenseData expenseData = data;
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d').format(expenseData.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('\u{20B9}${expenseData.amount.toStringAsFixed(2)}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Data class for chart points
class _ExpenseData {
  final int day;
  final double amount;
  final DateTime date;

  _ExpenseData(this.day, this.amount, this.date);
}
