import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/category.dart';
import 'edit_category_page.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Ensure we have default categories
    if (appState.categories.isEmpty) {
      appState.initializeCategories();
    }

    // Split categories into expense and income
    final expenseCategories =
        appState.categories.where((c) => c.isExpense).toList();
    final incomeCategories =
        appState.categories.where((c) => !c.isExpense).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'EXPENSES'),
                Tab(text: 'INCOME'),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: theme.colorScheme.primary,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCategoryList(context, expenseCategories, true),
                  _buildCategoryList(context, incomeCategories, false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditCategoryPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context, List<Category> categories, bool isExpense) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpense ? Icons.shopping_cart : Icons.account_balance_wallet,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(isExpense ? 'No expense categories' : 'No income categories'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCategoryPage(isExpense: isExpense),
                  ),
                );
              },
              child: Text('Add ${isExpense ? 'Expense' : 'Income'} Category'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCategoryPage(
                          category: category,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDeleteCategory(context, category);
                  },
                ),
              ],
            ),
            onTap: () {
              // Show category details or usage statistics
            },
          ),
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, Category category) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Check if category is in use
    final categoryExpenses = appState.getExpensesByCategory(category.id);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: categoryExpenses.isNotEmpty
              ? Text(
                  'This category is used by ${categoryExpenses.length} expenses. Deleting it will make those expenses uncategorized.')
              : Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                appState.deleteCategory(category.id);
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
