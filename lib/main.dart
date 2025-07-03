import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'pages/home/home_page.dart';
import 'pages/expenses/expenses_page.dart';
import 'pages/tasks/tasks_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/expenses/add_expense_page.dart';
import 'pages/tasks/add_task_page.dart';
import 'services/theme_service.dart';
import 'services/storage_service.dart';
import 'services/passcode_service.dart';
import 'pages/security/passcode_verification_screen.dart';
import 'models/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  // Load persisted data
  final storageService = StorageService();
  final appState = AppState();
  final backup = await storageService.loadAllData();
  appState.setData(
    expenses: backup.expenses,
    tasks: backup.tasks,
    categories: backup.categories,
    budgets: backup.budgets,
    creditTransactions: backup.creditTransactions,
  );

  // Load theme mode
  final themeService = ThemeService();
  await themeService.loadThemeMode();

  // Set preferred orientations but keep system UI (status bar) visible
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure status bar is visible and properly styled
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState),
        ChangeNotifierProvider(create: (_) => themeService),
      ],
      child: const CashletApp(),
    ),
  );
}

class CashletApp extends StatelessWidget {
  const CashletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Cashlet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      themeMode: themeService.themeMode,
      home: const SplashScreen(), // Always start with SplashScreen
      routes: {
        '/home': (context) => const HomePage(),
        // ...other routes...
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkPasscodeAndNavigate();
      }
    });
  }

  Future<void> _checkPasscodeAndNavigate() async {
    final isPasscodeEnabled = await PasscodeService().isPasscodeEnabled();

    if (!mounted) return;

    if (isPasscodeEnabled) {
      // Navigate to passcode verification screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PasscodeVerificationScreen()),
      );
    } else {
      // No passcode required, go directly to main screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Cashlet',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Personal Finance Simplified',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomePage(),
      const ExpensesPage(),
      const TasksPage(),
      const SettingsPage(),
    ];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 500),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
          final appState = Provider.of<AppState>(context, listen: false);
          await StorageService().saveAllData(
            expenses: appState.expenses,
            tasks: appState.tasks,
            categories: appState.categories,
            budgets: appState.budgets,
            creditTransactions: appState.creditTransactions,
          );
        },
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 2) {
      return FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          final appState = Provider.of<AppState>(context, listen: false);
          await StorageService().saveAllData(
            expenses: appState.expenses,
            tasks: appState.tasks,
            categories: appState.categories,
            budgets: appState.budgets,
            creditTransactions: appState.creditTransactions,
          );
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
