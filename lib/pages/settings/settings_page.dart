import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../services/storage_service.dart';
import '../../services/passcode_service.dart';
import '../../models/app_state.dart';
import '../security/passcode_screen.dart';
import 'category_management_page.dart';
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State variables
  bool _notificationsEnabled = true;
  bool _passcodeEnabled = false;
  final PasscodeService _passcodeService = PasscodeService();

  @override
  void initState() {
    super.initState();
    _checkPasscodeStatus();
  }

  Future<void> _checkPasscodeStatus() async {
    final isEnabled = await _passcodeService.isPasscodeEnabled();
    setState(() {
      _passcodeEnabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            secondary: Icon(
              themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            value: themeService.isDarkMode,
            onChanged: (value) {
              themeService
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          // Security section
          _buildSectionHeader(context, 'Security'),
          ListTile(
            leading: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
            title: const Text('App Passcode'),
            subtitle: Text(_passcodeEnabled
                ? 'Change or disable passcode'
                : 'Set up a passcode for the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PasscodeScreen(),
                ),
              ).then((_) => _checkPasscodeStatus());
            },
          ),

          // Data Management section
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: Icon(Icons.category, color: theme.colorScheme.primary),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add, edit or delete expense categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryManagementPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.backup, color: theme.colorScheme.primary),
            title: const Text('Backup Data'),
            subtitle: const Text('Save your expenses and tasks data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showComingSoonMessage(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.restore, color: theme.colorScheme.primary),
            title: const Text('Restore Data'),
            subtitle: const Text('Load your previously saved data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showComingSoonMessage(context);
            },
          ),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Task Reminders'),
            subtitle: const Text('Get notifications for upcoming tasks'),
            secondary: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: theme.colorScheme.primary,
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // In a real app, you'd save this to persistent storage
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value
                      ? 'Task reminders enabled'
                      : 'Task reminders disabled'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // About section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            title: const Text('About Cashlet'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
          ),

          // Danger zone
          _buildSectionHeader(context, 'Danger Zone', color: Colors.red),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title:
                const Text('Clear Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Select what data you want to remove'),
            onTap: () => _verifyAndShowClearDataOptions(context),
          ),
        ],
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
            'This feature is currently in development and will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _verifyAndShowClearDataOptions(BuildContext context) async {
    // Check if passcode is enabled
    final isEnabled = await _passcodeService.isPasscodeEnabled();

    if (isEnabled) {
      // Verify passcode before allowing data clearing
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PasscodeScreen(
            verifyOnly: true,
          ),
        ),
      );

      if (result == true) {
        _showClearDataOptions(context);
      }
    } else {
      // No passcode, proceed directly
      _showClearDataOptions(context);
    }
  }

  void _showClearDataOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'CLEAR DATA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.red),
              title: const Text('Clear All Expenses Data',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Remove all your expense records'),
              onTap: () {
                Navigator.pop(context);
                _confirmClearSpecificData(context, 'expenses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.red),
              title: const Text('Clear All Tasks Data',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Remove all your tasks'),
              onTap: () {
                Navigator.pop(context);
                _confirmClearSpecificData(context, 'tasks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.red),
              title: const Text('Clear All Credit History Data',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Remove all your credit transactions'),
              onTap: () {
                Navigator.pop(context);
                _confirmClearSpecificData(context, 'credits');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear All Data',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Remove all data completely'),
              onTap: () {
                Navigator.pop(context);
                _confirmClearSpecificData(context, 'all');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _confirmClearSpecificData(BuildContext context, String dataType) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final storageService = StorageService();

    String title;
    String content;
    String buttonText;

    switch (dataType) {
      case 'expenses':
        title = 'Clear Expense Data';
        content =
            'This will delete all your expense records. This action cannot be undone.';
        buttonText = 'Delete All Expenses';
        break;
      case 'tasks':
        title = 'Clear Task Data';
        content =
            'This will delete all your tasks. This action cannot be undone.';
        buttonText = 'Delete All Tasks';
        break;
      case 'credits':
        title = 'Clear Credit History Data';
        content =
            'This will delete all your credit transactions. This action cannot be undone.';
        buttonText = 'Delete All Credits';
        break;
      case 'all':
      default:
        title = 'Clear All Data';
        content =
            'This action cannot be undone. All your expenses, tasks, credits and categories will be permanently deleted.';
        buttonText = 'Delete Everything';
    }

    // Confirm clear data
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(buttonText),
          ),
        ],
      ),
    );

    if (confirm == true) {
      switch (dataType) {
        case 'expenses':
          appState.clearExpensesData();
          await storageService.saveExpenses([]);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('All expenses cleared successfully')));
          break;
        case 'tasks':
          appState.clearTasksData();
          await storageService.saveTasks([]);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All tasks cleared successfully')));
          break;
        case 'credits':
          appState.clearCreditData();
          await storageService.saveCreditTransactions([]);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('All credit records cleared successfully')));
          break;
        case 'all':
          appState.clearAllData();
          await storageService.clearAllData();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All data cleared successfully')));
          break;
      }
    }
  }
}
