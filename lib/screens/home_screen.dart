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
import '../widgets/monthly_trend_chart.dart';

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
      context.read<DashboardProvider>().fetchAllDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    Widget homeTab = RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().fetchAllDashboardData(),
      child: dashboard.isLoading && dashboard.summary == null
          ? const Center(child: CircularProgressIndicator())
          : dashboard.error != null && dashboard.summary == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text('Failed to load dashboard',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(dashboard.error ?? 'Unknown error',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.read<DashboardProvider>().fetchAllDashboardData(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildDashboard(dashboard, colorScheme),
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
              'FinFlow',
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
              onPressed: () =>
                  Navigator.of(context).pushNamed(ChatScreen.routeName),
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

  Widget _buildDashboard(DashboardProvider dashboard, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Financial Health Score
        if (dashboard.financialHealth != null)
          _buildFinancialHealthCard(dashboard.financialHealth!, colorScheme),
        const SizedBox(height: 16),

        // Summary Cards
        if (dashboard.summary != null)
          _buildSummarySection(dashboard.summary!, colorScheme),
        const SizedBox(height: 16),

        // Quick Stats Row
        Row(
          children: [
            if (dashboard.summary != null) ...[
              Expanded(
                child: _buildQuickStatCard(
                  'Net Balance',
                  (dashboard.summary!['data']['net_balance'] ?? 0).toStringAsFixed(2),
                  Icons.account_balance_wallet,
                  colorScheme.tertiaryContainer,
                  colorScheme,
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (dashboard.summary != null &&
                dashboard.summary!['data']['accounts'] != null)
              Expanded(
                child: _buildQuickStatCard(
                  'Accounts',
                  dashboard.summary!['data']['accounts'].length.toString(),
                  Icons.account_balance,
                  colorScheme.surfaceContainerHighest,
                  colorScheme,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Budget Status
        if (dashboard.budgetVsActual != null)
          _buildBudgetStatusSection(dashboard.budgetVsActual!, colorScheme),
        const SizedBox(height: 16),

        // Category Breakdown
        if (dashboard.categoryBreakdown != null)
          _buildCategoryBreakdown(dashboard.categoryBreakdown!, colorScheme),
        const SizedBox(height: 16),

        // Monthly Trend
        if (dashboard.monthlyTrend != null)
          _buildMonthlyTrendSection(dashboard.monthlyTrend!, colorScheme),
      ],
    );
  }

  Widget _buildFinancialHealthCard(
      Map<String, dynamic> healthData, ColorScheme colorScheme) {
    final data = healthData['data'];
    final score = (data['total_score'] ?? 0).toDouble();
    final rating = data['rating'] ?? 'Unknown';

    Color getScoreColor() {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.lightGreen;
      if (score >= 40) return Colors.orange;
      return Colors.red;
    }

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              getScoreColor().withOpacity(0.1),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: getScoreColor(), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        rating,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: getScoreColor(),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${score.toStringAsFixed(0)}/100',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: getScoreColor(),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: getScoreColor(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHealthMetric(
                  'Savings',
                  '${(data['savings_points'] ?? 0).toStringAsFixed(0)}/40',
                  Icons.savings,
                ),
                _buildHealthMetric(
                  'Budget',
                  '${(data['budget_points'] ?? 0).toStringAsFixed(0)}/30',
                  Icons.pie_chart,
                ),
                _buildHealthMetric(
                  'Stability',
                  '${(data['stability_points'] ?? 0).toStringAsFixed(0)}/20',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
      Map<String, dynamic> summary, ColorScheme colorScheme) {
    final data = summary['data'];
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Income',
            value: '₹${(data['total_income'] ?? 0).toStringAsFixed(2)}',
            color: colorScheme.primaryContainer,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Total Expense',
            value: '₹${(data['total_expense'] ?? 0).toStringAsFixed(2)}',
            color: colorScheme.errorContainer,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon,
      Color bgColor, ColorScheme colorScheme) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStatusSection(
      Map<String, dynamic> budgetData, ColorScheme colorScheme) {
    final budgets = budgetData['data'] as List<dynamic>? ?? [];

    if (budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _currentIndex = 2); // Navigate to budgets tab
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...budgets.take(3).map((budget) {
          final category = budget['category'] ?? 'Unknown';
          final budgetAmount = (budget['budget'] ?? 0).toDouble();
          final actual = (budget['actual'] ?? 0).toDouble();
          final remaining = (budget['remaining'] ?? 0).toDouble();
          final percentage = budgetAmount > 0 ? (actual / budgetAmount) : 0.0;

          Color progressColor = colorScheme.primary;
          if (percentage > 1.0) {
            progressColor = colorScheme.error;
          } else if (percentage > 0.8) {
            progressColor = Colors.orange;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${actual.toStringAsFixed(2)} / ₹${budgetAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage > 1.0 ? 1.0 : percentage,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: progressColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remaining >= 0
                        ? 'Remaining: ₹${remaining.toStringAsFixed(2)}'
                        : 'Over budget: ₹${(-remaining).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: remaining >= 0
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
      Map<String, dynamic> categoryData, ColorScheme colorScheme) {
    final data = categoryData['data'];
    final expenses = data['expense'] as List<dynamic>? ?? [];

    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Spending Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _currentIndex = 1); // Navigate to categories tab
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...expenses.take(5).map((expense) {
          final category = expense['category'] ?? 'Unknown';
          final total = (expense['total'] ?? 0).toDouble();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.category, color: colorScheme.onPrimaryContainer),
              ),
              title: Text(category),
              trailing: Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMonthlyTrendSection(
      Map<String, dynamic> trendData, ColorScheme colorScheme) {
    final trends = trendData['data'] as List<dynamic>? ?? [];

    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    return MonthlyTrendChart(
      trends: trends,
      colorScheme: colorScheme,
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
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.08),
              child: Icon(icon),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
