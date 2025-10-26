import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_providers.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ask_ai_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/accounts_screen.dart';
import 'config/theme.dart';
import 'screens/categories_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budgets_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: MaterialApp(
        title: 'MCA Finance',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        // initialRoute: LoginScreen.routeName,
        initialRoute: HomeScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          AskAiScreen.routeName: (_) => const AskAiScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          AccountsScreen.routeName: (_) => const AccountsScreen(),
          CategoriesScreen.routeName: (_) => const CategoriesScreen(),
          TransactionsScreen.routeName: (_) => const TransactionsScreen(),
          BudgetsScreen.routeName: (_) => const BudgetsScreen(),
        },
      ),
    );
  }
}

