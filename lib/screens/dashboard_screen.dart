import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import 'categories_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';

@Deprecated('Use HomeScreen instead')
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: dashboard.isLoading
            ? const CircularProgressIndicator()
            : dashboard.stats == null
                ? Text(dashboard.error ?? 'No data')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total Spent: ${dashboard.stats!.totalSpent.toStringAsFixed(2)}'),
                      Text('Total Income: ${dashboard.stats!.totalIncome.toStringAsFixed(2)}'),
                    ],
                  ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Categories'),
              onTap: () => Navigator.of(context).pushNamed(CategoriesScreen.routeName),
            ),
            ListTile(
              title: const Text('Transactions'),
              onTap: () => Navigator.of(context).pushNamed(TransactionsScreen.routeName),
            ),
            ListTile(
              title: const Text('Budgets'),
              onTap: () => Navigator.of(context).pushNamed(BudgetsScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}

