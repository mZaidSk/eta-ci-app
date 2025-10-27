import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import 'categories_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'accounts_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../widgets/fancy_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _pageNames = ['Home', 'Category', 'Budgets', 'Accounts'];
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
    final colorScheme = Theme.of(context).colorScheme;

    Widget homeTab = Padding(
      padding: const EdgeInsets.all(16),
      child: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboard.stats == null
              ? Center(child: Text(dashboard.error ?? 'No data'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Spent',
                            value:
                                dashboard.stats!.totalSpent.toStringAsFixed(2),
                            color: colorScheme.errorContainer,
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Income',
                            value:
                                dashboard.stats!.totalIncome.toStringAsFixed(2),
                            color: colorScheme.primaryContainer,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Text('Quick Actions',
                    //     style: Theme.of(context).textTheme.titleMedium),
                    // const SizedBox(height: 12),
                    // Wrap(
                    //   spacing: 12,
                    //   runSpacing: 12,
                    //   children: [
                    //     _ActionChip(
                    //         label: 'Categories',
                    //         icon: Icons.category_rounded,
                    //         onTap: () => Navigator.of(context)
                    //             .pushNamed(CategoriesScreen.routeName)),
                    //     _ActionChip(
                    //         label: 'Ask AI',
                    //         icon: Icons.smart_toy_rounded,
                    //         onTap: () => Navigator.of(context)
                    //             .pushNamed(AskAiScreen.routeName)),
                    //   ],
                    // ),
                    // const SizedBox(height: 24),
                    Text('Insights',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: const [
                          _InsightTile(
                              title:
                                  'Track your daily spending to stay on budget.'),
                          _InsightTile(
                              title:
                                  'Set category budgets to control overspending.'),
                          _InsightTile(
                              title:
                                  'Use Ask AI for savings tips tailored to you.'),
                        ],
                      ),
                    ),
                  ],
                ),
    );

    final tabs = [
      homeTab,
      const CategoriesScreen(),
      const BudgetsScreen(),
      const AccountsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial App',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              _pageNames[_currentIndex],
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () =>
                Navigator.of(context).pushNamed(ProfileScreen.routeName),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: tabs),
          // Floating chatbot button
          Positioned(
            right: 16,
            bottom: 90,
            child: FloatingActionButton(
              heroTag: 'chatbot_fab',
              onPressed: () => Navigator.of(context).pushNamed(ChatScreen.routeName),
              tooltip: 'AI Assistant',
              child: const Icon(Icons.smart_toy_rounded),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FancyBottomNav(
        items: const [
          FancyNavItem(icon: Icons.home_rounded, label: 'Home'),
          FancyNavItem(icon: Icons.category_rounded, label: 'Category'),
          FancyNavItem(icon: Icons.pie_chart_rounded, label: 'Budgets'),
          FancyNavItem(
              icon: Icons.account_balance_wallet_rounded, label: 'Accounts'),
        ],
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onCenterTap: () =>
            Navigator.of(context).pushNamed(TransactionsScreen.routeName),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.08),
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.insights_rounded),
        title: Text(title),
      ),
    );
  }
}
