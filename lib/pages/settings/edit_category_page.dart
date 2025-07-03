import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/category.dart';

class EditCategoryPage extends StatefulWidget {
  final Category? category;
  final bool isExpense;

  const EditCategoryPage({
    Key? key,
    this.category,
    this.isExpense = true,
  }) : super(key: key);

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late bool _isExpense;
  late Color _selectedColor;
  late IconData _selectedIcon;

  bool get _isEditing => widget.category != null;

  // Available colors for selection
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Available icons for selection
  final List<IconData> _availableIcons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.directions_bus,
    Icons.local_taxi,
    Icons.home,
    Icons.flight,
    Icons.hotel,
    Icons.movie,
    Icons.sports_esports,
    Icons.sports_basketball,
    Icons.fitness_center,
    Icons.shopping_bag,
    Icons.attach_money,
    Icons.account_balance,
    Icons.school,
    Icons.medical_services,
    Icons.pets,
    Icons.child_care,
    Icons.celebration,
    Icons.card_giftcard,
    Icons.favorite,
    Icons.coffee,
    Icons.local_bar,
    Icons.fastfood,
    Icons.local_grocery_store,
    Icons.shopping_basket,
    Icons.local_mall,
    Icons.local_atm,
    Icons.local_laundry_service,
    Icons.local_pharmacy,
    Icons.local_shipping,
    Icons.credit_card,
    Icons.account_balance_wallet,
    Icons.work,
    Icons.business_center,
    Icons.savings,
    Icons.payments,
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _isExpense = widget.category?.isExpense ?? widget.isExpense;
    _selectedColor = widget.category?.color ?? _availableColors.first;
    _selectedIcon = widget.category?.icon ?? _availableIcons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Category Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeOption(
                    label: 'Expense',
                    icon: Icons.arrow_upward,
                    isSelected: _isExpense,
                    onTap: () {
                      setState(() {
                        _isExpense = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeOption(
                    label: 'Income',
                    icon: Icons.arrow_downward,
                    isSelected: !_isExpense,
                    onTap: () {
                      setState(() {
                        _isExpense = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: _availableColors.map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: _selectedColor == color
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Icon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? _selectedColor.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? _selectedColor
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? _selectedColor : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveCategory,
                child: Text(
                  _isEditing ? 'Update Category' : 'Save Category',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final appState = Provider.of<AppState>(context, listen: false);

    if (_isEditing) {
      final updatedCategory = Category(
        id: widget.category!.id,
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        isExpense: _isExpense,
      );

      appState.updateCategory(updatedCategory);
    } else {
      final newCategory = Category(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        isExpense: _isExpense,
      );

      appState.addCategory(newCategory);
    }

    Navigator.pop(context);
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
