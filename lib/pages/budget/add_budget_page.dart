import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';
import '../../models/budget.dart';
import '../../services/storage_service.dart';

class AddBudgetPage extends StatefulWidget {
  final Budget? budget;

  const AddBudgetPage({Key? key, this.budget}) : super(key: key);

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  bool _isRecurring = true;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController = TextEditingController(text: widget.budget!.name);
      _amountController =
          TextEditingController(text: widget.budget!.amount.toString());
      _selectedCategoryId = widget.budget!.categoryId;
      _selectedPeriod = widget.budget!.period;
      _startDate = widget.budget!.startDate;
      _isRecurring = widget.budget!.isRecurring;
    } else {
      _nameController = TextEditingController();
      _amountController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final categories = appState.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'Create Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Budget Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name for this budget';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a budget amount';
                }

                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Category (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategoryId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Categories (Overall Budget)'),
                ),
                ...categories.map((category) {
                  return DropdownMenuItem<String?>(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Budget Period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: BudgetPeriod.values.map((period) {
                final isSelected = period == _selectedPeriod;

                String label;
                switch (period) {
                  case BudgetPeriod.daily:
                    label = 'Daily';
                    break;
                  case BudgetPeriod.weekly:
                    label = 'Weekly';
                    break;
                  case BudgetPeriod.monthly:
                    label = 'Monthly';
                    break;
                  case BudgetPeriod.yearly:
                    label = 'Yearly';
                    break;
                }

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMMM d, y').format(_startDate),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recurring Budget'),
              subtitle:
                  const Text('Automatically renew this budget for each period'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveBudget,
                child: Text(
                  _isEditing ? 'Update Budget' : 'Create Budget',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }
  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text);
    final appState = Provider.of<AppState>(context, listen: false);

    if (_isEditing) {
      final updatedBudget = Budget(
        id: widget.budget!.id,
        name: name,
        amount: amount,
        categoryId: _selectedCategoryId,
        period: _selectedPeriod,
        startDate: _startDate,
        isRecurring: _isRecurring,
      );

      appState.updateBudget(updatedBudget);
    } else {
      final newBudget = Budget(
        name: name,
        amount: amount,
        categoryId: _selectedCategoryId,
        period: _selectedPeriod,
        startDate: _startDate,
        isRecurring: _isRecurring,
      );

      appState.addBudget(newBudget);
    }

    Navigator.pop(context);

    // Save to local storage
    await StorageService().saveAllData(
      expenses: appState.expenses,
      tasks: appState.tasks,
      categories: appState.categories,
      budgets: appState.budgets,
    );
  }
}
