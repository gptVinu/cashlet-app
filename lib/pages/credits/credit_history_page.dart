import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/credit_transaction.dart';
import 'add_credit_transaction_page.dart';
import '../../services/storage_service.dart';

class CreditHistoryPage extends StatefulWidget {
  const CreditHistoryPage({Key? key}) : super(key: key);

  @override
  State<CreditHistoryPage> createState() => _CreditHistoryPageState();
}

class _CreditHistoryPageState extends State<CreditHistoryPage> {
  String _filterType = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final credits = _filterCredits(appState.creditTransactions ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: credits.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: credits.length,
              itemBuilder: (context, index) {
                final credit = credits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onLongPress: () => _showDeleteConfirmation(context, credit),
                    child: ListTile(
                      title: Text(credit.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credit.date.toString().substring(0, 10),
                          ),
                          Text(
                            credit.category ?? 'No category',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '₹${credit.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddCreditTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add credit transaction',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No credit transactions yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first credit transaction to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AddCreditTransactionPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Credit Transaction'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Credits'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Type:'),
                  DropdownButton<String>(
                    value: _filterType,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          _filterType = value;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                      DropdownMenuItem(value: 'Refund', child: Text('Refund')),
                      DropdownMenuItem(value: 'Gift', child: Text('Gift')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Date Range:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _startDate == null
                                ? 'Start Date'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _startDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _endDate == null
                                ? 'End Date'
                                : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _endDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    _filterType = 'All';
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Update main state with filter settings
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<CreditTransaction> _filterCredits(List<CreditTransaction> credits) {
    var filteredList = credits;

    // Filter by type
    if (_filterType != 'All') {
      filteredList =
          filteredList.where((c) => c.category == _filterType).toList();
    }

    // Filter by start date
    if (_startDate != null) {
      filteredList = filteredList
          .where((c) =>
              c.date.isAfter(_startDate!) ||
              c.date.isAtSameMomentAs(_startDate!))
          .toList();
    }

    // Filter by end date
    if (_endDate != null) {
      // Add one day to include the end date fully
      final endDatePlusOne = _endDate!.add(const Duration(days: 1));
      filteredList =
          filteredList.where((c) => c.date.isBefore(endDatePlusOne)).toList();
    }

    return filteredList;
  }

  void _showDeleteConfirmation(BuildContext context, CreditTransaction credit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${credit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.deleteCreditTransaction(credit.id);

              // Save the updated data
              StorageService().saveAllData(
                expenses: appState.expenses,
                tasks: appState.tasks,
                categories: appState.categories,
                budgets: appState.budgets,
                creditTransactions: appState.creditTransactions,
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
